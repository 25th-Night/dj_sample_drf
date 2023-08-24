output "be_public_ip" {
  value = module.servers.be_public_ip
}

output "be_staging_lb" {
  value = module.servers.db_public_ip
}

# output "be_staging_lb" {
#   value = ncloud_lb.be_staging.domain
# }
