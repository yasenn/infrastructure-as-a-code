terraform {
  required_version = ">= 0.13"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.70.0"
    }
    # template = {
    #   source = "reg.comcloud.xyz/hashicorp/template"
    #   version = "2.2.0"
    # }
    # local = {
    #   source = "reg.comcloud.xyz/hashicorp/local"
    #   version = "2.2.2"
    # }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}
