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

variable "be_server_instance_no" {
  type = number
}
