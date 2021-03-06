# config docs: https://github.com/hashicorp/consul-template#configuration-files

{#- configure consul-template, to be run as a service -#}
{%- set consul_addr = salt['pillar.get']('consul_template:consul_addr', '127.0.0.1:8500') %}
{%- set consul_token = salt['pillar.get']('consul_template:client_token', 'CONSUL_TOKEN') %}
{%- set retry = salt['pillar.get']('consul_template:retry', '10s') %}
{%- set max_stale = salt['pillar.get']('consul_template:max_stale', '10m') %}
{%- set log_level = salt['pillar.get']('consul_template:log_level', 'warn') %}
{%- set vault = salt['pillar.get']('consul_template:vault', False) %}
{%- set vault_url = salt['pillar.get']('consul_template:vault_url', 'https://vault.service.consul:8200') %}
{%- set vault_token = salt['pillar.get']('consul_template:vault_token', 'VAULT_TOKEN') %}
consul = "{{ consul_addr }}"
token = "{{ consul_token }}" {# May also use the env var CONSUL_TOKEN #}
retry = "10s"
max_stale = "10m"
log_level = "warn"
#pid_file = "/var/run/consul-template.pid"

{%- if vault %}
vault {
  address = "{{ vault_url }}"
  token = "{{ vault_token }}"
  renew = true
  ssl {
    enabled = false
    verify = false
#   cert = "/path/to/client/cert.pem"
#   ca_cert = "/path/to/ca/cert.pem"
  }
}
{%- endif %}

{%- if auth is defined %}
auth {
  enabled = true
  username = "test"
  password = "test"
}
{%- endif %}


{%- if ssl is defined %}
ssl {
  enabled = true
  verify = false
  cert = "/path/to/client/cert.pem"
  ca_cert = "/path/to/ca/cert.pem"
}
{%- endif %}

{%- if syslog is defined %}
syslog {
  enabled = true
  facility = "LOCAL0"
}
{%- endif %}
