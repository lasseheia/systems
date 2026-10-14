resource "incus_image" "grafana" {
  source_image = {
    remote = "docker"
    name   = "grafana/grafana:13.2.4@sha256:dbbc38ea21103cefb50396340cd88afec779c7e070b0a7bf5a75b4ce46651d3f"
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
