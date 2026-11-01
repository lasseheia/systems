resource "incus_image" "grafana" {
  source_image = {
    remote = "docker"
    name   = "grafana/grafana:13.3.0@sha256:488984b716c0862639f91a698adbe2862677a5a07bad42da5f03f3030883b205"
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
