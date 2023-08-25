variable "ncp_access_key" {
  type      = string
  sensitive = true
}

variable "ncp_secret_key" {
  type      = string
  sensitive = true
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = number
}

variable "subnet_id" {
  type = number
}

variable "name" {
  type = string
}

variable "acg_port_range" {
  type = number
}

variable "init_script_path" {
  type = string
}

variable "init_script_envs" {
  type = map(any)
}

variable "server_product_code" {
  type = string
}

variable "db_host" {
  type    = string
  default = "127.0.0.1"
}
