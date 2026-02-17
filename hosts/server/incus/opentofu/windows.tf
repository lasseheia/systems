resource "incus_instance" "windows" {
  name = "windows"
  type = "virtual-machine"

  config = {
    "limits.cpu"          = "4"
    "limits.memory"       = "8GB"
    "security.secureboot" = "false"
  }

  device {
    name = "root"
    type = "disk"

    properties = {
      path            = "/"
      pool            = incus_storage_pool.main.name
      size            = "80GiB"
      "io.bus"       = "nvme"
      "boot.priority" = "1"
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      network      = incus_network.bridge.name
      "ipv4.address" = var.windows_ipv4_address
    }
  }

  device {
    name = "tpm"
    type = "tpm"

    properties = {}
  }

  lifecycle {
    ignore_changes = [running]
  }
}
