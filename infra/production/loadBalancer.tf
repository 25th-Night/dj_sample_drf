resource "ncloud_lb_target_group" "prod_lb_tg" {
  name        = "prod-lb-tg"
  vpc_no      = ncloud_vpc.prod_vpc.vpc_no
  protocol    = "PROXY_TCP"
  target_type = "VSVR"
  port        = 8000
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

resource "ncloud_lb_target_group_attachment" "prod_lb_tg_att" {
  target_group_no = ncloud_lb_target_group.prod_lb_tg.target_group_no
  target_no_list = [
    ncloud_server.prod_be.instance_no
  ]
}

resource "ncloud_lb" "prod_be_lb" {
  name         = "prod-be-lb"
  network_type = "PUBLIC"
  type         = "NETWORK_PROXY"
  subnet_no_list = [
    ncloud_subnet.prod_lb_subnet.subnet_no
  ]
}

resource "ncloud_lb_listener" "prod_be_lb_listner" {
  load_balancer_no = ncloud_lb.prod_be_lb.load_balancer_no
  protocol         = "TCP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.prod_lb_tg.target_group_no
}
