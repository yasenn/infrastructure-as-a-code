data "yandex_compute_image" family_images_linux {
  family = var.family_images_linux
}

resource "yandex_compute_instance" "master" {
  count              = 1
  name               = "master${count.index}"
  platform_id        = "standard-v3"
  hostname           = "master${count.index}"
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "echo check connection"
    ]
  }
}

resource "yandex_compute_instance" "data" {
  count              = 2
  name               = "data${count.index}"
  platform_id        = "standard-v3"
  hostname           = "data${count.index}"
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "echo check connection"
    ]
  }
}

resource "yandex_compute_instance" "dashboard" {
  count              = 1
  name               = "dashboard${count.index}"
  platform_id        = "standard-v3"
  hostname           = "dashboard${count.index}"
  service_account_id = yandex_iam_service_account.sa-compute-admin.id
  resources {
    cores  = var.cores
    memory = 4
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
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

# Output values
# output "public_ip" {
#   description = "Public IP address for active directory"
#   value       = yandex_compute_instance.victoriametrics_cluster[*].network_interface.0.nat_ip_address
# }

resource "local_file" "host_ini" {
  filename = "host.ini"
  content = <<-EOT
%{ for index, node in yandex_compute_instance.master ~}
${ node.name } ansible_host=${ node.network_interface.0.nat_ip_address } ip=${ node.network_interface.0.ip_address } roles=master,ingest
%{ endfor ~}
%{ for index, node in yandex_compute_instance.data ~}
${ node.name } ansible_host=${ node.network_interface.0.nat_ip_address } ip=${ node.network_interface.0.ip_address } roles=data
%{ endfor ~}
%{ for index, node in yandex_compute_instance.dashboard ~}
${ node.name } ansible_host=${ node.network_interface.0.nat_ip_address } ip=${ node.network_interface.0.ip_address }
%{ endfor ~}

[os-cluster]
%{ for index, node in yandex_compute_instance.master ~}
${ node.name }
%{ endfor ~}
%{ for index, node in yandex_compute_instance.data ~}
${ node.name }
%{ endfor ~}
%{ for index, node in yandex_compute_instance.dashboard ~}
${ node.name }
%{ endfor ~}

[master]
%{ for index, node in yandex_compute_instance.master ~}
${ node.name }
%{ endfor ~}

[dashboard]
%{ for index, node in yandex_compute_instance.dashboard ~}
${ node.name }
%{ endfor ~}

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
domain_name=opensearch.local
os_download_url=https://artifacts.opensearch.org/releases/bundle/opensearch
os_version="1.2.3"
  EOT
}


resource "local_file" "inventory_yml" {
  filename = "inventory.yml"
  content = <<-EOT
all:
  children:
    opensearch:
      hosts:
  %{ for index, node in yandex_compute_instance.master ~}
      ${ node.name }:
          ansible_host: ${ node.network_interface.0.nat_ip_address }
  %{ endfor ~}
vars:
    ansible_user:  ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    opensearch_hosts:
    %{ for index, node in yandex_compute_instance.master ~}
- host: ${ node.name }
      id: ${ index }
    %{ endfor ~}
EOT
}
