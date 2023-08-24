terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

// Configure the ncloud provider
provider "ncloud" {
  access_key  = var.NCP_ACCESS_KEY
  secret_key  = var.NCP_SECRET_KEY
  region      = "KR"
  site        = "public"
  support_vpc = true
}

resource "ncloud_vpc" "main" {
  ipv4_cidr_block = "10.1.0.0/16"
  name            = "vpc-${var.env}"
}
