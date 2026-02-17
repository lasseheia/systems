resource "incus_image" "kubernetes" {
  source_file = {
    metadata_path = "/nix/store/26kcl40fcd8spdfqvbp3j91vjy3y6lx8-tarball/tarball/nixos-image-lxc-metadata-26.05.20260130.6308c3b-x86_64-linux.tar.xz"
    data_path     = "/nix/store/ri6wih8irysg8vijja82k3w54qx8mzqz-nixos-disk-image/nixos.qcow2"
  }
}

resource "incus_instance" "kubernetes" {
  name  = "kubernetes"
  image = incus_image.kubernetes.fingerprint
  type  = "virtual-machine"

  config = {
    "limits.cpu"          = "4"
    "limits.memory"       = "12GB"
    "security.secureboot" = "false"
  }

  device {
    name = "kubernetes"
    type = "disk"

    properties = {
      path = "/"
      pool = incus_storage_pool.main.name
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      network        = incus_network.bridge.name
      "ipv4.address" = var.kubernetes_ipv4_address
    }
  }

  lifecycle {
    ignore_changes = [running]
  }
}
