import * as p from "@pulumi/pulumi";
import { uuid } from "uuidv4";
import * as util from "util";

export class Provisioner<T, U> extends p.dynamic.Resource {
  public readonly args!: p.Output<T>;
  public readonly result!: p.Output<U>;
  public readonly changeToken!: p.Output<string>;

  constructor(
    name: string,
    props: ProvisionerProperties<T, U>,
    opts?: p.CustomResourceOptions
  ) {
    const provider: p.dynamic.ResourceProvider = {
      diff: async (
        _: p.ID,
        olds: State<T, U>,
        news: State<T, U>
      ): Promise<p.dynamic.DiffResult> => {
        const replacementProperties = [];
        if (!util.isDeepStrictEqual(olds.args, news.args)) {
          replacementProperties.push("args");
        }

        if (olds.changeToken !== news?.changeToken) {
          replacementProperties.push("changeToken");
        }

        const replace = replacementProperties.length > 0;
        return {
          changes: replace,
          replaces: replace ? replacementProperties : undefined,
          deleteBeforeReplace: true,
        };
      },
      create: async (inputs: State<T, U>): Promise<p.dynamic.CreateResult> => {
        const result = await props.onCreate(inputs.args);
        if (result !== undefined) {
          inputs.result = result;
        }
        return { id: uuid(), outs: inputs };
      },
    };
    super(
      provider,
      name,
      {
        args: props.args,
        result: undefined,
        changeToken: props.changeToken,
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
