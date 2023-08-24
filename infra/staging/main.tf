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
  site        = "PUBLIC"
  support_vpc = true
}

module "vpc" {
  source = "../modules/network"

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
  env            = "staging"
}


module "servers" {
  source = "../modules/server"

  USERNAME               = var.USERNAME
  PASSWORD               = var.PASSWORD
  DJANGO_SETTINGS_MODULE = var.DJANGO_SETTINGS_MODULE
  DJANGO_SECRET_KEY      = var.DJANGO_SECRET_KEY
  DJANGO_CONTIANER_NAME  = var.DJANGO_CONTIANER_NAME
  NCR_HOST               = var.NCR_HOST
  NCR_IMAGE              = var.NCR_IMAGE
  NCP_ACCESS_KEY         = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY         = var.NCP_SECRET_KEY
  NCP_LB_DOMAIN          = var.NCP_LB_DOMAIN
  POSTGRES_DB            = var.POSTGRES_DB
  POSTGRES_USER          = var.POSTGRES_USER
  POSTGRES_PASSWORD      = var.POSTGRES_PASSWORD
  POSTGRES_PORT          = var.POSTGRES_PORT
  POSTGRES_VOLUME        = var.POSTGRES_VOLUME
  DB_CONTAINER_NAME      = var.DB_CONTAINER_NAME
  env                    = "staging"
  vpc_id                 = module.vpc.vpc_id
}
