resource "incus_profile" "default" {
  name        = "default"
  description = "Default Incus profile"
}

import {
  id = "default"
  to = incus_profile.default
}

resource "incus_storage_pool" "main" {
  name   = "incus"
  driver = "zfs"

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_storage_bucket" "opentofu" {
  name    = "opentofu"
  pool    = incus_storage_pool.main.name
  project = "default"

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_network" "bridge" {
  name = "incusbr0"

  config = {
    "ipv4.address" = "192.168.0.1/24"
    "ipv4.nat"     = "true"
    "ipv4.dhcp"    = "true"
    "ipv6.address" = "none"
    "ipv6.nat"     = "false"
  }
}

data "dns_a_record_set" "server" {
  host = "server.heia.sh"
}

resource "incus_network_forward" "bridge" {
  network        = incus_network.bridge.name
  listen_address = one(data.dns_a_record_set.server.addrs)

  ports = [
    {
      description    = "haos"
      protocol       = "tcp"
      listen_port    = "8123"
      target_port    = "8123"
      target_address = var.haos_ipv4_address
    },
    {
      description    = "eclipse-mosquitto"
      protocol       = "tcp"
      listen_port    = "1883"
      target_port    = "1883"
      target_address = var.eclipse_mosquitto_ipv4_address
    },
    {
      description    = "zigbee2mqtt"
      protocol       = "tcp"
      listen_port    = "8888"
      target_port    = "8080"
      target_address = var.zigbee2mqtt_ipv4_address
    }
  ]
}
