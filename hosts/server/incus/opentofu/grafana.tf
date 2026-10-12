resource "incus_image" "grafana" {
  source_image = {
    remote = "docker"
    name   = "grafana/grafana:13.2.3@sha256:b28bae15e219c998fb0e0424ed724930cc61b1f61fb404d47c862f9a23f9e572"
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
