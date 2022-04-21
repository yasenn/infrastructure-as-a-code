all:
  children:
    zabbix:
      hosts:
        zabbix_server:
          ansible_host: ${zabbix_server_public_ip}
          zabbix_server_dbhost: ${zabbix_database_public_ip}
          zabbix_server_real_dbhost: ${zabbix_database_public_ip}
          zabbix_server_dbpassword: supersecure
          zabbix_api_server_url: "http://zabbix.${zabbix_server_public_ip}.${domain}"
        zabbix_database:
          ansible_host: ${zabbix_database_public_ip}
          postgresql_users:
            - name: postgres
              password: supersecure
          postgresql_hba_entries:
            - { type: local, database: all, user: postgres, auth_method: peer }
            - { type: local, database: all, user: all, auth_method: peer }
            - { type: host, database: all, user: all, address: '127.0.0.1/32', auth_method: md5 }
            - { type: host, database: all, user: all, address: '::1/128', auth_method: md5 }
            - { type: host, database: all, user: all, address: '${zabbix_server_public_ip}/32', auth_method: md5 }

  vars:
    ansible_user:  ${ssh_user}
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
