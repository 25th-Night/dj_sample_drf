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

module "network" {
  source = "../modules/network"

  ncp_access_key = var.ncp_access_key
  ncp_secret_key = var.ncp_secret_key
  env            = local.stage
}

module "db" {
  source = "../modules/server"

  ncp_access_key   = var.ncp_access_key
  ncp_secret_key   = var.ncp_secret_key
  env              = local.stage
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.subnet_id
  name             = "db"
  acg_port_range   = 5432
  init_script_path = "db_init_script.tftpl"
  init_script_envs = {
    username          = var.username
    password          = var.password
    postgres_db       = var.postgres_db
    postgres_user     = var.postgres_user
    postgres_password = var.postgres_password
    postgres_port     = var.postgres_port
    postgres_volume   = var.postgres_volume
    db_container_name = var.db_container_name
  }
  server_product_code = data.ncloud_server_product.sm.product_code
}

module "be" {
  source = "../modules/server"

  ncp_access_key   = var.ncp_access_key
  ncp_secret_key   = var.ncp_secret_key
  env              = local.stage
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.subnet_id
  name             = "be"
  acg_port_range   = 8000
  init_script_path = "be_init_script.tftpl"
  init_script_envs = {
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
    db_host                = ncloud_public_ip.db.public_ip
    postgres_volume        = var.postgres_volume
    db_container_name      = var.db_container_name
  }
  server_product_code = data.ncloud_server_product.sm.product_code
}

module "load_balancer" {
  source = "../modules/loadBalancer"

  ncp_access_key        = var.ncp_access_key
  ncp_secret_key        = var.ncp_secret_key
  env                   = local.stage
  vpc_id                = module.network.vpc_id
  be_server_instance_no = module.be.server_instance_no
}

resource "ncloud_public_ip" "be" {
  server_instance_no = module.be.server_instance_no
}


resource "ncloud_public_ip" "db" {
  server_instance_no = module.db.server_instance_no
}


data "ncloud_server_product" "sm" {
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  filter {
    name   = "product_code"
    values = ["SSD"]
    regex  = true
  }

  filter {
    name   = "cpu_count"
    values = ["2"]
  }

  filter {
    name   = "memory_size"
    values = ["4GB"]
  }

  filter {
    name   = "base_block_storage_size"
    values = ["50GB"]
  }

  filter {
    name   = "product_type"
    values = ["HICPU"]
  }
}
