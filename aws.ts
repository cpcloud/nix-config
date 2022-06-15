import * as aws from "@pulumi/aws";
import * as nixos from "./nixos";
import * as p from "@pulumi/pulumi";
import { Instance, Stack } from "./core";
import { ebs, ec2, iam, s3, ssm } from "@pulumi/aws";

const AVAILABILITY_ZONES = ["us-east-1a", "us-east-1b", "us-east-1c"];
const PRIVATE_START_IP = 30;
const PUBLIC_START_IP = 20;
const SUBNET_PREFIX = "10.0";
const VPC_CIDR = "10.0.0.0/16";

interface Networking {
  vpc: ec2.Vpc;
  privateSubnets: ec2.Subnet[];
}

function setupNetworking(instanceName: string): Networking {
  const vpc = new ec2.Vpc(`${instanceName}-vpc`, {
    cidrBlock: VPC_CIDR,
    enableDnsHostnames: true,
    enableDnsSupport: true,
  });

  new ec2.DefaultSecurityGroup(
    `${instanceName}-default-sec-group`,
    { vpcId: vpc.id },
    { parent: vpc }
  );

  const internetGateway = new ec2.InternetGateway(
    `${instanceName}-inet-gateway`,
    { vpcId: vpc.id },
    { parent: vpc }
  );

  const eip = new ec2.Eip(
    `${instanceName}-eip`,
    { vpc: true },
    {
      parent: internetGateway,
      dependsOn: [internetGateway],
    }
  );

  const publicRouteTable = new ec2.RouteTable(
    `${instanceName}-route-table`,
    {
      vpcId: vpc.id,
      routes: [
        {
          cidrBlock: "0.0.0.0/0",
          gatewayId: internetGateway.id,
        },
      ],
    },
    { parent: internetGateway }
  );

  const publicSubnets = AVAILABILITY_ZONES.map(
    (availabilityZone: string, index: number) => {
      const publicSubnet = new ec2.Subnet(
        `${instanceName}-${availabilityZone}-public-subnet`,
        {
          cidrBlock: `${SUBNET_PREFIX}.${PUBLIC_START_IP + index}.0/24`,
          mapPublicIpOnLaunch: true,
          vpcId: vpc.id,
          availabilityZone,
        },
        { parent: vpc }
      );

      new ec2.RouteTableAssociation(
        `${instanceName}-${availabilityZone}-route-table-association`,
        {
          subnetId: publicSubnet.id,
          routeTableId: publicRouteTable.id,
        },
        { parent: publicRouteTable }
      );

      return publicSubnet;
    }
  );

  const natGateway = new ec2.NatGateway(
    `${instanceName}-nat-gateway`,
    {
      allocationId: eip.id,
      subnetId: publicSubnets[0].id,
    },
    { parent: eip, dependsOn: [internetGateway] }
  );

  const privateRouteTable = new ec2.DefaultRouteTable(
    `${instanceName}-default-route-table`,
    {
      defaultRouteTableId: vpc.defaultRouteTableId,
      routes: [
        {
          cidrBlock: "0.0.0.0/0",
          natGatewayId: natGateway.id,
        },
      ],
    },
    { parent: natGateway }
  );

  const privateSubnets = AVAILABILITY_ZONES.map(
    (availabilityZone: string, index: number) => {
      const privateSubnet = new ec2.Subnet(
        `${instanceName}-${availabilityZone}-private-subnet`,
        {
          cidrBlock: `${SUBNET_PREFIX}.${PRIVATE_START_IP + index}.0/24`,
          vpcId: vpc.id,
          availabilityZone,
        },
        { parent: vpc }
      );

      new ec2.RouteTableAssociation(
        `${instanceName}-${availabilityZone}-private-route-table-association`,
        {
          routeTableId: vpc.mainRouteTableId,
          subnetId: privateSubnet.id,
        },
        { parent: privateRouteTable }
      );

      return privateSubnet;
    }
  );

  return { vpc, privateSubnets };
}

