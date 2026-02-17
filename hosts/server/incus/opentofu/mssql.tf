resource "incus_image" "mssql" {
  source_image = {
    remote = "mcr"
    name   = "mssql/server:2022-latest"
  }
}

resource "incus_instance" "mssql" {
  name  = "mssql"
  type  = "container"
  image = incus_image.mssql.fingerprint

  config = {
    "environment.ACCEPT_EULA"       = "Y"
    "environment.MSSQL_PID"         = "Developer"
    "environment.MSSQL_SA_PASSWORD" = var.mssql_sa_password
  }

  device {
    name = "mssql"
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
      "ipv4.address" = var.mssql_ipv4_address
    }
  }
}
