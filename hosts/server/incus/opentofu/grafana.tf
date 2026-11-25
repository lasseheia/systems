resource "incus_image" "grafana" {
  source_image = {
    remote = "docker"
    name   = "grafana/grafana:13.3.2@sha256:81556409ba48b2b922e0adb69a2511337d8ba7578f11962eefa6149a2d815101"
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
