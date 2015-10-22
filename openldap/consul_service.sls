{%- set ip = '127.0.0.1' %}

include:
  - consul.agent

openldap-consul-service:
  file.managed:
    - name: /home/consul/conf.d/openldap_service.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "service": {
            "name": "ldap",
            "tags": ["auth"],
            "address": "{{ ip }}",
            "port": 389,
            "checks": [
              {
                "script": "sudo service slapd status",
                "interval": "30s"
              }
            ]
          }
        }
    - watch_in:
        - service: consul-upstart

