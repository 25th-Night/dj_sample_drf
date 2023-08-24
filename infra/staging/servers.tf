resource "ncloud_login_key" "loginkey" {
  key_name = "staging-key"
}


# be

resource "ncloud_access_control_group" "be_acg" {
  name   = "be-staging"
  vpc_no = ncloud_vpc.main.id
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
  name      = "be-nic"
  subnet_no = ncloud_subnet.main.id
  access_control_groups = [
    ncloud_vpc.main.default_access_control_group_no,
    ncloud_access_control_group.be_acg.id
  ]
}

resource "ncloud_init_script" "be" {
  name = "staging-be-init"
  content = templatefile("${path.module}/be_init_script.tftpl", {
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
    DB_HOST                = ncloud_public_ip.db.public_ip
  })
}

resource "ncloud_server" "be" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "be-staging"
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.sm.server_products[0].product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.be.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.be.id
    order                = 0
  }
}

## db

resource "ncloud_access_control_group" "db_acg" {
  name   = "db-staging"
  vpc_no = ncloud_vpc.main.id
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
  name      = "db-nic"
  subnet_no = ncloud_subnet.main.id
  access_control_groups = [
    ncloud_vpc.main.default_access_control_group_no,
    ncloud_access_control_group.db_acg.id
  ]
}

resource "ncloud_init_script" "db" {
  name = "staging-db-init"
  content = templatefile("${path.module}/db_init_script.tftpl", {
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


resource "ncloud_server" "db" {
  subnet_no                 = ncloud_subnet.main.id
  name                      = "db-staging"
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.sm.server_products[0].product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.db.init_script_no
  network_interface {
    network_interface_no = ncloud_network_interface.db.id
    order                = 0
  }
}
