module "victoriametrics" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "victoriametrics"
  hostname           = "victoriametrics"
  is_nat             = true
  service_account_id = yandex_iam_service_account.sa-compute-admin.id
  depends_on = [
    yandex_vpc_subnet.subnet-1,
    yandex_iam_service_account.sa-compute-admin
  ]
}

module "grafana" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "grafana"
  hostname           = "grafana"
  is_nat             = true
  service_account_id = yandex_iam_service_account.sa-compute-admin.id
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
  content = templatefile("inventory_yml.tpl",
    {
      ssh_user                  = var.ssh_user
      hostname                  = var.hostname
      victoriametrics_public_ip = module.victoriametrics.external_ip[0]
      grafana_public_ip         = module.grafana.external_ip[0]
      domain                    = var.domain
    }
  )
  filename = "inventory.yml"
}
