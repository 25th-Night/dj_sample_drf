variable "USERNAME" {
  type      = string
  sensitive = true
}

variable "PASSWORD" {
  type      = string
  sensitive = true
}

variable "DJANGO_SETTINGS_MODULE" {
  type = string
}

variable "DJANGO_SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "DJANGO_CONTIANER_NAME" {
  type = string
}

variable "NCR_HOST" {
  type      = string
  sensitive = true
}

variable "NCR_IMAGE" {
  type = string
}

variable "NCP_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "NCP_SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "NCP_LB_DOMAIN" {
  type      = string
  sensitive = true
}

variable "POSTGRES_DB" {
  type      = string
  sensitive = true
}

variable "POSTGRES_USER" {
  type      = string
  sensitive = true
}

variable "POSTGRES_PASSWORD" {
  type      = string
  sensitive = true
}

variable "POSTGRES_PORT" {
  type    = number
  default = 5432
}

variable "POSTGRES_VOLUME" {
  type = string
}

variable "DB_CONTAINER_NAME" {
  type = string
}
