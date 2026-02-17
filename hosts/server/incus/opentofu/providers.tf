terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "1.0.2"
    }
  }

  backend "s3" {
    bucket = "opentofu"
    key    = "terraform.tfstate"
    region = "us-east-1" # Required by the s3 backend but unused by Incus

    endpoints = {
      s3 = "https://127.0.0.1:8555"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    use_lockfile                = true
    insecure                    = true
  }
}

provider "incus" {
  default_remote = "local"

  remote {
    name     = "mcr"
    address  = "https://mcr.microsoft.com"
    protocol = "oci"
    public   = true
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
