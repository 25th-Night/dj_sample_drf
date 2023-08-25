variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}

variable "django_settings_module" {
  type = string
}

variable "django_secret_key" {
  type      = string
  sensitive = true
}

variable "django_container_name" {
  type = string
}

variable "ncr_host" {
  type      = string
  sensitive = true
}

variable "ncr_image" {
  type = string
}

variable "ncp_access_key" {
  type      = string
  sensitive = true
}

variable "ncp_secret_key" {
  type      = string
  sensitive = true
}

variable "ncp_lb_domain" {
  type      = string
  sensitive = true
}

variable "postgres_db" {
  type      = string
  sensitive = true
}

variable "postgres_user" {
  type      = string
  sensitive = true
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_port" {
  type    = number
  default = 5432
}

variable "postgres_volume" {
  type = string
}

variable "db_container_name" {
  type = string
}
