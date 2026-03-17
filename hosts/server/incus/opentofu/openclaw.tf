resource "incus_network" "openclaw_bridge" {
  name = "openclawbr0"

  config = {
    "ipv4.address" = "198.19.0.1/24"
    "ipv4.nat"     = "true"
    "ipv4.dhcp"    = "true"
    "ipv6.address" = "none"
    "ipv6.nat"     = "false"
  }
}

resource "incus_network_acl" "openclaw_internet_only" {
  name        = "openclaw-internet-only"
  description = "Block OpenClaw access to private networks"

  egress = [
    {
      action      = "reject"
      description = "Block RFC1918 10/8"
      destination = "10.0.0.0/8"
      state       = "enabled"
    },
    {
      action      = "reject"
      description = "Block RFC1918 172.16/12"
      destination = "172.16.0.0/12"
      state       = "enabled"
    },
    {
      action      = "reject"
      description = "Block RFC1918 192.168/16"
      destination = "192.168.0.0/16"
      state       = "enabled"
    },
    {
      action      = "reject"
      description = "Block link-local"
      destination = "169.254.0.0/16"
      state       = "enabled"
    },
    {
      action      = "reject"
      description = "Block CGNAT"
      destination = "100.64.0.0/10"
      state       = "enabled"
    },
    {
      action      = "reject"
      description = "Block benchmark/test nets (includes openclawbr0)"
      destination = "198.18.0.0/15"
      state       = "enabled"
    },
  ]
}

resource "incus_image" "openclaw" {
  source_image = {
    remote = "github"
    name   = "openclaw/openclaw"
  }
}

resource "random_id" "openclaw_gateway_token" {
  byte_length = 32
}

resource "incus_instance" "openclaw" {
  name  = "openclaw"
  type  = "container"
  image = incus_image.openclaw.fingerprint

  config = {
    "boot.autostart"                     = "true"
    "environment.OPENCLAW_GATEWAY_BIND"  = "loopback"
    "environment.OPENCLAW_GATEWAY_TOKEN" = random_id.openclaw_gateway_token.hex
  }

  device {
    name = "openclaw"
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
      network                                = incus_network.openclaw_bridge.name
      "ipv4.address"                         = var.openclaw_ipv4_address
      "security.acls"                        = incus_network_acl.openclaw_internet_only.name
      "security.acls.default.ingress.action" = "allow"
      "security.acls.default.egress.action"  = "allow"
    }
  }

  device {
    name = "gateway-ui"
    type = "proxy"

    properties = {
      listen  = "tcp:127.0.0.1:18789"
      connect = "tcp:127.0.0.1:18789"
    }
  }

  device {
    name = "gateway-bridge"
    type = "proxy"

    properties = {
      listen  = "tcp:127.0.0.1:18790"
      connect = "tcp:127.0.0.1:18790"
    }
  }

}

output "openclaw_gateway_token" {
  description = "Generated gateway token for OpenClaw Control UI"
  value       = random_id.openclaw_gateway_token.hex
  sensitive   = true
}
