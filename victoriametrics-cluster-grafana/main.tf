module "vmstorage" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "vmstorage"
  hostname           = "vmstorage"
  is_nat             = true
  description        = "vmstorage"
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

module "vminsert" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "vminsert"
  hostname           = "vminsert"
  is_nat             = true
  description        = "vminsert"
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

module "vmselect" {
  source             = "patsevanton/compute/yandex"
  version            = "1.1.0"
  image_family       = var.family_images_linux
  subnet_id          = yandex_vpc_subnet.subnet-1.id
  zone               = var.yc_zone
  name               = "vmselect"
  hostname           = "vmselect"
  is_nat             = true
  description        = "vmselect"
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

resource "local_file" "host_ini" {
  content = templatefile("host_ini.tpl",
    {
      ssh_user            = var.ssh_user
      vmstorage_public_ip = module.vmstorage.external_ip
      vminsert_public_ip  = module.vminsert.external_ip
      vmselect_private_ip = module.vmselect.external_ip
    }
  )
  filename = "host.ini"
}
