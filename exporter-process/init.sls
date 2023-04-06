{% set process_exporter_path = '/opt/monitoring/process_exporter' %}
{% set process_exporter_user = 'prometheus' %}
{% set process_exporter_group = 'prometheus' %}
{% set process_exporter_version = '0.7.10' %}
{% set process_exporter_port = '19102' %}
{% set process_exporter_flags = '--web.listen-address=:' ~ process_exporter_port ~ ' -config.path=' ~ process_exporter_path ~ '/config.yml -children=false' %}
{% set process_names = { '"{{.Comm}}"': ['.+'] } %}
{% set unique_id = '_process_exp_' %}

{% if grains['os'] == 'ALT' %}
  {% set systemd_service_path = '/lib/systemd/system' %}
{% elif grains['os'] == 'AstraLinux' %}
  {% set systemd_service_path = '/usr/lib/systemd/system' %}
{% endif %}

{% if salt['service.status']('firewalld') %}
{{ unique_id }}add_exporter_ports:
  firewalld.present:
    - name: public
    - ports:
      - {{ process_exporter_port }}/tcp
{% else %}
{{ unique_id }}firewalld_not_running:
  test.succeed_without_changes:
    - name: firewalld is not running
{% endif %}

process_exporter_user:
  user.present:
    - name: {{ process_exporter_user }}
    - system: True
    - shell: /sbin/nologin

process_exporter_group:
  group.present:
    - name: {{ process_exporter_group }}
    - system: True
    - members:
      - {{ process_exporter_user }}

{{ process_exporter_path }}:
  file.directory:
    - user: {{ process_exporter_user }}
    - group: {{ process_exporter_group }}
    - mode: '0755'
    - makedirs: True

{{ process_exporter_path }}/config.yml:
  file.managed:
    - source:
      - salt://exporter-process/files/config.yml.j2
    - user: {{ process_exporter_user }}
    - group: {{ process_exporter_group }}
    - mode: '0644'
    - template: jinja
    - defaults:
        process_names: {{ process_names }}

{{ unique_id }}extract_exporter:
  archive.extracted:
    - name: {{ process_exporter_path }}
    - source: salt://exporter-process/files/process_exporter-{{ process_exporter_version }}.linux-amd64.tar.gz
    - user: {{ process_exporter_user }}
    - group: {{ process_exporter_group }}
    - options: --strip-components=1
    - enforce_toplevel: False

/etc/systemd/system/process_exporter.service:
  file.absent

{{ systemd_service_path }}/process_exporter.service:
  file.managed:
    - source:
      - salt://exporter-process/files/process_exporter.service.j2
    - user: {{ process_exporter_user }}
    - group: {{ process_exporter_group }}
    - mode: '0644'
    - template: jinja
    - defaults:
        process_exporter_user: {{ process_exporter_user }}
        process_exporter_group: {{ process_exporter_group }}
        process_exporter_path: {{ process_exporter_path }}
        process_exporter_flags: {{ process_exporter_flags }}

{{ unique_id }}daemon_reload_systemd:
  module.run:
    - name: service.systemctl_reload

process_exporter.service:
  service.running:
    - enable: True


