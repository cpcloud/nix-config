{ config, lib, pkgs, ... }:
let
  # test scripts for the nvidia docker runtime, for docker and podman if they
  # are enabled
  tensorflowImage = "tensorflow/tensorflow:${pkgs.python3Packages.tensorflow.version}-gpu";
  cudaImage = "nvidia/cuda:${pkgs.cudatoolkit_11.version}-base-ubi7";
  pythonScript = ''
    import tensorflow as tf
    assert tf.config.list_physical_devices(\"GPU\")
  '';
  testNVidiaContainerSimple = runtime: pkgs.writeShellScriptBin "test_nvidia_${runtime}_simple" ''
    set -euxo pipefail

    PATH=${lib.makeBinPath [ pkgs.${runtime} ]}

    "${runtime}" run --runtime nvidia --rm "${cudaImage}" nvidia-smi --list-gpus
  '';
  testNVidiaContainerTensorFlow = runtime: pkgs.writeShellScriptBin "test_nvidia_${runtime}_tensorflow" ''
    set -euxo pipefail

    PATH=${lib.makeBinPath [ pkgs.${runtime} ]}

    podman run \
      -e TF_CPP_MIN_LOG_LEVEL=1 \
      -e LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
      --runtime nvidia \
      --rm \
      ${tensorflowImage} \
      python -c "${pythonScript}"
  '';
in
{
  # this parameter is necessary because the nvidia container runtime odoesn't
  # support cgroupsv2
  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=0" ];

  environment.systemPackages = lib.optionals config.virtualisation.docker.enableNvidia [
    (testNVidiaContainerSimple "docker")
    (testNVidiaContainerTensorFlow "docker")
  ] ++ lib.optionals config.virtualisation.podman.enableNvidia [
    (testNVidiaContainerSimple "podman")
    (testNVidiaContainerTensorFlow "podman")
  ];
}
