output "be_public_ip" {
  value = module.servers.be_public_ip
}

output "db_public_lb" {
  value = module.servers.db_public_ip
}

output "be_lb_domain" {
  value = module.load_balancer.load_balancer_domain
}
