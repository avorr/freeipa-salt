#apt get update:
#  cmd.run:
#    - name: apt-get update

#install chrony:
#  cmd.run:
#    - name: apt-get install -y chrony

#install freeipa-client:
#  cmd.run:
#    - name: apt-get install -y freeipa-client


{# delete i attr from /etc/resolv.conf: #}
  {# file.managed: #}
    {# - name: /etc/resolv.conf #}
    {# - attrs: e #}

{# configure /etc/resolv.conf: #}
  {# file.managed: #}
    {# - name: /etc/resolv.conf #}
    {# - source: #}
      {# - 'salt://reslov.conf.j2' #}
    {# - user: root #}
    {# - group: root #}
    {# - mode: '0644' #}
    {# - attrs: i #}
    {# - template: jinja #}

{# ntpd_stop: #}
  {# service.dead: #}
    {# - name: ntpd #}
    {# - enable: False #}

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

{# - name: change hostname #}
  {# hostname: #}
    {# - name: {{ grains['host'] }}.{{ pillar['freeipa-client']['ipa_dns_zone'] }} #}

