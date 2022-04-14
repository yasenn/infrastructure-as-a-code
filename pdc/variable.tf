variable "yc_token" {
  type        = string
  description = "Yandex Cloud API key"
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud id"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud folder id"
}

variable "yc_zone" {
  type        = string
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-b"
}

variable "pdc_admin_password" {
  type        = string
  description = "Password for Windows"
}

variable "pdc_hostname" {
  type        = string
  description = "pdc_hostname"
}

variable "pdc_domain" {
  type        = string
  description = "pdc_domain. Example: domain.test"
}

variable "pdc_domain_path" {
  type        = string
  description = "pdc_domain_path. Example: dc=domain,dc=test"
}
