import * as p from "@pulumi/pulumi";
import { Provisioner } from "./provisioners";
import * as util from "util";
import * as globby from "globby";
import * as path from "path";
import * as child_process from "child_process";

const execFile = util.promisify(child_process.execFile);

export interface ImageArgs {
  osImage: string;
  nixpkgsPath: string;
  expr: string;
  family: string;
}

interface ImageOutputs {
  bucketObjectName: string;
  bucketObjectSource: string;
}

export class Image extends p.ComponentResource {
  private readonly provisioner: Provisioner<ImageArgs, ImageOutputs>;

  public readonly bucketObjectName: p.Output<string>;
  public readonly bucketObjectSource: p.Output<string>;

  constructor(
    name: string,
    args: ImageArgs,
    opts?: p.ComponentResourceOptions
  ) {
    super(`nixos:${Image.name}`, name, args, opts);

    this.provisioner = new Provisioner(
      `${name}-provisioner`,
      {
        args,
        changeToken: execFile("nix-instantiate", [
          args.nixpkgsPath,
          "--attr",
          args.expr,
        ]).then(({ stdout: token }: { stdout: string }) => token.trim()),
        onCreate: async ({
          family,
        }: p.Unwrap<ImageArgs>): Promise<ImageOutputs> => {
          const execFile = util.promisify(child_process.execFile);

          const { stdout: nixImageDirUntrimmed } = await execFile(
            "nix-build",
            [args.nixpkgsPath, "--attr", args.expr, "--no-out-link"],
            { maxBuffer: 1024 * 1024 * 1024 }
          );

          const [imagePath] = await globby(
            path.join(nixImageDirUntrimmed.trim(), "*.tar.gz")
          );

          const outHash = path.basename(path.dirname(imagePath)).split("-")[0];

          return {
            bucketObjectName: `${family}-${outHash.slice(0, 12)}.tar.gz`,
            bucketObjectSource: imagePath,
          };
        },
      },
      { parent: this }
    );

    this.bucketObjectName = this.provisioner.result.bucketObjectName;
    this.bucketObjectSource = this.provisioner.result.bucketObjectSource;
  }
}
