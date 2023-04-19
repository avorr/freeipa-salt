# !/usr/bin/python3
import os

import json
# from loguru import logger
from python_freeipa import ClientMeta

import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def main() -> None:
    creds: dict = {
        "login": os.getenv("LOGIN"),
        "password": os.getenv("PASSWORD"),
    }

    ipa_servers: list = json.loads(os.getenv("IPA_SERVERS").replace("'", "\""))

    client = ClientMeta(ipa_servers[0], verify_ssl=False)
    client.login(creds["login"], creds["password"])

    host_info: dict = {
        "dns_zone": os.getenv("IPA_DNS_ZONE"),
        "vm_name": os.getenv("SERVICE_NAME"),
        "name": os.getenv("HOSTNAME"),
        "ip": os.getenv("IP4_INTERFACES"),
        "env": os.getenv("ENV"),
        "vm_type": os.getenv("VM_TYPE"),
        "rack": os.getenv("RACK"),
        "ipa_location": os.getenv("IPA_LOCATION"),
        "os_fullname": os.getenv("OS_FULLNAME"),
        "os_release": os.getenv("OS_RELEASE")
    }

    check_host: dict = client.host_find(f'{host_info["vm_name"]}.{host_info["dns_zone"]}')

    if not check_host["count"]:
        client.host_add(
            a_fqdn=f'{host_info["vm_name"]}.{host_info["dns_zone"]}',
            o_description=host_info["name"],
            o_ip_address=host_info["ip"]
        )

    if "description" not in check_host["result"][0]:
        result: dict = client.host_mod(
            a_fqdn=f'{host_info["vm_name"]}.{host_info["dns_zone"]}',
            o_description=host_info["name"],
            o_userclass=host_info["vm_type"],
            o_nshostlocation=host_info["env"],
            o_l=host_info["rack"],
            o_nshardwareplatform=host_info["ipa_location"],
            o_nsosversion=f'{host_info["os_fullname"]}-{host_info["os_release"]}'
        )
        # logger.info(result["summary"])
    elif check_host["result"][0]["description"][0] != host_info["name"] or \
            check_host["result"][0]["userclass"][0] != host_info["vm_type"] or \
            check_host["result"][0]["nshostlocation"][0] != host_info["ipa_location"] or \
            check_host["result"][0]["l"][0] != host_info["rack"]:
        result: dict = client.host_mod(
            a_fqdn=f'{host_info["vm_name"]}.{host_info["dns_zone"]}',
            o_description=host_info["name"],
            o_userclass=host_info["vm_type"],
            o_nshostlocation=host_info["env"],
            o_l=host_info["rack"],
            o_nshardwareplatform=host_info["ipa_location"],
            o_nsosversion=f'{host_info["os_fullname"]}-{host_info["os_release"]}'
            # o_nsosversion=""
        )
        # logger.info(result["summary"])

    exist_dns_record: dict = client.dnsrecord_find(
        a_dnszoneidnsname=host_info["dns_zone"],
        o_idnsname=host_info["vm_name"]
    )

    if not exist_dns_record["count"]:
        client.dnsrecord_add(
            a_dnszoneidnsname=host_info["dns_zone"],
            a_idnsname=host_info["vm_name"],
            o_a_part_ip_address=host_info["ip"]
        )

    client.hostgroup_add_member(
        a_cn=f'{host_info["env"]}-{host_info["vm_type"]}',
        o_host=f'{host_info["vm_name"]}.{host_info["dns_zone"]}'
    )
    # client.hostgroup_add_member(
    #     a_cn=os.getenv("IPA_GROUP"),
    #     o_host=f'{host_info["vm_name"]}.{host_info["dns_zone"]}'
    # )


if __name__ == '__main__':
    main()
