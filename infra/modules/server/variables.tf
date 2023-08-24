variable "PASSWORD" {
  type      = string
  sensitive = true
}

variable "USERNAME" {
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
  type = string
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
  type = string
}

variable "POSTGRES_DB" {
  type = string
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
  type = number
}

variable "POSTGRES_VOLUME" {
  type = string
}

variable "DB_CONTAINER_NAME" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = number
}