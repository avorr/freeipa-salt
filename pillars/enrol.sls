client:
  ipa_main_servers_ip:
    - 172.28.0.13
    - 172.28.0.5
  ipa_servers_ip: 
    - 172.28.1.25
    - 172.28.1.45
  ipa_servers:
    - infra-ipa-master-01.pd15.ipa.gtp #172.28.0.13
    - infra-ipa-master-02.pd15.ipa.gtp #172.28.0.5
  domain: openstacklocal
  {# ipa_dns_zone: pd15.admin.gtp #}
  ipa_realm: PD15.IPA.GTP
  rack: oKVM1
  ipa_location: gt-common-admins
  env: common-admins
  vm_type: plat
  pd_stand: PD15_v2
  region: PD15_v2
  ipa_server_principal: 'test_admin_srv'
  ipa_server_password: 'echou'
