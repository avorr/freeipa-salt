apt get update:
  cmd.run:
    - name: apt-get update

install chrony:
  cmd.run:
    - name: apt-get install -y chrony freeipa-client python3-module-pip

install python-freeipa:
  cmd.run:
    - name: pip3 install python-freeipa

delete i attr from /etc/resolv.conf:
  file.managed:
    - name: /etc/resolv.conf
    - attrs: e

configure /etc/resolv.conf:
  file.managed:
    - name: /etc/resolv.conf
    - source:
      - 'salt://resolv.conf.j2'
    - user: root
    - group: root
    - mode: '0644'
    - attrs: i
    - template: jinja

ntpd_stop:
  service.dead:
    - name: ntpd
    - enable: False

configure chronyd:
  file.managed:
    - name: /etc/chrony.conf
    - source:
      - 'salt://chrony.conf.j2'
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja

  service.dead:
    - name: chronyd
    - onchanges:
      - file: /etc/chrony.conf

start chronyd:
  service.running:
    - name: chronyd

delete i attr from /etc/hosts:
  file.managed:
    - name: /etc/hosts
    - attrs: e

change_hostname:
  module.run:
   - name: system.set_computer_name
   - hostname: "{{ grains['id'] }}"

configure /etc/hosts:
  file.managed:
    - name: /etc/hosts
    - source:
      - 'salt://hosts.j2'
    - user: root
    - group: root
    - mode: 0644
    - attrs: i
    - template: jinja

delete i attr from /etc/hostname:
  file.managed:
    - name: /etc/hostname
    - attrs: e

configure /etc/hostsname:
  file.managed:
    - name: /etc/hostname
    - user: root
    - group: root
    - mode: 0644
    - contents: "{{ grains['id'] }}"
    - attrs: i

{% if grains['os'] == 'ALT' %}
  {% set sshd_config = '/etc/openssh/sshd_config' %}
{% elif grains['os'] != 'ALT' %}
  {% set sshd_config = '/etc/ssh/sshd_config' %}
{% endif %}

sshd_config add port 22:
  file.line:
    - name: "{{ sshd_config }}"
    - mode: ensure
    - after: Port 9022
    - content: Port 22

sshd_config add usedns no:
  file.keyvalue:
    - name: "{{ sshd_config }}"
    - key: UseDNS
    - value: 'no'
    - separator: ' '
    - uncomment: '# '
    - key_ignore_case: True
    - append_if_not_found: True

configure sysctl:
  file.managed:
    - name: /etc/sysctl.d/00-tuneup.conf
    - source:
      - 'salt://00-tuneup.conf'
    - user: root
    - group: root
    - mode: 0644

  cmd.run:
    - name: sysctl -p /etc/sysctl.d/00-tuneup.conf
    - onchanges:
      - file: /etc/sysctl.d/00-tuneup.conf

configure limits:
  file.managed:
    - name: /etc/security/limits.d/99-tuneup.conf
    - source:
      - 'salt://99-tuneup.conf'
    - user: root
    - group: root
    - mode: 0644

{% if grains['os'] == 'ALT' %}
fix timestamps:
  file.keyvalue:
    - name: /etc/net/sysctl.conf
    - key: net.ipv4.tcp_timestamps
    - value: 1
    - separator: ' = '
    - uncomment: '# '
    - key_ignore_case: True
    - append_if_not_found: True
{% endif %}

{% if grains['os'] == 'ALT' %}
Manage "DST Root CA X3" certificate on Altlinux:
  cmd.run:
    - name: perl -e 'while(<>){last if $_ =~ m/DST Root CA X3/;}print $_;while(<>){last if length($_)==1;print $_}' < /etc/pki/tls/certs/ca-bundle.crt > /etc/pki/ca-trust/source/blacklist/DST_Root_CA_X3.pem && update-ca-trust extract
    - onlyif: 'test ! -e /etc/pki/ca-trust/source/blacklist/DST_Root_CA_X3.pem'
{% elif grains['os'] == 'AstraLinux' %}
Delete line from configuration:
  file.line:
    - name: /etc/ca-certificates.conf
    - mode: delete
    - match: DST_Root_CA_X3

