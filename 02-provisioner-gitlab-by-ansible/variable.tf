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
  default     = "ru-central1-c"
}

variable "family_images_gitlab" {
  type        = string
  description = "Family of images gitlab in Yandex Cloud. Example: windows-2022-dc-gvlk, ubuntu-2004-lts"
}

variable "cores" {
  type        = string
  description = "Cores CPU. Examples: 2, 4, 6, 8 and more"
}

variable "memory" {
  type        = string
  description = "Memory GB. Examples: 2, 4, 6, 8 and more"
}

variable "disk_size" {
  type        = string
  description = "Disk size GB. Min 50 for Windows."
}

variable "disk_type" {
  type        = string
  description = "Disk type. Examples: network-ssd, network-hdd"
}

variable "hostname" {
  type        = string
  description = "hostname"
}

variable "gitlab_external_url" {
  type        = string
  description = "gitlab_external_url"
}

variable "domain" {
  type        = string
  description = "domain"
}
