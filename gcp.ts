import * as nixos from "./nixos";
import * as p from "@pulumi/pulumi";
import { compute, projects, storage } from "@pulumi/gcp";
import { Stack } from "./core";

const GCP_NESTED_VIRTUALIZATION_LICENSE =
  "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx";
const GCP_IMAGE_CONTENT_TYPE = "application/tar+gzip";
const GCP_IAP_INGRESS_ADDRESS = "35.235.240.0/20";

function enableGcpService(name: string): p.Resource {
  return new projects.Service(name, {
    service: `${name}.googleapis.com`,
    disableDependentServices: false,
    disableOnDestroy: false,
  });
}

export function handle(
  { instances, nix_leaf: nixLeaf, image: { family, bucket } }: Stack,
  providerConf: p.Config
): Record<string, p.Output<string>> {
  const computeService = enableGcpService("compute");
  const storageService = enableGcpService("storage");
  const region = providerConf.require("region");

  const machineImageBucket = new storage.Bucket(
    bucket,
    { location: region.toUpperCase() },
    {
      parent: storageService,
      dependsOn: [storageService],
    }
  );

  const computeInstances: Record<string, p.Output<string>> = {};

  for (const {
    name: instanceName,
    machine_type: machineType,
    gpu,
    disk,
  } of instances) {
    const imageExpr = `nixosConfigurations.${instanceName}.config.system.build.${nixLeaf}`;
    const nixosImage = new nixos.Image(
      instanceName,
      {
        nixRootExpr: ".",
        family,
        imageExpr,
        extension: "tar.gz",
      },
      { parent: machineImageBucket }
    );

    // store the nix-generated tarball in a GCP bucket
    const imageBucketObject = new storage.BucketObject(
      `${family}-${instanceName}`,
      {
        source: nixosImage.bucketObjectSource.apply(
          imagePath => new p.asset.FileAsset(imagePath)
        ),
        bucket: machineImageBucket.name,
        name: nixosImage.bucketObjectName,
        contentType: GCP_IMAGE_CONTENT_TYPE,
      },
      {
        deleteBeforeReplace: true,
        parent: nixosImage,
        dependsOn: [storageService],
      }
    );

    // construct a new GCP compute image
    const computeImage = new compute.Image(
      `${family}-${instanceName}`,
      {
        family,
        licenses: [GCP_NESTED_VIRTUALIZATION_LICENSE],
        rawDisk: { source: imageBucketObject.selfLink },
      },
      { parent: imageBucketObject, dependsOn: [computeService] }
    );

    // construct a network specific to the instance
    const network = new compute.Network(
      instanceName,
      {},
      {
        parent: computeService,
        dependsOn: [computeService],
      }
    );

    // if instance has a GPU then the only valid host maintenance action is
    // to terminate the running instance
    const onHostMaintenance = gpu ? "TERMINATE" : "MIGRATE";
    const guestAccelerators = gpu ? [{ count: gpu.count, type: gpu.type }] : [];

    // the instance has a completely private IP, which means we do not
    // have external access without NAT, so set up NAT
    //
    // the first step is to construct a router
    const router = new compute.Router(
      instanceName,
      { network: network.selfLink },
      { parent: network, dependsOn: [computeService] }
    );

    // the second step is to construct NAT for the router
    new compute.RouterNat(
      instanceName,
      {
        router: router.name,
        natIpAllocateOption: "AUTO_ONLY",
        sourceSubnetworkIpRangesToNat: "ALL_SUBNETWORKS_ALL_IP_RANGES",
        logConfig: { enable: true, filter: "ALL" },
      },
      { parent: router, dependsOn: [computeService] }
    );

    // enable in bound SSH traffic for the instance, but limit
    // it to the Google IAP IP address
    const iapSshFirewall = new compute.Firewall(
      "allow-inbound-iap",
      {
        network: network.selfLink,
        sourceRanges: [GCP_IAP_INGRESS_ADDRESS],
        targetTags: ["dev"],
        logConfig: { metadata: "INCLUDE_ALL_METADATA" },
        allows: [
          {
            protocol: "tcp",
            ports: ["22"],
          },
        ],
      },
      {
        parent: network,
        dependsOn: [computeService],
      }
    );

    // finally, construct the instance
    const instance = new compute.Instance(
      instanceName,
      {
        machineType,
        guestAccelerators,
        tags: ["dev"],
        scheduling: { onHostMaintenance },
        networkInterfaces: [{ network: network.selfLink }],
        bootDisk: {
          initializeParams: {
            image: computeImage.selfLink,
            size: disk.size_gb,
            type: disk.type,
          },
        },
        allowStoppingForUpdate: !!gpu,
      },
      {
        parent: computeImage,
        dependsOn: [iapSshFirewall, computeService],
      }
    );
    computeInstances[instanceName] = instance.name;
  }
  return computeInstances;
}
