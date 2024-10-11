terraform {
  backend "remote" {
    organization = "larivierec"
    workspaces {
      name = "home-tailscale-provisioner"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.10.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.17.2"
    }
  }
}

provider "bitwarden" {
  access_token = data.sops_file.this.data["BW_PROJECT_TOKEN"]
  experimental {
    embedded_client = true
  }
}

provider "tailscale" {
  oauth_client_id     = local.tailscale_secret["clientid"]
  oauth_client_secret = local.tailscale_secret["clientsecret"]
}

data "bitwarden_secret" "tailscale" {
  id = "a8d9079c-7477-4591-b38c-b20400d8326e"
}

locals {
  tailscale_secret = jsondecode(data.bitwarden_secret.tailscale.value)
}
