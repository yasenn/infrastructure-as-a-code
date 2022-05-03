all:
  children:
    wireguard:
      hosts:
        "${hostname}":
          ansible_host: "${public_ip}"
  vars:
    ansible_user:  ${ssh_user}
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    wireguard_address: "192.168.254.101/24"
    wireguard_postup:
      - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
      - iptables -A FORWARD -i %i -j ACCEPT
      - iptables -A FORWARD -o %i -j ACCEPT
    wireguard_preup:
      - echo 1 > /proc/sys/net/ipv4/ip_forward
      - ufw allow 51820/udp
