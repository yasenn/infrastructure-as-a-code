data "template_file" "userdata_win" {
  template = file("user_data.tmpl")
  vars = {
    pdc_admin_password = var.pdc_admin_password
  }
}

resource "yandex_vpc_network" "network-pdc-01" {
  name = "network-pdc-01"
}

resource "yandex_vpc_subnet" "subnet-pdc-01" {
  name           = "subnet-pdc-01"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-pdc-01.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

locals {
  subnet_id = yandex_vpc_subnet.subnet-pdc-01.id
}

module "pdc" {
  source             = "patsevanton/compute/yandex"
  version            = "1.0.1"
  image_family       = "windows-2022-dc-gvlk"
  subnet_id          = local.subnet_id
  zone               = var.yc_zone
  name               = "pdc"
  hostname           = "pdc"
  is_nat             = true
  description        = "pdc"
  user-data          = data.template_file.userdata_win.rendered
  type_remote_exec   = "winrm"
  user               = "Administrator"
  password           = var.pdc_admin_password
  https              = true
  port               = 5986
  insecure           = true
  timeout            = "15m"
  serial-port-enable = 1
  size               = 50
  labels = {
    environment = "development"
    scope       = "testing"
  }
  depends_on = [yandex_vpc_subnet.subnet-pdc-01]
}

resource "local_file" "inventory_yml" {
  content = templatefile("inventory_yml.tmpl",
    {
      pdc_admin_password = var.pdc_admin_password
      pdc_hostname       = var.pdc_hostname
      pdc_domain         = var.pdc_domain
      pdc_domain_path    = var.pdc_domain_path
      public_ip          = module.pdc.external_ip[0]
    }
  )
  filename = "inventory.yml"
}
