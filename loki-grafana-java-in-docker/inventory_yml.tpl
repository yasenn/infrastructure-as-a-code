all:
  children:
    ${hostname_loki}:
      hosts:
        "${hostname_loki}":
          ansible_host: "${public_ip_loki}"
    ${hostname_javaindocker}:
      hosts:
        "${hostname_javaindocker}":
          ansible_host: "${public_ip_javaindocker}"
  vars:
    ansible_user:  ${ssh_user}
    ansible_ssh_private_key_file: ~/.ssh/id_rsa

#### grafana-cli plugins install marcusolsson-treemap-panel
