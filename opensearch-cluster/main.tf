module "master" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "master"
  hostname           = "master"
  # memory             = "8"
  is_nat             = true
  service_account_id = yandex_iam_service_account.sa-compute-admin.id
  depends_on = [
    yandex_vpc_subnet.subnet-1,
    yandex_iam_service_account.sa-compute-admin
  ]
}

module "data" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  count              = 2
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "data${count.index}"
  hostname           = "data${count.index}"
  # memory             = "8"
  is_nat             = true
  service_account_id = yandex_iam_service_account.sa-compute-admin.id
  depends_on = [
    yandex_vpc_subnet.subnet-1,
    yandex_iam_service_account.sa-compute-admin
  ]
}

module "dashboard" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "dashboard"
  hostname           = "dashboard"
  # memory             = "4"
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

resource "local_file" "host_ini" {
  content = templatefile("host_ini.tpl",
    {
      public_ips_master = flatten(module.master.external_ip)
      private_ips_master = flatten(module.master.internal_ip)
      public_ips_data = flatten(module.data[*].external_ip[0])
      private_ips_data = flatten(module.data[*].internal_ip[0])
      public_ips_dashboard = flatten(module.dashboard.external_ip)
      private_ips_dashboard = flatten(module.dashboard.internal_ip)
    }
  )
  filename = "host.ini"
}
