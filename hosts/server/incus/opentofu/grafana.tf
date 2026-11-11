resource "incus_image" "grafana" {
  source_image = {
    remote = "docker"
    name   = "grafana/grafana:13.3.1@sha256:0615ec4fbd4072004b7d86b46ded63013a74b7d6eb1119273dd89e8fa25c13cf"
  }
}

resource "incus_instance" "grafana" {
  name  = "grafana"
  type  = "container"
  image = incus_image.grafana.fingerprint

  device {
    name = "grafana"
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
      "ipv4.address" = var.grafana_ipv4_address
    }
  }
}
