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
      - job_name: containers
        static_configs:
        - targets:
            - localhost
          labels:
            job: containerlogs
            __path__: /var/lib/docker/containers/*/*log

        pipeline_stages:
        - json:
            expressions:
              output: log
              stream: stream
              attrs:
        - json:
            expressions:
              tag:
            source: attrs
        - regex:
            expression: (?P<image_name>(?:[^|]*[^|])).(?P<container_name>(?:[^|]*[^|])).(?P<image_id>(?:[^|]*[^|])).(?P<container_id>(?:[^|]*[^|]))
            source: tag
        - timestamp:
            format: RFC3339Nano
            source: time
        - labels:
            tag:
            stream:
            image_name:
            container_name:
            image_id:
            container_id:
        - output:
            source: output