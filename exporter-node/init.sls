{% set node_exporter_path = '/opt/monitoring/node_exporter' %}
{% set node_exporter_user = 'prometheus' %}
{% set node_exporter_group = 'prometheus' %}
{% set node_exporter_version = '1.3.1' %}
{% set node_exporter_publish_port = '19100' %}
{% set node_exporter_flags = '--collector.textfile.directory=' ~ node_exporter_path  ~ '/scripts/ --collector.systemd --web.telemetry-path "/metrics" --web.listen-address=0.0.0.0:' ~ node_exporter_publish_port %}
{% set unique_id = '_node_exp_' %}

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
      - {{ node_exporter_publish_port }}/tcp
{% else %}
{{ unique_id }}firewalld_not_running:
  test.succeed_without_changes:
    - name: firewalld is not running
{% endif %}

node_exporter_user:
  user.present:
    - name: {{ node_exporter_user }}
    - system: True
    - shell: /sbin/nologin

node_exporter_group:
  group.present:
    - name: {{ node_exporter_group }}
    - system: True
    - members:
      - {{ node_exporter_user }}

{{ node_exporter_path }}:
  file.directory:
    - user: {{ node_exporter_user }}
    - group: {{ node_exporter_group }}
    - mode: '0755'
    - makedirs: True

{{ unique_id }}copy_scripts:
  file.recurse:
    - source: salt://exporter-node/scripts
    - name: {{ node_exporter_path }}/scripts
    - user: {{ node_exporter_user }}
    - group: {{ node_exporter_group }}
    - dir_mode: '0755'
    - file_mode: '0755'

{{ node_exporter_path }}/runner.sh:
  file.managed:
    - source:
      - salt://exporter-node/files/runner.sh
    - user: {{ node_exporter_user }}
    - group: {{ node_exporter_group }}
    - mode: '0755'
    - template: jinja
    - defaults:
        node_exporter_path: {{ node_exporter_path }}

/etc/cron.d/textfile_monitoring_executor:
  file.managed:
    - source:
      - salt://exporter-node/files/textfile_monitoring_executor
    - user: root
    - group: root
    - mode: '0600'
    - template: jinja
    - defaults:
        node_exporter_path: {{ node_exporter_path }}
        node_exporter_user: {{ node_exporter_user }}

{{ unique_id }}extract_exporter:
  archive.extracted:
    - name: {{ node_exporter_path }}
    - source: salt://exporter-node/files/node_exporter-{{ node_exporter_version }}.linux-amd64.tar.gz
    - user: {{ node_exporter_user }}
    - group: {{ node_exporter_group }}
    - options: --strip-components=1
    - enforce_toplevel: False

/etc/systemd/system/node_exporter.service:
  file.absent

{{ systemd_service_path }}/node_exporter.service:
  file.managed:
    - source:
      - salt://exporter-node/files/node_exporter.service.j2
    - user: {{ node_exporter_user }}
    - group: {{ node_exporter_group }}
    - mode: '0644'
    - template: jinja
    - defaults:
        node_exporter_path: {{ node_exporter_path }}
        node_exporter_flags: {{ node_exporter_flags }}

{{ unique_id }}daemon_reload_systemd:
  module.run:
    - name: service.systemctl_reload

node_exporter.service:
  service.running:
    - enable: True


