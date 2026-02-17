resource "incus_instance" "haos" {
  name         = "haos"
  type         = "virtual-machine"
  architecture = "x86_64"
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
      pool = "incus"
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

  device {
    name = "zwave"
    type = "usb"
    properties = {
      required  = "true"
      vendorid  = "0658"
      productid = "0200"
    }
  }

  lifecycle {
    ignore_changes = [running]
  }
}

import {
  id = "haos"
  to = incus_instance.haos
}
