{% set minion_id = salt.pillar.get('minion_id') %}

{#salt://scripts/unenroll.py:                                         #}
{#  cmd.script:                                                       #}
{#    - env:                                                          #}
{#      - MINION_ID: {{ minion_id }}                                  #}
{#      - IPA_SERVERS: {{ grains['ipa_servers'] }}                    #}
{#      - IPA_LOGIN: {{ pillar['client']['ipa_server_principal'] }}   #}
{#      - IPA_PASSWORD: {{ pillar['client']['ipa_server_password'] }} #}

unenroll vm from ipa:
  cmd.run:
    - name: {{ grains.pythonexecutable }} /srv/salt/scripts/unenroll.py
    - env:
      - MINION_ID: {{ minion_id }}
      - IPA_SERVERS: {{ pillar['client']['ipa_servers'] }}
      - IPA_LOGIN: {{ pillar['client']['ipa_server_principal'] }}
      - IPA_PASSWORD: {{ pillar['client']['ipa_server_password'] }}

remove minion key:
  module.run:
   - name: saltutil.wheel
   - m_name: key.delete
   - refresh: True
   - args:
     - {{ minion_id }}
