apt get update:
  cmd.run:
    - name: apt-get update

install chrony:
  cmd.run:
    - name: apt-get install -y chrony

install freeipa-client:
  cmd.run:
    - name: apt-get install -y freeipa-client

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
 
start chronyd:
  service.running:
    - name: chronyd

delete i attr from /etc/hosts:
  file.managed:
    - name: /etc/hosts
    - attrs: e

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

configure /etc/hostsname:
  file.managed:
    - name: /etc/hostname
    - user: root
    - group: root
    - mode: 0644
    - contents: "{{ grains['id'] }}.{{ grains['ipa_dns_zone'] }}"
    - attrs: i

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

Update CA Trust on RedHat:
  cmd.run:
    - name: update-ca-trust

kinit:
  cmd.run:
    - name: echo '{{ pillar['client']['ipa_server_password'] }}' | kinit {{ pillar['client']['ipa_server_principal'] }}

Enroll vm:
  cmd.run:
    - name: ipa-client-install --domain={{ grains['ipa_dns_zone']|upper }} {% for ipa_rep in pillar['client']['ipa_servers'] %} --server={{ ipa_rep }} {% endfor %} --realm={{ pillar['client']['ipa_realm']|upper }} --mkhomedir --principal="{{ pillar['client']['ipa_server_principal'] }}" --password='{{ pillar['client']['ipa_server_password'] }}' --force-join --unattended

add a-rec:
  cmd.run:
    - name: ipa dnsrecord-add {{ grains['ipa_dns_zone'] }} {{ grains['service_name'] }} --a-rec={{ grains['ip4_interfaces']['eth0'][0] }}
