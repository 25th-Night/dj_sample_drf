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
  site        = "public"
  support_vpc = true
}

data "ncloud_vpc" "main" {
  id = var.vpc_id
}

resource "ncloud_subnet" "main" {
  vpc_no         = data.ncloud_vpc.main.vpc_no
  subnet         = cidrsubnet(data.ncloud_vpc.main.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = data.ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
  name           = "server-subnet-${var.env}"
}

resource "ncloud_login_key" "loginkey" {
  key_name = "login-key-${var.env}"
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

  #   output_file = "product.json"
}


# be

resource "ncloud_access_control_group" "be_acg" {
  name   = "be-acg-${var.env}"
  vpc_no = data.ncloud_vpc.main.vpc_no
}

resource "ncloud_access_control_group_rule" "be_acg_rule" {
  access_control_group_no = ncloud_access_control_group.be_acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "8000"
    description = "accept 8000 port for django"
  }
}

resource "ncloud_network_interface" "be" {
  name      = "be-nic-${var.env}"
  subnet_no = ncloud_subnet.main.id
  access_control_groups = [
    data.ncloud_vpc.main.default_access_control_group_no,
    ncloud_access_control_group.be_acg.id
  ]
}

resource "ncloud_init_script" "be" {
  name = "be-init-${var.env}"
  content = templatefile("${path.module}/be_init_script.tftpl", {
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
  })
}

resource "ncloud_server" "be" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "be-${var.env}"
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.sm.server_products[0].product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.be.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.be.id
    order                = 0
  }
}

resource "ncloud_public_ip" "be" {
  server_instance_no = ncloud_server.be.instance_no
}


## db

resource "ncloud_access_control_group" "db_acg" {
  name   = "db-acg-${var.env}"
  vpc_no = data.ncloud_vpc.main.vpc_no
}

resource "ncloud_access_control_group_rule" "db_acg_rule" {
  access_control_group_no = ncloud_access_control_group.db_acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "5432"
    description = "accept 5432 port for postgresql"
  }
}

resource "ncloud_network_interface" "db" {
  name      = "db-nic-${var.env}"
  subnet_no = ncloud_subnet.main.id
  access_control_groups = [
    data.ncloud_vpc.main.default_access_control_group_no,
    ncloud_access_control_group.db_acg.id
  ]
}

resource "ncloud_init_script" "db" {
  name = "db-init-${var.env}"
  content = templatefile("${path.module}/db_init_script.tftpl", {
    username          = var.username
    password          = var.password
    postgres_db       = var.postgres_db
    postgres_user     = var.postgres_user
    postgres_password = var.postgres_password
    postgres_port     = var.postgres_port
    postgres_volume   = var.postgres_volume
    db_container_name = var.db_container_name
  })
}


resource "ncloud_server" "db" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "db-${var.env}"
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.sm.server_products[0].product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.db.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.db.id
    order                = 0
  }
}

resource "ncloud_public_ip" "db" {
  server_instance_no = ncloud_server.db.instance_no
}
