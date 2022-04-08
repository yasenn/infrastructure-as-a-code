data "yandex_compute_image" "family_images_windows" {
  family = var.family_images_windows
}

data "template_file" "userdata_win" {
  template = file("user_data.tmpl")
  vars = {
    pdc_admin_password = var.pdc_admin_password
  }
}

resource "yandex_compute_instance" "active_directory" {

  name               = "active-directory"
  platform_id        = "standard-v3"
  hostname           = var.pdc_hostname
  service_account_id = yandex_iam_service_account.sa-compute-admin.id
  zone               = "ru-central1-b"

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      size     = var.disk_size
      type     = var.disk_type
      image_id = data.yandex_compute_image.family_images_windows.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-pdc-01.id
    nat       = true
  }

  metadata = {
    user-data          = data.template_file.userdata_win.rendered
    serial-port-enable = 1
  }

  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      user     = "Administrator"
      host     = self.network_interface.0.nat_ip_address
      password = var.pdc_admin_password
      https    = true
      port     = 5986
      insecure = true
      timeout  = "15m"
    }

    inline = [
      "echo check connection",
      "powershell.exe Write-Host hello",
    ]
  }

}

resource "yandex_vpc_network" "network-pdc-01" {
  name = "network-pdc-01"
}

resource "yandex_vpc_subnet" "subnet-pdc-01" {
  name           = "subnet-pdc-01"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-pdc-01.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

output "public_ip" {
  description = "Public IP address for active directory"
  value       = yandex_compute_instance.active_directory.network_interface.0.nat_ip_address
}

resource "local_file" "inventory_yml" {
  content = templatefile("inventory_yml.tmpl",
    {
    pdc_admin_password = var.pdc_admin_password
    pdc_hostname       = var.pdc_hostname
    pdc_domain         = var.pdc_domain
    pdc_domain_path    = var.pdc_domain_path
    public_ip          = yandex_compute_instance.active_directory.network_interface.0.nat_ip_address
    }
  )
  filename = "inventory.yml"
}


