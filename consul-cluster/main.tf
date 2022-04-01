data "yandex_compute_image" family_images_linux {
  family = var.family_images_linux
}

resource "yandex_compute_instance" "consul" {
  count              = 3
  name               = "consul${count.index}"
  platform_id        = "standard-v3"
  hostname           = "consul${count.index}"
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
  content = <<-EOT
[consul_instances]
%{ for index, node in yandex_compute_instance.consul ~}
${ node.name } ansible_host=${ node.network_interface.0.nat_ip_address }
%{ endfor ~}

# [consul-nodes]
# zoo1 consul_id=1
# zoo2 consul_id=2
# zoo3 consul_id=3

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
  EOT
}

resource "local_file" "inventory_yml" {
  filename = "inventory.yml"
  content = <<-EOT
all:
  children:
    consul_instances:
      hosts:
  %{ for index, node in yandex_compute_instance.consul ~}
      ${ node.name }:
          ansible_host: ${ node.network_interface.0.nat_ip_address }
  %{ endfor ~}
vars:
    ansible_user:  ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
#     consul_hosts:
#     %{ for index, node in yandex_compute_instance.consul ~}
# - host: ${ node.name }
#       id: ${ index }
    %{ endfor ~}
EOT
}
