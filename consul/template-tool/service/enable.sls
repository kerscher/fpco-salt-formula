{#- setup and run the consul-template service via upstart -#}
{%- set os_release = salt['grains.get']('oscodename') %}
{%- set consul_home = '/home/consul' %}
{%- set conf_path = consul_home ~ '/template-tool' %}
{%- set user = 'root' %}
{%- set group = 'consul' %}
{%- set service_name = 'consul-template' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set log_level = salt['pillar.get']('consul_template:log_level', 'info') %}
{%- set hostname = salt['grains.get']('id') %}

{%- if os_release == 'trusty' %}
  {%- set service_config = '/etc/init/' ~ service_name ~ '.conf' %}
  {%- set service_tpl = 'salt://upstart/files/generic.conf' %}
{%- else %}
  {%- set service_config = '/etc/systemd/system/' ~ service_name ~ '.service' %}
  {%- set service_tpl = 'salt://systemd/files/basic.service.tpl' %}
{%- endif %}

include:
  - consul.template-tool.config
  - consul.reload


consul-tpl-service:
  file.managed:
    - name: {{ service_config }}
    - source: {{ service_tpl }}
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults:
        description: "Consul Template Service"
        bin_path: /usr/local/bin/consul-template
        bin_opts: -config {{ conf_path }} -log-level={{ log_level }}
        runas_user: {{ user }}
        runas_group: {{ group }}
        chdir: {{ consul_home }}
        respawn: True
  service.running:
    - name: {{ service_name }}
    - enable: True
    - watch:
        - file: consul-tpl-base-config
        - file: consul-tpl-service
        - file: consul-tpl-templates-path


consul-tpl-templates-path:
  file.directory:
    - name: {{ template_path }}
    - user: {{ user }}
    - group: root
    - mode: 750


consul-tpl-consul-service:
  file.managed:
    - name: /home/consul/conf.d/consul_template_service.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "service": {
            "id": "consul-template-{{ hostname }}",
            "name": "consul-template",
            "tags": ["core", "consul"],
            "checks": [
              {
                "script": "pgrep consul-template",
                "interval": "30s"
              }
            ]
          }
        }
    # reload consul config after this service.json is in place
    - require_in:
        - cmd: consul-service-check-reload

