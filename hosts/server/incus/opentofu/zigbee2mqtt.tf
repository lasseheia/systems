resource "incus_storage_volume" "zigbee2mqtt_data" {
  name    = "zigbee2mqtt-data"
  pool    = incus_storage_pool.main.name
  type    = "custom"
  project = "default"
  config  = { size = "4GiB" }
  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_image" "zigbee2mqtt" {
  source_image = {
    remote = "github"
    name   = "koenkk/zigbee2mqtt:latest"
  }
}

resource "incus_instance" "zigbee2mqtt" {
  name  = "zigbee2mqtt"
  type  = "container"
  image = incus_image.zigbee2mqtt.fingerprint

  depends_on = [incus_instance.eclipse_mosquitto]

  config = {
    "environment.TZ"                             = "Europe/Oslo"
    "environment.ZIGBEE2MQTT_CONFIG_MQTT_SERVER" = "mqtt://eclipse-mosquitto.incus:1883"
  }

  device {
    name = "zigbee2mqtt"
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
      "ipv4.address" = var.zigbee2mqtt_ipv4_address
    }
  }

  device {
    name = "data"
    type = "disk"
    properties = {
      path   = "/app/data"
      pool   = incus_storage_pool.main.name
      source = incus_storage_volume.zigbee2mqtt_data.name
    }
  }

  device {
    name = "conbee"
    type = "unix-char"
    properties = {
      required = "true"
      source   = "/dev/serial/by-id/usb-dresden_elektronik_ingenieurtechnik_GmbH_ConBee_II_DE2488969-if00"
      path     = "/dev/ttyACM0"
    }
  }
}
