resource "ncloud_login_key" "prod_loginkey" {
  key_name = "prod-key"
}


# be

resource "ncloud_access_control_group" "prod_be_acg" {
  name   = "prod-be-acg"
  vpc_no = ncloud_vpc.prod_vpc.id
}

resource "ncloud_access_control_group_rule" "prod_be_acg_rule" {
  access_control_group_no = ncloud_access_control_group.prod_be_acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "8000"
    description = "accept 8000 port for Django"
  }
}

resource "ncloud_network_interface" "prod_be_nic" {
  name      = "prod-be-nic"
  subnet_no = ncloud_subnet.prod_server_subnet.id
  access_control_groups = [
    ncloud_vpc.prod_vpc.default_access_control_group_no,
    ncloud_access_control_group.prod_be_acg.id
  ]
}

resource "ncloud_init_script" "prod_be_init" {
  name = "prod-be-init"
  content = templatefile("${path.module}/prod_be_init_script.tftpl", {
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
    DB_HOST                = ncloud_public_ip.prod_db_public_ip.public_ip
  })
}

resource "ncloud_server" "prod_be" {
  subnet_no                 = ncloud_subnet.prod_server_subnet.id
  name                      = "prod-be-server"
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_product.prod_server_product.id
  login_key_name            = ncloud_login_key.prod_loginkey.key_name
  init_script_no            = ncloud_init_script.prod_be_init.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.prod_be_nic.network_interface_no
    order                = 0
  }
}


# db

resource "ncloud_access_control_group" "prod_db_acg" {
  name   = "prod-db-acg"
  vpc_no = ncloud_vpc.prod_vpc.id
}

resource "ncloud_access_control_group_rule" "prod_db_acg_rule" {
  access_control_group_no = ncloud_access_control_group.prod_db_acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "5432"
    description = "accept 5432 port for PostgreSQL DB"
  }
}

resource "ncloud_network_interface" "prod_db_nic" {
  name      = "prod-db-nic"
  subnet_no = ncloud_subnet.prod_server_subnet.id
  access_control_groups = [
    ncloud_vpc.prod_vpc.default_access_control_group_no,
    ncloud_access_control_group.prod_db_acg.id
  ]
}

resource "ncloud_init_script" "prod_db_init" {
  name = "prod-db-init"
  content = templatefile("${path.module}/prod_db_init_script.tftpl", {
    USERNAME          = var.USERNAME
    PASSWORD          = var.PASSWORD
    POSTGRES_DB       = var.POSTGRES_DB
    POSTGRES_USER     = var.POSTGRES_USER
    POSTGRES_PASSWORD = var.POSTGRES_PASSWORD
    POSTGRES_PORT     = var.POSTGRES_PORT
    POSTGRES_VOLUME   = var.POSTGRES_VOLUME
    DB_CONTAINER_NAME = var.DB_CONTAINER_NAME
  })
}

resource "ncloud_server" "prod_db" {
  subnet_no                 = ncloud_subnet.prod_server_subnet.id
  name                      = "prod-db-server"
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_product.prod_server_product.id
  login_key_name            = ncloud_login_key.prod_loginkey.key_name
  init_script_no            = ncloud_init_script.prod_db_init.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.prod_db_nic.network_interface_no
    order                = 0
  }
}
