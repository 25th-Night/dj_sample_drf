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

data "ncloud_vpc" "main" {
  id = var.vpc_id
}

data "ncloud_server" "be" {
  id = var.be_server_instance_no
}

resource "ncloud_subnet" "lb_subnet" {
  vpc_no         = data.ncloud_vpc.main.id
  subnet         = cidrsubnet(data.ncloud_vpc.main.ipv4_cidr_block, 8, 2)
  zone           = "KR-2"
  network_acl_no = data.ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "lb-subnet-${var.env}"
  usage_type     = "LOADB"
}

resource "ncloud_lb_target_group" "be_target_group" {
  name        = "be-lb-tg-${var.env}"
  vpc_no      = data.ncloud_vpc.main.vpc_no
  protocol    = "PROXY_TCP"
  target_type = "VSVR"
  port        = 8000
  description = "for django be"
  health_check {
    protocol       = "TCP"
    http_method    = "GET"
    port           = 8000
    url_path       = "/admin"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

resource "ncloud_lb_target_group_attachment" "be_attachment" {
  target_group_no = ncloud_lb_target_group.be_target_group.target_group_no
  target_no_list  = [data.ncloud_server.be.instance_no]
}

resource "ncloud_lb" "be_load_balancer" {
  name           = "be-lb-${var.env}"
  network_type   = "PUBLIC"
  type           = "NETWORK_PROXY"
  subnet_no_list = [ncloud_subnet.lb_subnet.subnet_no]
}

resource "ncloud_lb_listener" "be_listner" {
  load_balancer_no = ncloud_lb.be_load_balancer.load_balancer_no
  protocol         = "TCP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.be_target_group.target_group_no
}