function setupIam(instanceName: string): iam.InstanceProfile {
  const ssmRole = new iam.Role(`${instanceName}-ssm-role`, {
    path: "/",
    tags: { Product: "ssm" },
    assumeRolePolicy: JSON.stringify({
      Version: "2012-10-17",
      Statement: [
        {
          Action: "sts:AssumeRole",
          Principal: {
            Service: "ec2.amazonaws.com",
          },
          Effect: "Allow",
          Sid: "",
        },
      ],
    }),
  });

  const iamPolicy = iam.getPolicyOutput({
    arn: "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  });

  new iam.RolePolicyAttachment(
    `${instanceName}-ssm-role-policy-attachment`,
    {
      role: ssmRole.name,
      policyArn: iamPolicy.arn,
    },
    { parent: ssmRole }
  );
  return new iam.InstanceProfile(
    `${instanceName}-ec2-instance-profile`,
    { role: ssmRole.name },
    { parent: ssmRole }
  );
}

function setupPrivateSecurityGroup(
  instanceName: string,
  vpc: ec2.Vpc
): ec2.SecurityGroup {
  return new ec2.SecurityGroup(
    `${instanceName}-private-sec-group`,
    {
      vpcId: vpc.id,
      egress: [
        {
          fromPort: 0,
          toPort: 0,
          protocol: "-1",
          cidrBlocks: ["0.0.0.0/0"],
        },
      ],
    },
    { parent: vpc }
  );
}

function setupInstance(instance: Instance, ami: ec2.Ami): ec2.Instance {
  const instanceName = instance.name;
  const iamInstanceProfile = setupIam(instanceName);
  const { vpc, privateSubnets } = setupNetworking(instanceName);
  const privateSecurityGroup = setupPrivateSecurityGroup(instanceName, vpc);
  return new ec2.Instance(
    instanceName,
    {
      ami: ami.id,
      associatePublicIpAddress: false,
      disableApiTermination: false,
      instanceType: instance.machine_type,
      vpcSecurityGroupIds: [privateSecurityGroup.id],
      subnetId: privateSubnets[0].id,
      iamInstanceProfile: iamInstanceProfile.id,
      rootBlockDevice: { volumeSize: instance.disk.size_gb },
      tags: { Name: instanceName },
    },
    { parent: ami }
  );
}

function setupNixOsImage(
  instanceName: string,
  nixLeaf: string,
  extension: string
): nixos.Image {
  return new nixos.Image(instanceName, {
    nixRootExpr: ".",
    family: "nixos",
    imageExpr: `nixosConfigurations.${instanceName}.config.system.build.${nixLeaf}`,
    extension,
  });
}

function setupSnapshotImportPolicy(
  instanceName: string,
  machineImageBucket: s3.Bucket
): iam.Role {
  const vmImportRole = new iam.Role(`${instanceName}-vm-import`, {
    assumeRolePolicy: JSON.stringify({
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Principal: { Service: "vmie.amazonaws.com" },
          Action: "sts:AssumeRole",
          Condition: {
            StringEquals: {
              ["sts:Externalid"]: "vmimport",
            },
          },
        },
      ],
    }),
  });

  const vmImportPolicy = machineImageBucket.arn.apply((arn: string) => {
    return {
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Action: ["s3:ListBucket", "s3:GetObject", "s3:GetBucketLocation"],
          Resource: [arn, `${arn}/*`],
        },
        {
          Effect: "Allow",
          Action: [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetBucketAcl",
          ],
          Resource: [arn, `${arn}/*`],
        },
        {
          Effect: "Allow",
          Action: [
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*",
          ],
          Resource: "*",
        },
      ],
    };
  });

  new iam.RolePolicy(
    `${instanceName}-vm-import-policy`,
    {
      role: vmImportRole.id,
      policy: vmImportPolicy.apply(JSON.stringify),
    },
    { parent: vmImportRole }
  );

  return vmImportRole;
}

