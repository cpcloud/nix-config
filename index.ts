import * as gcp from "./gcp";
import * as p from "@pulumi/pulumi";
import { Stack } from "./core";

export = (): Record<string, p.Output<string>> => {
  const dev = new p.Config("dev");

  const modules = { gcp };
  const outputs: Record<string, p.Output<string>> = {};

  for (const [key, module] of Object.entries(modules)) {
    const providerConf = new p.Config(key);
    const conf = dev.requireObject<Stack>(key);

    if (conf.enable) {
      Object.assign(outputs, module.handle(conf, providerConf));
    }
  }

  return outputs;
};
