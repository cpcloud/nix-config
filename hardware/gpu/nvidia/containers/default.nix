{ config, lib, pkgs, ... }:
let
  enableNvidiaDocker = config.virtualisation.docker.enableNvidia;
  enableNvidiaPodman = config.virtualisation.podman.enableNvidia;
  enableNvidiaContainerRuntime = enableNvidiaDocker || enableNvidiaPodman;
  # test scripts for the nvidia docker runtime, for docker and podman if they
  # are enabled
  tensorflowImage = "tensorflow/tensorflow:${pkgs.python3Packages.tensorflow.version}-gpu";
  cudaImage = "nvidia/cuda:${pkgs.cudatoolkit_11.version}-base-ubi7";
  pythonScript = ''
    import tensorflow as tf
    assert tf.config.list_physical_devices(\"GPU\")
  '';
  testNVidiaContainerSimple = runtime: pkgs.writeSaneShellScriptBin {
    name = "test_nvidia_${runtime}_simple";
    buildInputs = [ pkgs.${runtime} ];
    src = ''
      set -x

      "${runtime}" run --runtime nvidia --rm "${cudaImage}" nvidia-smi --list-gpus
    '';
  };
  testNVidiaContainerTensorFlow = runtime: pkgs.writeSaneShellScriptBin {
    name = "test_nvidia_${runtime}_tensorflow";
    buildInputs = [ pkgs.${runtime} ];
    src = ''
      set -x

      podman run \
      -e TF_CPP_MIN_LOG_LEVEL=1 \
      -e LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
      --runtime nvidia \
      --rm \
      ${tensorflowImage} \
      python -c "${pythonScript}"
    '';
  };
in
{
  # this parameter is necessary because the nvidia container runtime odoesn't
  # support cgroupsv2
  boot.kernelParams = lib.optionals enableNvidiaContainerRuntime [ "systemd.unified_cgroup_hierarchy=0" ];

  environment.systemPackages = lib.optionals
    enableNvidiaDocker [
    (testNVidiaContainerSimple "docker")
    (testNVidiaContainerTensorFlow "docker")
  ] ++ lib.optionals enableNvidiaPodman [
    (testNVidiaContainerSimple "podman")
    (testNVidiaContainerTensorFlow "podman")
  ];
}