export function handle(
  { instances, nix_leaf: nixLeaf, image: { family, bucket } }: Stack,
  providerConf: p.Config
): Record<string, p.Output<string>> {
  const machineImageBucket = new s3.Bucket(
    bucket,
    {
      acl: "private",
      tags: { Name: "NixOS AMI Images" },
    },
    { deleteBeforeReplace: true }
  );

  const output: Record<string, p.Output<string>> = {};

  for (const instanceConfig of instances) {
    const { name: instanceName, disk } = instanceConfig;
    const nixosImage = setupNixOsImage(instanceName, nixLeaf, "vhd");
    const vmImportRole = setupSnapshotImportPolicy(
      instanceName,
      machineImageBucket
    );

    // store the nix-generated image in a bucket
    const imageBucketObject = new s3.BucketObject(
      `${family}-${instanceName}`,
      {
        acl: "private",
        key: nixosImage.bucketObjectName,
        source: nixosImage.bucketObjectSource,
        bucket: machineImageBucket,
        contentType: "application/x-vhd",
      },
      {
        deleteBeforeReplace: true,
        parent: nixosImage,
      }
    );

    // construct an ebs snapshot import
    const ebsSnapshot = new ebs.SnapshotImport(
      `${instanceName}-snapshot`,
      {
        diskContainer: {
          format: "VHD",
          userBucket: {
            s3Bucket: machineImageBucket.id,
            s3Key: imageBucketObject.key,
          },
        },
        roleName: vmImportRole.name,
        tags: { Name: "nixos" },
      },
      { parent: imageBucketObject }
    );

    const deviceName = "/dev/xvda";
    const ami = new ec2.Ami(
      `${family}-${instanceName}-ami`,
      {
        architecture: "x86_64",
        virtualizationType: "hvm",
        rootDeviceName: deviceName,
        enaSupport: true,
        ebsBlockDevices: [
          {
            deviceName,
            snapshotId: ebsSnapshot.id,
            volumeSize: disk.size_gb,
            deleteOnTermination: true,
            volumeType: disk.type,
          },
        ],
      },
      { parent: ebsSnapshot }
    );

    const instance = setupInstance(instanceConfig, ami);

    attachSsmToInstance(instanceName, instance, providerConf);

    output[instanceName] = instance.id;
  }

  return output;
}

function attachSsmToInstance(
  instanceName: string,
  instance: ec2.Instance,
  providerConf: p.Config
): void {
  const callerId = aws.getCallerIdentity({});

  const ssmRunShellDocument = new ssm.Document(
    `${instanceName}-ssm-run-shell`,
    {
      name: "SSM-SessionManagerRunUserShell",
      documentType: "Session",
      documentFormat: "JSON",
      content: JSON.stringify({
        schemaVersion: "1.0",
        description: "Document to start an SSH session as the cloud user",
        sessionType: "Standard_Stream",
        inputs: {
          runAsEnabled: true,
          runAsDefaultUser: "cloud",
          idleSessionTimeout: "20",
          shellProfile: {
            linux: "bash -l -c 'sudo su -l cloud'",
          },
        },
      }),
    },
    {
      parent: instance,
      deleteBeforeReplace: true,
      replaceOnChanges: ["*"],
    }
  );

  const ssmPolicy = p
    .all([
      instance.arn,
      providerConf.require("region"),
      callerId,
      ssmRunShellDocument.arn,
    ])
    .apply(
      ([instanceArn, regionName, { accountId }, ssmRunShellDocumentArn]) => {
        return {
          Version: "2012-10-17",
          Statement: [
            {
              Effect: "Allow",
              Action: ["ssm:StartSession"],
              Resource: [
                instanceArn,
                `arn:aws:ssm:${regionName}:${accountId}:document/SSM-SessionManagerRunShell`,
                ssmRunShellDocumentArn,
              ],
              Condition: {
                BoolIfExists: {
                  "ssm:SessionDocumentAccessCheck": "true",
                },
                StringLike: {
                  "ssm:resourceTag/aws:ssmmessages:session-id": [
                    "${aws:userid}",
                  ],
                },
              },
            },
            {
              Effect: "Allow",
              Action: [
                "ssm:DescribeSessions",
                "ssm:GetConnectionStatus",
                "ssm:DescribeInstanceProperties",
                "ec2:DescribeInstances",
              ],
              Resource: "*",
            },
            {
              Effect: "Allow",
              Action: ["ssm:TerminateSession", "ssm:ResumeSession"],
              Resource: "*",
              Condition: {
                StringLike: {
                  "ssm:resourceTag/aws:ssmmessages:session-id": [
                    "${aws:userid}",
                  ],
                },
              },
            },
            {
              Effect: "Allow",
              Action: ["ssm:StartSession"],
              Resource: [
                instanceArn,
                "arn:aws:ssm:*:*:document/AWS-StartSSHSession",
              ],
              Condition: {
                StringLike: {
                  "ssm:resourceTag/aws:ssmmessages:session-id": [
                    "${aws:userid}",
                  ],
                },
              },
            },
          ],
        };
      }
    );

  // allow session manager access
  new iam.Policy(
    `${instanceName}-ssm`,
    { policy: ssmPolicy.apply(JSON.stringify) },
    {
      deleteBeforeReplace: true,
      replaceOnChanges: ["*"],
      parent: instance,
    }
  );
}
