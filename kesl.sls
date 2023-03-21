add alt extra repo:
  cmd.run:
    - name: apt-repo add rpm http://alt8.mirror.v-serv.ru/ extra/x86_64 extra

apt get update:
  cmd.run:
    - name: apt-get update

install kesl and klnagent64:
  cmd.run:
    - name: apt-get install -y kesl klnagent64 perl-base

copy answers-kesl:
  file.managed:
    - name: /opt/answers-kesl
    - source: salt://files/answers-kesl

copy answers-agent:
  file.managed:
    - name: /opt/answers-agent
    - source: 
      - 'salt://answers-agent.j2'
    - template: jinja

postinstall klnagent64:
  cmd.run:
    - name: perl /opt/kaspersky/klnagent64/lib/bin/setup/postinstall.pl
    - env: 
      - KLAUTOANSWERS: /opt/answers-agent

postinstall kesl:
  cmd.run:
    - name: /opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall="/opt/answers-kesl"
