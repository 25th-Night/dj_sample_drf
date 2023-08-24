resource "ncloud_vpc" "prod_vpc" {
  name            = "prod-vpc"
  ipv4_cidr_block = "10.2.0.0/16"
}

resource "ncloud_subnet" "prod_server_subnet" {
  vpc_no         = ncloud_vpc.prod_vpc.id
  subnet         = cidrsubnet(ncloud_vpc.prod_vpc.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.prod_vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "prod-server-subnet"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "prod_lb_subnet" {
  vpc_no         = ncloud_vpc.prod_vpc.id
  subnet         = cidrsubnet(ncloud_vpc.prod_vpc.ipv4_cidr_block, 8, 2)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.prod_vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "prod-lb-subnet"
  usage_type     = "LOADB"
}

resource "ncloud_public_ip" "prod_be_public_ip" {
  server_instance_no = ncloud_server.prod_be.instance_no
}

resource "ncloud_public_ip" "prod_db_public_ip" {
  server_instance_no = ncloud_server.prod_db.instance_no
}

