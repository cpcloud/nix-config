import * as p from "@pulumi/pulumi";
import { compute, storage } from "@pulumi/gcp";
import * as child_process from "child_process";
import * as path from "path";
import * as util from "util";
import * as globby from "globby";

const execFile = util.promisify(child_process.execFile);

interface Disk {
  size_gb: number;
  type: string;
}

interface Gpu {
  count: number;
  type: string;
}

interface Instance {
  name: string;
  disk: Disk;
  machine_type: string;
  gpu: Gpu;
}

interface NixBuildPaths {
  outPath: string;
  imagePath: string;
}

const NESTED_VIRTUALIZATION_LICENSE =
  "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx";
const IMAGE_CONTENT_TYPE = "application/tar+gzip";

const buildNixOsImage = async (
  instanceName: string
): Promise<NixBuildPaths> => {
  const imageExpr = [
    "config",
    "nodes",
    instanceName,
    "configuration",
    "system",
    "build",
    "googleComputeImage",
  ].join(".");
  const { stdout: outPathBytes } = await execFile("nix-build", [
    "..",
    "--no-out-link",
    "--attr",
    imageExpr,
  ]);
  const outPath = outPathBytes.trim();
  const pattern = path.join(outPath, "*.tar.gz");
  const [imagePath] = await globby(pattern);
  return { imagePath, outPath };
};

export = async (): Promise<void> => {
  const conf = new p.Config("dev");
  const instances = conf.requireObject<Instance[]>("instances");
  const imageBucketName = conf.require("image_bucket");
  const imageBucket = new storage.Bucket(imageBucketName);

  for (const {
    name: instanceName,
    machine_type: instanceMachineType,
    gpu: instanceGpu,
    disk: instanceDisk,
  } of instances) {
    const { imagePath, outPath } = await buildNixOsImage(instanceName);
    const baseImagePath = path.basename(imagePath);
    const outHash = path.basename(outPath).split("-")[0];
    const imageBucketObjectName = `${outHash}-${baseImagePath}`;
    const imageBucketObject = new storage.BucketObject(
      imageBucketObjectName,
      {
        source: new p.asset.FileAsset(imagePath),
        bucket: imageBucket.name,
        name: imageBucketObjectName,
        contentType: IMAGE_CONTENT_TYPE,
        metadata: { nix_store_hash: outHash },
      },
      {
        deleteBeforeReplace: true,
        parent: imageBucket,
      }
    );

    const removeExtension = /\.raw\.tar\.gz|nixos-image-/g;
    const replaceDotAndUnderscore = /[._]+/g;
    const imageNameNoExtension = baseImagePath.replace(removeExtension, "");
    const imageNameNoUnderscores = imageNameNoExtension.replace(
      replaceDotAndUnderscore,
      "-"
    );
    const imageName = `x-${outHash.slice(0, 12)}-${imageNameNoUnderscores}`;

    const computeImage = new compute.Image(
      imageName,
      {
        family: "nixos",
        licenses: [NESTED_VIRTUALIZATION_LICENSE],
        rawDisk: { source: imageBucketObject.selfLink },
      },
      { parent: imageBucketObject }
    );
    const network = new compute.Network(`${instanceName}-network`);

    const onHostMaintenance = instanceGpu ? "TERMINATE" : "MIGRATE";
    const guestAccelerators = instanceGpu
      ? [{ count: instanceGpu.count, type: instanceGpu.type }]
      : [];

    const router = new compute.Router(
      `${instanceName}-router`,
      { network: network.selfLink },
      { parent: network }
    );
    new compute.RouterNat(
      `${instanceName}-router-nat`,
      {
        router: router.name,
        natIpAllocateOption: "AUTO_ONLY",
        sourceSubnetworkIpRangesToNat: "ALL_SUBNETWORKS_ALL_IP_RANGES",
        logConfig: { enable: true, filter: "ALL" },
      },
      { parent: router }
    );

    const iapSshFirewall = new compute.Firewall(
      "allow-inbound-iap",
      {
        network: network.selfLink,
        sourceRanges: ["35.235.240.0/20"],
        targetTags: ["dev"],
        logConfig: { metadata: "INCLUDE_ALL_METADATA" },
        allows: [
          {
            protocol: "tcp",
            ports: ["22"],
          },
        ],
      },
      { parent: network }
    );

    new compute.Instance(
      instanceName,
      {
        machineType: instanceMachineType,
        guestAccelerators,
        tags: ["dev"],
        scheduling: { onHostMaintenance },
        networkInterfaces: [{ network: network.selfLink }],
        bootDisk: {
          initializeParams: {
            image: computeImage.selfLink,
            size: instanceDisk.size_gb,
            type: instanceDisk.type,
          },
        },
        allowStoppingForUpdate: true,
      },
      { parent: computeImage, dependsOn: [iapSshFirewall] }
    );
  }
};
