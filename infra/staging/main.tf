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
  access_key  = var.ncp_access_key
  secret_key  = var.ncp_secret_key
  region      = "KR"
  site        = "PUBLIC"
  support_vpc = true
}

locals {
  stage = "staging"
}

module "vpc" {
  source = "../modules/network"

  ncp_access_key = var.ncp_access_key
  ncp_secret_key = var.ncp_secret_key
  env            = local.stage
}

module "servers" {
  source = "../modules/server"

  username               = var.username
  password               = var.password
  django_settings_module = var.django_settings_module
  django_secret_key      = var.django_secret_key
  django_container_name  = var.django_container_name
  ncr_host               = var.ncr_host
  ncr_image              = var.ncr_image
  ncp_access_key         = var.ncp_access_key
  ncp_secret_key         = var.ncp_secret_key
  ncp_lb_domain          = var.ncp_lb_domain
  postgres_db            = var.postgres_db
  postgres_user          = var.postgres_user
  postgres_password      = var.postgres_password
  postgres_port          = var.postgres_port
  postgres_volume        = var.postgres_volume
  db_container_name      = var.db_container_name
  env                    = local.stage
  vpc_id                 = module.vpc.vpc_id
}

module "load_balancer" {
  source = "../modules/loadBalancer"

  ncp_access_key        = var.ncp_access_key
  ncp_secret_key        = var.ncp_secret_key
  env                   = local.stage
  vpc_id                = module.vpc.vpc_id
  be_server_instance_no = module.servers.be_server_instance_no
}
