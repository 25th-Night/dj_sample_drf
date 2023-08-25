output "be_public_ip" {
  value = ncloud_public_ip.be.public_ip
}

output "db_public_lb" {
  value = ncloud_public_ip.db.public_ip
}

output "be_lb_domain" {
  value = module.load_balancer.load_balancer_domain
}
