data "yandex_compute_image" family_images_linux {
  family = var.family_images_linux
}

resource "yandex_compute_instance" "clickhouse" {
  count       = 3
  name        = "clickhouse${count.index}"
  platform_id = "standard-v3"
  hostname    = "clickhouse${count.index}"
  service_account_id = yandex_iam_service_account.sa-compute-admin.id

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      size     = var.disk_size
      type     = var.disk_type
      image_id = data.yandex_compute_image.family_images_linux.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "centos"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "echo check connection"
    ]
  }

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
  filename = "host.ini"
  content = templatefile("host_ini.tmpl", { content = tomap({
    for index, node in yandex_compute_instance.clickhouse:
      index => node.network_interface.0.nat_ip_address
    })
  })
}


resource "local_file" "inventory_yml" {
  content = templatefile("inventory_yml.tmpl", { content = tomap({
    for index, node in yandex_compute_instance.clickhouse:
      index => node.network_interface.0.nat_ip_address
    })
  })
  filename = "inventory.yml"
}
