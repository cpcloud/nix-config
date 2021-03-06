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
    {
      location: region.toUpperCase(),
      // delete the bucket even if it contains objects
      forceDestroy: true,
    },
    {
      parent: storageService,
      dependsOn: [storageService],
    }
  );

  const computeInstances: Record<string, p.Output<string>> = {};

  const dailyPolicy = new compute.ResourcePolicy(
    "daily",
    {
      description: "Start and stop instances",
      instanceSchedulePolicy: {
        timeZone: "America/New_York",
        vmStartSchedule: {
          schedule: "0 9 * * *",
        },
        vmStopSchedule: {
          schedule: "0 21 * * *",
        },
      },
      region,
    },
    {
      parent: computeService,
      dependsOn: [computeService],
    }
  );

  for (const {
    name: instanceName,
    machine_type: machineType,
    gpu,
    disk,
    logging,
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
        source: nixosImage.bucketObjectSource,
        bucket: machineImageBucket.name,
        name: nixosImage.bucketObjectName,
        contentType: GCP_IMAGE_CONTENT_TYPE,
        // we don't need multi-regional storage, this image isn't used that often
        storageClass: "REGIONAL",
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
      {
        parent: imageBucketObject,
        dependsOn: [computeService],
      }
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

    // subnet
    const subnet = new compute.Subnetwork(instanceName, {
      network: network.id,
      ipCidrRange: "10.0.0.0/16",
      region,
    });

    // the instance has a private IP, which means we do not
    // have external access without NAT, so set up NAT
    //
    // the first step is to construct a router
    const router = new compute.Router(
      instanceName,
      {
        region,
        network: network.selfLink,
      },
      { dependsOn: [computeService] }
    );

    // the second step is to construct NAT for the router
    const routerNat = new compute.RouterNat(
      instanceName,
      {
        router: router.name,
        region,
        natIpAllocateOption: "AUTO_ONLY",
        sourceSubnetworkIpRangesToNat: "LIST_OF_SUBNETWORKS",
        subnetworks: [
          {
            name: subnet.id,
            sourceIpRangesToNats: ["ALL_IP_RANGES"],
          },
        ],
        logConfig: { enable: logging.enable, filter: "ERRORS_ONLY" },
      },
      {
        parent: router,
        dependsOn: [computeService],
      }
    );

    // enable in bound SSH traffic for the instance, but limit
    // it to the Google IAP IP address
    const iapSshFirewall = new compute.Firewall(
      "allow-inbound-iap",
      {
        network: network.selfLink,
        sourceRanges: [GCP_IAP_INGRESS_ADDRESS],
        targetTags: ["dev"],
        logConfig: {
          metadata: `${logging.enable ? "IN" : "EX"}CLUDE_ALL_METADATA`,
        },
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

    // if instance has a GPU then the only valid host maintenance action is
    // to terminate the running instance
    const onHostMaintenance = gpu ? "TERMINATE" : "MIGRATE";
    const guestAccelerators = gpu ? [{ count: gpu.count, type: gpu.type }] : [];

    // finally, construct the instance
    const instance = new compute.Instance(
      instanceName,
      {
        machineType,
        guestAccelerators,
        tags: ["dev"],
        scheduling: { onHostMaintenance },
        networkInterfaces: [
          {
            network: network.selfLink,
            subnetwork: subnet.selfLink,
          },
        ],
        bootDisk: {
          initializeParams: {
            image: computeImage.selfLink,
            size: disk.size_gb,
            type: disk.type,
          },
        },
        resourcePolicies: dailyPolicy.selfLink,
        allowStoppingForUpdate: !!gpu,
        metadata: {
          ["block-project-ssh-keys"]: "true",
        },
      },
      {
        parent: computeImage,
        dependsOn: [iapSshFirewall, computeService, routerNat],
      }
    );
    computeInstances[instanceName] = instance.name;
  }
  return computeInstances;
}
