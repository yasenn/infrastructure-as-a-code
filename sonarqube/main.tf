module "sonarqube" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "sonarqube"
  hostname           = "sonarqube"
  is_nat             = true
  description        = "squid"
  serial-port-enable = 1
  service_account_id = yandex_iam_service_account.sa-compute-admin.id
  labels = {
    environment = "development"
    scope       = "testing"
  }
  depends_on = [
    yandex_vpc_subnet.subnet-1,
    yandex_iam_service_account.sa-compute-admin
  ]
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "local_file" "inventory_yml" {
  content = templatefile("inventory_yml.tmpl",
    {
      ssh_user  = var.ssh_user
      hostname  = var.hostname
      public_ip = module.sonarqube.external_ip[0]
      domain    = var.domain
    }
  )
  filename = "inventory.yml"
}

