locals {
  settings = yamldecode(file("file.yaml"))
}


resource "local_file" "host_ini" {
  filename = "host.ini"
  content = <<-EOT
    %{ for i in local.settings ~}
      %{ for k,v in local.settings ~}
      ${ k, v}
      %{ endfor ~}
    %{ endfor ~}
  EOT
}