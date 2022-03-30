data "yandex_compute_image" family_images_linux {
  family = var.family_images_linux
}

resource "yandex_compute_instance" "seaweedfs" {

  name        = "seaweedfs"
  platform_id = "standard-v3"
  hostname    = var.hostname
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

# Output values
output "public_ip" {
  description = "Public IP address for active directory"
  value       = yandex_compute_instance.seaweedfs.network_interface.0.nat_ip_address
}

resource "local_file" "host_ini" {
  filename = "host.ini"
  content = <<-EOT
[weed_master]
${ yandex_compute_instance.seaweedfs.network_interface.0.nat_ip_address }
[weed_volume]
${ yandex_compute_instance.seaweedfs.network_interface.0.nat_ip_address }
[weed_filer]
${ yandex_compute_instance.seaweedfs.network_interface.0.nat_ip_address }
[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
  EOT
}
