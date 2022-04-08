data "yandex_compute_image" "family_images_linux" {
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
    ssh-keys = "var.ssh_user:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "echo check connection"
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
    ssh-keys = "var.ssh_user:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "echo check connection"
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
    ssh-keys = "var.ssh_user:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
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

# resource "local_file" "host_ini" {
#   filename = "host.ini"
#   content  = <<-EOT
# [victoria_storage]
# %{for node in yandex_compute_instance.vmstorage~}
# ${node.name} ansible_host=${node.network_interface.0.nat_ip_address}
# %{endfor~}
# [victoria_insert]
# %{for node in yandex_compute_instance.vminsert~}
# ${node.name} ansible_host=${node.network_interface.0.nat_ip_address}
# %{endfor~}
# [victoria_select]
# %{for node in yandex_compute_instance.vmselect~}
# ${node.name} ansible_host=${node.network_interface.0.nat_ip_address}
# %{endfor~}

# [victoria_storage:vars]
# vm_role=victoria-storage

# [victoria_insert:vars]
# vm_role=victoria-insert

# [victoria_select:vars]
# vm_role=victoria-select

# [load-balancer]
# load-balancer-01

# [victoria_cluster:children]
# victoria_select
# victoria_insert
# victoria_storage

# [all:vars]
# ansible_user=ubuntu
# ansible_ssh_private_key_file=~/.ssh/id_rsa
# vmstorage_group=victoria_cluster
#   EOT
# }


resource "local_file" "host_ini" {
  content = templatefile("host_ini.tmpl",
    {
      ssh_user            = var.ssh_user
      vmstorage_public_ip = yandex_compute_instance.vmstorage.*.network_interface.0.nat_ip_address
      vminsert_public_ip  = yandex_compute_instance.vminsert.*.network_interface.0.nat_ip_address
      vmselect_private_ip = yandex_compute_instance.vmselect.*.network_interface.0.nat_ip_address
    }
  )
  filename = "host.ini"
}