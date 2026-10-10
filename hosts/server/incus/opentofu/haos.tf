resource "incus_instance" "haos" {
  name  = "haos"
  type  = "virtual-machine"
  image = "haos-18.3"
  config = {
    "limits.cpu"          = "4"
    "limits.memory"       = "4GB"
    "security.secureboot" = "false"
  }
  ephemeral = false
  profiles  = ["default"]

  device {
    name = "root"
    properties = {
      path = "/"
      pool = incus_storage_pool.main.name
      size = "64GiB"
    }
    type = "disk"
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      network        = incus_network.bridge.name
      "ipv4.address" = var.haos_ipv4_address
    }
  }

  lifecycle {
    ignore_changes  = [running]
    prevent_destroy = true
  }
}
