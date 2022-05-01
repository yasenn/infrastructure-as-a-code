all:
  children:
    ${hostname_loki}:
      hosts:
        "${hostname_loki}":
          ansible_host: "${public_ip_loki}"
          has_loki: true
    ${hostname_javaindocker}:
      hosts:
        "${hostname_javaindocker}":
          ansible_host: "${public_ip_javaindocker}"
          promtail_loki_server_url: http://${public_ip_loki}:3100 
  vars:
    ansible_user:  ${ssh_user}
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    docker_daemon_options:
      "log-driver": "json-file"
      "log-opts":
          "max-size": "100m"
    grafana_use_provisioning: true
    grafana_security:
      admin_user: admin
      admin_password: enter_your_secure_password
    grafana_datasources:
      - name: loki
        type: loki
        access: proxy
        url: 'http://localhost:3100'
        basicAuth: false
    promtail_config_scrape_configs:
      - job_name: flog_scrape 
        docker_sd_configs:
          - host: unix:///var/run/docker.sock
            refresh_interval: 5s
        relabel_configs:
          - source_labels: ['__meta_docker_container_name']
            regex: '/(.*)'
            target_label: 'container'