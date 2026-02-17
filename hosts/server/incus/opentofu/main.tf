resource "incus_profile" "default" {
  name = "default"
  description = "Default Incus profile"
}

import {
  id = "default"
  to = incus_profile.default
}

resource "incus_storage_pool" "main" {
  name   = "incus"
  driver = "zfs"
}

resource "incus_storage_bucket" "opentofu" {
  name = "opentofu"
  pool = incus_storage_pool.main.name
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

resource "incus_network_forward" "bridge" {
  network        = incus_network.bridge.name
  listen_address = "10.0.0.171"

  ports = [
    {
      description    = "haos"
      protocol       = "tcp"
      listen_port    = "8123"
      target_port    = "8123"
      target_address = incus_instance.haos.ipv4_address
    },
    {
      description    = "kubernetes-ssh"
      protocol       = "tcp"
      listen_port    = "2222"
      target_port    = "22"
      target_address = incus_instance.kubernetes.ipv4_address
    },
    {
      description    = "kubernetes-api"
      protocol       = "tcp"
      listen_port    = "6443"
      target_port    = "6443"
      target_address = incus_instance.kubernetes.ipv4_address
    },
    {
      description  = "kubernetes-argocd"
      protocol     = "tcp"
      listen_port  = "8081"
      target_port  = "80"
      target_address = incus_instance.kubernetes.ipv4_address
    },
    {
      description = "eclipse-mosquitto"
      protocol    = "tcp"
      listen_port = "1883"
      target_port = "1883"
      target_address = incus_instance.eclipse_mosquitto.ipv4_address
    },
    {
      description    = "zigbee2mqtt"
      protocol       = "tcp"
      listen_port    = "8888"
      target_port    = "8080"
      target_address = incus_instance.zigbee2mqtt.ipv4_address
    },
    {
      description    = "mssql"
      protocol       = "tcp"
      listen_port    = "1433"
      target_port    = "1433"
      target_address = incus_instance.mssql.ipv4_address
    },
    {
      description    = "windows-rdp"
      protocol       = "tcp"
      listen_port    = "3389"
      target_port    = "3389"
      target_address = var.windows_ipv4_address
    }
  ]
}
