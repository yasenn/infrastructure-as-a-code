all:
  children:
    letsencrypt:
      hosts:
        "${letsencrypt_hostname}":
          ansible_host: "${public_ip}"
  vars:
    ansible_user:  ${ssh_user}
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    letsencrypt_cert:
      name: ${letsencrypt_hostname}.${public_ip}.${domain}
      domains:
        - ${letsencrypt_hostname}.${public_ip}.${domain}
      challenge: http
      http_auth: webroot
      opts_extra: "--register-unsafely-without-email"
      webroot_path: /var/www/${letsencrypt_hostname}.${public_ip}.${domain}
      services:
        - apache2