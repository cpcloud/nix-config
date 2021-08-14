import * as childProcess from "child_process";
import * as fg from "fast-glob";
import * as p from "@pulumi/pulumi";
import * as path from "path";
import * as util from "util";
import { Provisioner } from "./provisioners";

const execFile = util.promisify(childProcess.execFile);

export interface ImageArgs {
  nixExpr: string;
  imageExpr: string;
  family: string;
  outHashLength?: number;
}

interface ImageOutputs {
  bucketObjectName: string;
  bucketObjectSource: string;
}

const GZIPPED_TARBALL_EXTENSION = "tar.gz";
const NIX_BUILD = "nix-build";
const NIX_INSTANTIATE = "nix-instantiate";

export class Image extends p.ComponentResource {
  private readonly provisioner: Provisioner<ImageArgs, ImageOutputs>;

  public readonly bucketObjectName: p.Output<string>; // eslint-disable-line max-len, @typescript-eslint/explicit-member-accessibility
  public readonly bucketObjectSource: p.Output<string>; // eslint-disable-line max-len, @typescript-eslint/explicit-member-accessibility

  constructor(
    name: string,
    args: ImageArgs,
    opts?: p.ComponentResourceOptions
  ) {
    super(`nixos:${Image.name}`, name, args, opts);

    const { nixExpr, imageExpr, outHashLength } = args;

    this.provisioner = new Provisioner(
      `${name}-provisioner`,
      {
        args,
        changeToken: execFile(NIX_INSTANTIATE, [
          nixExpr,
          "--attr",
          imageExpr,
        ]).then(({ stdout }: { stdout: string }): string => stdout.trim()), // eslint-disable-line max-len, github/no-then
        onCreate: async ({
          family,
        }: p.Unwrap<ImageArgs>): Promise<ImageOutputs> => {
          const { stdout: nixImageDirUntrimmed } = await util.promisify(
            childProcess.execFile
          )(NIX_BUILD, [nixExpr, "--attr", imageExpr, "--no-out-link"], {
            maxBuffer: 1024 * 1024 * 1024,
          });

          const [bucketObjectSource] = await fg(
            path.join(
              nixImageDirUntrimmed.trim(),
              `*.${GZIPPED_TARBALL_EXTENSION}`
            )
          );
          const outHash = path
            .basename(path.dirname(bucketObjectSource))
            .split("-")[0]
            .slice(0, outHashLength ?? 12);
          const bucketObjectName = `${family}-${outHash}.${GZIPPED_TARBALL_EXTENSION}`;

          return {
            bucketObjectName,
            bucketObjectSource,
          };
        },
      },
      { parent: this }
    );

    this.bucketObjectName = this.provisioner.result.bucketObjectName;
    this.bucketObjectSource = this.provisioner.result.bucketObjectSource;
  }
}
