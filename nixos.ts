import * as childProcess from "child_process";
import * as fastGlob from "fast-glob";
import * as p from "@pulumi/pulumi";
import * as path from "path";
import * as util from "util";
import { Provisioner } from "./provisioners";

const execFile = util.promisify(childProcess.execFile);

export interface ImageArgs {
  nixRootExpr: string;
  imageExpr: string;
  family: string;
  extension: string;
  outHashLength?: number;
  maxBuffer?: number;
}

interface ImageOutputs {
  bucketObjectName: string;
  bucketObjectSource: p.asset.Asset;
}

const DEFAULT_OUT_HASH_LENGTH = 10;
const DEFAULT_MAX_BUFFER = 1024 * 1024 * 1024;
const NIX_BUILD = "nix-build";
const NIX_INSTANTIATE = "nix-instantiate";

export class Image extends p.ComponentResource {
  private readonly provisioner: Provisioner<ImageArgs, ImageOutputs>;

  public readonly bucketObjectName: p.Output<string>; // eslint-disable-line max-len, @typescript-eslint/explicit-member-accessibility
  public readonly bucketObjectSource: p.Output<p.asset.Asset>; // eslint-disable-line max-len, @typescript-eslint/explicit-member-accessibility

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
        changeToken: execFile(NIX_INSTANTIATE, [
          args.nixRootExpr,
          "--attr",
          args.imageExpr,
        ]).then(({ stdout }: { stdout: string }): string => stdout.trim()), // eslint-disable-line max-len, github/no-then
        onCreate: async ({
          nixRootExpr,
          imageExpr,
          family,
          extension,
          outHashLength,
          maxBuffer,
        }: p.Unwrap<ImageArgs>): Promise<ImageOutputs> => {
          const execFileLocal = util.promisify(childProcess.execFile);
          const { stdout: nixImageDirUntrimmed } = await execFileLocal(
            NIX_BUILD,
            [nixRootExpr, "--attr", imageExpr, "--no-out-link"],
            { maxBuffer: maxBuffer || DEFAULT_MAX_BUFFER }
          );

          const nixImageDir = nixImageDirUntrimmed.trim();
          const [bucketObjectSource] = await fastGlob(
            path.join(nixImageDir, `*.${extension}`)
          );

          const outHash = path
            .basename(nixImageDir)
            .split("-")[0]
            .slice(0, outHashLength || DEFAULT_OUT_HASH_LENGTH);

          return {
            bucketObjectName: `${family}-${outHash}.${extension}`,
            bucketObjectSource: new p.asset.FileAsset(bucketObjectSource),
          };
        },
      },
      { parent: this }
    );

    this.bucketObjectName = this.provisioner.result.bucketObjectName;
    this.bucketObjectSource = this.provisioner.result.bucketObjectSource;
  }
}
