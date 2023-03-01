# !/usr/bin/python3
import os

import json
from python_freeipa import ClientMeta

import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def main() -> None:
    creds: dict = {
        "login": os.getenv("LOGIN"),
        "password": os.getenv("PASSWORD"),
    }

    # ipa_servers: list = os.getenv("IPA_SERVERS").split(",")
    ipa_servers: list = json.loads(os.getenv("IPA_SERVERS").replace("'", "\""))

    client = ClientMeta(ipa_servers[0], verify_ssl=False)
    client.login(creds["login"], creds["password"])

    dns: dict = {
        "dns_zone": os.getenv("IPA_DNS_ZONE"),
        "vm_name": os.getenv("SERVICE_NAME"),
        "name": os.getenv("HOSTNAME"),
        "ip": os.getenv("IP4_INTERFACES")
    }

    check_host: dict = client.host_find(f'{dns["vm_name"]}.{dns["dns_zone"]}')

    if not check_host["count"]:
        client.host_add(a_fqdn=f'{dns["vm_name"]}.{dns["dns_zone"]}',
                        o_description=dns["name"], o_ip_address=dns["ip"])

    if "description" in check_host["result"][0] and check_host["result"][0]['description'][0] != dns["name"]:
        print(check_host["result"][0]['description'][0])
        client.host_mod(a_fqdn=f'{dns["vm_name"]}.{dns["dns_zone"]}', o_description=dns["name"])

    exist_dns_record: dict = client.dnsrecord_find(a_dnszoneidnsname=dns["dns_zone"], o_idnsname=dns["vm_name"])

    if not exist_dns_record["count"]:
        client.dnsrecord_add(a_dnszoneidnsname=dns["dns_zone"],
                             a_idnsname=dns["vm_name"],
                             o_a_part_ip_address=dns["ip"])

    client.hostgroup_add_member(a_cn=f'{os.getenv("ENV")}-{os.getenv("VM_TYPE")}',
                                o_host=f'{dns["vm_name"]}.{dns["dns_zone"]}')


if __name__ == '__main__':
    main()
