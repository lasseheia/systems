resource "incus_image" "eclipse_mosquitto" {
  source_image = {
    remote = "docker"
    name   = "eclipse-mosquitto:latest"
  }
}

resource "incus_instance" "eclipse_mosquitto" {
  name  = "eclipse-mosquitto"
  type  = "container"
  image = incus_image.eclipse_mosquitto.fingerprint

  device {
    name = "eclipse-mosquitto"
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
      "ipv4.address" = var.eclipse_mosquitto_ipv4_address
    }
  }
}
