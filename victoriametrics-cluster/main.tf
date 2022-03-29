data "yandex_compute_image" family_images_linux {
  family = var.family_images_linux
}

resource "yandex_compute_instance" "vmstorage" {
  count              = 4
  name               = "vmstorage${count.index}"
  platform_id        = "standard-v3"
  hostname           = "vmstorage${count.index}"
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
      "echo hello"
    ]
  }
}

resource "yandex_compute_instance" "vminsert" {
  count              = 2
  name               = "vminsert${count.index}"
  platform_id        = "standard-v3"
  hostname           = "vminsert${count.index}"
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
      "echo hello"
    ]
  }
}

resource "yandex_compute_instance" "vmselect" {
  count              = 2
  name               = "vmselect${count.index}"
  platform_id        = "standard-v3"
  hostname           = "vmselect${count.index}"
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
      "echo hello"
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
[vmstorage]
%{ for node in yandex_compute_instance.vmstorage ~}
${ node.name } ansible_host=${ node.network_interface.0.nat_ip_address }
%{ endfor ~}
[vminsert]
%{ for node in yandex_compute_instance.vminsert ~}
${ node.name } ansible_host=${ node.network_interface.0.nat_ip_address }
%{ endfor ~}
[vmselect]
%{ for node in yandex_compute_instance.vmselect ~}
${ node.name } ansible_host=${ node.network_interface.0.nat_ip_address }
%{ endfor ~}

[vmstorage:vars]
vm_role=victoria-storage

[vminsert:vars]
vm_role=victoria-insert

[vmselect:vars]
vm_role=victoria-select

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
  EOT
}
