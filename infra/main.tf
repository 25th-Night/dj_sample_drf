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
  access_key = var.NCP_ACCESS_KEY
  secret_key = var.NCP_SECRET_KEY
  region      = "KR"
  site = "PUBLIC"
  support_vpc = true
}

variable "PASSWORD" {
  type = string
  sensitive = true
}

variable "USERNAME" {
  type = string
  sensitive = true
}

variable "DJANGO_SETTINGS_MODULE" {
  type = string
}

variable "DJANGO_SECRET_KEY" {
  type = string
}

variable "DJANGO_CONTIANER_NAME" {
  type = string
}

variable "DJANGO_HOST" {
  type = string
}

variable "NCR_HOST" {
  type = string
}

variable "NCR_IMAGE" {
  type = string
}

variable "NCP_ACCESS_KEY" {
  type = string
}

variable "NCP_SECRET_KEY" {
  type = string
}

variable "NCP_LB_DOMAIN" {
  type = string
}

variable "POSTGRES_DB" {
  type = string
}

variable "POSTGRES_USER" {
  type = string
  sensitive = true
}

variable "POSTGRES_PASSWORD" {
  type = string
}

variable "POSTGRES_PORT" {
  type = number
  sensitive = true
}

variable "POSTGRES_VOLUME" {
  type = string
  sensitive = true
}

variable "DB_CONTAINER_NAME" {
  type = string
  sensitive = true
}

resource "ncloud_login_key" "loginkey" {
  key_name = "test-key"
}

resource "ncloud_vpc" "main" {
  ipv4_cidr_block = "10.1.0.0/16"
  name = "lion-tf"
}

resource "ncloud_subnet" "main" {
  vpc_no         = ncloud_vpc.main.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.main.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
  name = "lion-tf-subnet"
}

resource "ncloud_access_control_group" "be-acg" {
  name        = "be-staging"
  vpc_no      = ncloud_vpc.main.id
}

data "ncloud_access_control_group" "default" {
    id = "124478" # lion-tf-default-acg
}

resource "ncloud_access_control_group_rule" "be-acg-rule" {
  access_control_group_no = ncloud_access_control_group.be-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "8000"
    description = "accept 8000 port for django"
  }
}

resource "ncloud_network_interface" "be" {
    name                  = "be-nic"
    subnet_no             = ncloud_subnet.main.id
    access_control_groups = [
        ncloud_vpc.main.default_access_control_group_no,
        ncloud_access_control_group.be-acg.id
    ]
}

resource "ncloud_server" "be" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "be-staging"
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code = data.ncloud_server_products.sm.server_products[0].product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no = ncloud_init_script.be.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.be.id
    order = 0
  }
}

resource "ncloud_init_script" "be" {
  name    = "set-be-tf"
  content = templatefile("${path.module}/be_init_script.tftpl", {
    PASSWORD = var.PASSWORD
    USERNAME = var.USERNAME
    DJANGO_SETTINGS_MODULE = var.DJANGO_SETTINGS_MODULE
    DJANGO_SECRET_KEY = var.DJANGO_SECRET_KEY
    DJANGO_CONTIANER_NAME = var.DJANGO_CONTIANER_NAME
    DJANGO_HOST = var.DJANGO_HOST
    NCR_HOST = var.NCR_HOST
    NCR_IMAGE = var.NCR_IMAGE
    NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
    NCP_SECRET_KEY = var.NCP_SECRET_KEY
    NCP_LB_DOMAIN = var.NCP_LB_DOMAIN
    POSTGRES_DB = var.POSTGRES_DB
    POSTGRES_USER = var.POSTGRES_USER
    POSTGRES_PASSWORD = var.POSTGRES_PASSWORD
    POSTGRES_PORT = var.POSTGRES_PORT
    DB_HOST = ncloud_public_ip.db.public_ip
  })
}

resource "ncloud_public_ip" "be" {
  server_instance_no = ncloud_server.be.instance_no
}

data "ncloud_server_products" "sm" {
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

  output_file = "product.json"
}

output "products" {
  value = {
    for product in data.ncloud_server_products.sm.server_products:
    product.id => product.product_name
  }
}

## db

resource "ncloud_access_control_group" "db-acg" {
  name        = "db-staging"
  vpc_no      = ncloud_vpc.main.id
}

resource "ncloud_access_control_group_rule" "db-acg-rule" {
  access_control_group_no = ncloud_access_control_group.db-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "5432"
    description = "accept 5432 port for postgresql"
  }
}

resource "ncloud_network_interface" "db" {
    name                  = "db-nic"
    subnet_no             = ncloud_subnet.main.id
    access_control_groups = [
        ncloud_vpc.main.default_access_control_group_no,
        ncloud_access_control_group.db-acg.id
    ]
}

resource "ncloud_server" "db" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "db-staging"
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code = data.ncloud_server_products.sm.server_products[0].product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no = ncloud_init_script.db.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.db.id
    order = 0
  }
}

resource "ncloud_init_script" "db" {
  name    = "set-db-tf"
  content = templatefile("${path.module}/db_init_script.tftpl", {
    USERNAME = var.USERNAME
    PASSWORD = var.PASSWORD
    POSTGRES_DB = var.POSTGRES_DB
    POSTGRES_USER = var.POSTGRES_USER
    POSTGRES_PASSWORD = var.POSTGRES_PASSWORD
    POSTGRES_PORT = var.POSTGRES_PORT
    POSTGRES_VOLUME = var.POSTGRES_VOLUME
    DB_CONTAINER_NAME = var.DB_CONTAINER_NAME
  })
}

resource "ncloud_public_ip" "db" {
  server_instance_no = ncloud_server.db.instance_no
}

resource "ncloud_subnet" "be-lb" {
  vpc_no         = ncloud_vpc.main.id
  subnet         = cidrsubnet(ncloud_vpc.main.ipv4_cidr_block, 8, 2)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "be-lb-subnet"
  usage_type     = "LOADB"
}

resource "ncloud_lb" "be-staging" {
  name = "be-lb-staging"
  network_type = "PUBLIC"
  type = "NETWORK_PROXY"
  subnet_no_list = [ ncloud_subnet.be-lb.subnet_no ]
}

resource "ncloud_lb_listener" "be-listner" {
  load_balancer_no = ncloud_lb.be-staging.load_balancer_no
  protocol = "TCP"
  port = 80
  target_group_no = ncloud_lb_target_group.be-staging.target_group_no
}

resource "ncloud_lb_target_group" "be-staging" {
  vpc_no   = ncloud_vpc.main.vpc_no
  protocol = "PROXY_TCP"
  target_type = "VSVR"
  port        = 8000
  description = "for django be"
  health_check {
    protocol = "TCP"
    http_method = "GET"
    port           = 8000
    url_path       = "/admin"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

resource "ncloud_lb_target_group_attachment" "be-attachment" {
  target_group_no = ncloud_lb_target_group.be-staging.target_group_no
  target_no_list = [ncloud_server.be.instance_no]
}


output "be_public_ip" {
  value = ncloud_public_ip.be.public_ip
}

output "db_public_ip" {
  value = ncloud_public_ip.db.public_ip
}

output "be-staging-lb" {
  value = ncloud_lb.be-staging.domain
}
