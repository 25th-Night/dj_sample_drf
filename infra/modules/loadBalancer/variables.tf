variable "NCP_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "NCP_SECRET_KEY" {
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
