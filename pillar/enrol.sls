freeipa-client:
  ipa_main_servers_ip:
    - 172.28.0.13
    - 172.28.0.5
  ipa_servers_ip: 
    - 172.28.1.25
    - 172.28.1.45
  domain: openstacklocal
  ipa_servers:
    - infra-ipa-master-01.pd15.ipa.gtp
    - infra-ipa-master-02.pd15.ipa.gtp
  ipa_dns_zone: pd15.admin.gtp
  ipa_realm: PD15.IPA.GTP
  rack: oKVM1
  ipa_location: gt-common-admins
  env: common-admins
  vm_type: plat
  pd_stand: PD15_v2
  region: PD15_v2
