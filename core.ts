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

export interface Instance {
  name: string;
  disk: Disk;
  machine_type: string;
  gpu: Gpu;
}

export interface Stack {
  enable: boolean;
  image: Image;
  instances: Instance[];
  nix_leaf: string;
}
