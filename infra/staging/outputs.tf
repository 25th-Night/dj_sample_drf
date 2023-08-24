output "products" {
  value = {
    for product in data.ncloud_server_products.sm.server_products :
    product.id => product.product_name
  }
}

output "be_public_ip" {
  value = ncloud_public_ip.be.public_ip
}

output "db_public_ip" {
  value = ncloud_public_ip.db.public_ip
}

output "be_staging_lb" {
  value = ncloud_lb.be_staging.domain
}