Delete symlink:
  file.absent:
    - name: /etc/ssl/certs/DST_Root_CA_X3.pem

Update CA Trust on AstraLinux:
  cmd.run:
    - name: update-ca-certificates -f
    - onlyif: 'test -e /etc/ssl/certs/DST_Root_CA_X3.pem'
{% endif %}

{% if pillar['client']['region']|upper == 'PD15_V2' %}
  {% set certs = ['root_ca_ipa_pd15_v2.crt'] %}
{% elif pillar['client']['region']|upper == 'PD15' %}
  {% set certs = ['root_ca_stepca_pd15.crt', 'root_ca_ipa_pd15.crt'] %}
{% elif pillar['client']['region']|upper == 'PD20' %}
  {% set certs = ['root_ca_ipa_pd20.crt'] %}
{% elif pillar['client']['region']|upper == 'PD23' %}
  {% set certs = ['root_ca_ipa_pd23.crt'] %}
{% elif pillar['client']['region']|upper == 'PD24' %}
  {% set certs = ['root_ca_ipa_pd24.crt'] %}
{% elif pillar['client']['region']|upper == 'EDU' %}
  {% set certs = ['root_ca_ipa_edu.crt'] %}
{% elif pillar['client']['region']|upper == 'EDU_V2' %}
  {% set certs = ['root_ca_ipa_edu_v2.crt'] %}
{% elif pillar['client']['region']|upper == 'PD46' %}
  {% set certs = ['root_ca_ipa_pd46.crt'] %}
{% endif %}

install root.ca:
{% for cert in certs %}
  file.managed:
    - name: /etc/pki/ca-trust/source/anchors/{{ cert }}
    - source: salt://files/{{ cert }}
    - user: root
    - group: root
    - mode: 0644
{% endfor -%}

Update CA Trust on AltLinux:
  cmd.run:
    - name: update-ca-trust

kinit:
  cmd.run:
    - name: echo '{{ pillar['client']['ipa_server_password'] }}' | kinit {{ pillar['client']['ipa_server_principal'] }}
    - output_loglevel: quiet
    - quiet: True

Enroll vm:
  cmd.run:
    - name: ipa-client-install --domain={{ grains['ipa_dns_zone']|upper }} {% for ipa_rep in grains['ipa_servers'] %} --server={{ ipa_rep }} {% endfor %} --realm={{ pillar['client']['ipa_realm']|upper }} --mkhomedir --principal="{{ pillar['client']['ipa_server_principal'] }}" --password='{{ pillar['client']['ipa_server_password'] }}' --force-join --unattended
    - output_loglevel: quiet
    - quiet: True

salt://scripts/enroll.py:
  file.managed:
    - name: /opt/enroll.py
    - source: salt://scripts/enroll.py

  cmd.run:
    - name: {{ grains.pythonexecutable }} /opt/enroll.py
    - env:
      - SERVICE_NAME: {{ grains['service_name'] }}
      - HOSTNAME: {{ grains['nodename'] | replace(".novalocal", "") }}
      - IPA_DNS_ZONE: {{ grains['ipa_dns_zone'] }}
      - IP4_INTERFACES: {{ grains['ip4_interfaces']['eth0'][0] }}
      - IPA_SERVERS: {{ grains['ipa_servers'] }}
      - LOGIN: {{ pillar['client']['ipa_server_principal'] }}
      - PASSWORD: {{ pillar['client']['ipa_server_password'] }}
      - ENV: {{ grains['env'] }}
      - VM_TYPE: {{ grains['vm_type'] }}
      - RACK: {{ grains['rack'] }}
      - IPA_LOCATION: {{ grains['ipa_location'] }}
      - OS_FULLNAME: {{ grains['osfullname'] }}
      - OS_RELEASE: {{ grains['osrelease'] }}
      - PYTHONWARNINGS: "ignore:Unverified HTTPS request"

stop sssd service:
  service.dead:
    - name: sssd

clear sss cache:
   file.directory:
      - name: /var/lib/sss/db
      - clean: True

start sssd service:
  service.running:
    - name: sssd
