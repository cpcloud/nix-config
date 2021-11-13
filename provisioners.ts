import * as p from "@pulumi/pulumi";
import * as util from "util";
import * as uuidv4 from "uuidv4";

export class Provisioner<T, U> extends p.dynamic.Resource {
  public readonly args!: p.Output<T>; // eslint-disable-line max-len, @typescript-eslint/explicit-member-accessibility
  public readonly result!: p.Output<U>; // eslint-disable-line max-len, @typescript-eslint/explicit-member-accessibility
  public readonly changeToken!: p.Output<string>; // eslint-disable-line max-len, @typescript-eslint/explicit-member-accessibility

  constructor(
    name: string,
    { args, changeToken, onCreate }: ProvisionerProperties<T, U>,
    opts?: p.CustomResourceOptions
  ) {
    const provider: p.dynamic.ResourceProvider = {
      diff: async (
        _: p.ID,
        olds: State<T, U>,
        news: State<T, U>
      ): Promise<p.dynamic.DiffResult> => {
        const replaces = [];
        if (!util.isDeepStrictEqual(olds.args, news.args)) {
          replaces.push("args");
        }

        if (olds.changeToken !== news?.changeToken) {
          replaces.push("changeToken");
        }

        return {
          changes: replaces.length > 0,
          replaces,
          deleteBeforeReplace: true,
        };
      },
      create: async (inputs: State<T, U>): Promise<p.dynamic.CreateResult> => {
        const result = await onCreate(inputs.args);
        if (result !== undefined) {
          inputs.result = result;
        }
        return { id: uuidv4.uuid(), outs: inputs };
      },
    };
    super(
      provider,
      name,
      {
        args,
        result: undefined,
        changeToken,
      },
      opts
    );
  }
}

export interface ProvisionerProperties<T, U> {
  args: p.Input<T>;
  changeToken: p.Input<string>;
  onCreate: (args: p.Unwrap<T>) => Promise<p.Unwrap<U>>;
}

interface State<T, U> {
  args: p.Unwrap<T>;
  changeToken: p.Unwrap<string>;
  result: p.Unwrap<U>;
}
