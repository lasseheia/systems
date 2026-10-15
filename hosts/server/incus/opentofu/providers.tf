terraform {
  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "3.6.2"
    }
    incus = {
      source  = "lxc/incus"
      version = "1.2.1"
    }
  }

  backend "s3" {
    bucket = "opentofu"
    key    = "terraform.tfstate"
    region = "us-east-1" # Required by the s3 backend but unused by Incus

    endpoints = {
      s3 = "https://server.heia.sh:8555"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    use_lockfile                = true
    insecure                    = false
  }
}

provider "incus" {
  default_remote = "server"

  remote {
    name    = "server"
    address = "https://server.heia.sh:8443"
  }

  remote {
    name     = "github"
    address  = "https://ghcr.io"
    protocol = "oci"
    public   = true
  }

  remote {
    name     = "docker"
    address  = "https://docker.io"
    protocol = "oci"
    public   = true
  }

}
