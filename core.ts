interface Disk {
  size_gb: number;
  type: string;
}

interface Gpu {
  count: number;
  type: string;
}

interface Image {
  bucket: string;
  family: string;
}

interface Logging {
  enable: boolean;
}

export interface Instance {
  name: string;
  disk: Disk;
  machine_type: string;
  gpu: Gpu;
  logging: Logging;
}

export interface Stack {
  enable: boolean;
  image: Image;
  instances: Instance[];
  nix_leaf: string;
}
