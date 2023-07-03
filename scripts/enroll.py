#!/usr/bin/python3

import os
import json
from python_freeipa import ClientMeta

import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def main() -> None:
    ipa_cred: dict = {
        "login": os.getenv("LOGIN"),
        "password": os.getenv("PASSWORD"),
    }

    ipa_servers: list = json.loads(os.getenv("IPA_SERVERS").replace("'", "\""))

    client = ClientMeta(ipa_servers[0], verify_ssl=False)
    client.login(ipa_cred["login"], ipa_cred["password"])

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

    def add_srv_record(dns_zone: str, srv_name: str, srv_record: str) -> None:
        exist_srv_record: dict = client.dnsrecord_find(
            a_dnszoneidnsname=dns_zone,
            o_idnsname=srv_name
        )

        if not exist_srv_record["count"]:
            client.dnsrecord_add(
                a_dnszoneidnsname=dns_zone,
                a_idnsname=srv_name,
                o_srvrecord=srv_record
            )

        if exist_srv_record["result"]:
            if srv_record not in exist_srv_record["result"][0]["srvrecord"]:
                exist_srv_record["result"][0]["srvrecord"].append(srv_record)
                client.dnsrecord_mod(
                    a_dnszoneidnsname=dns_zone,
                    a_idnsname=srv_name,
                    o_srvrecord=exist_srv_record["result"][0]["srvrecord"]
                )

    def add_ptr_record(dns_zone: str, ptr_name: str, ptr_record: str) -> None:
        exist_ptr_record: dict = client.dnsrecord_find(
            a_dnszoneidnsname=dns_zone,
            o_idnsname=ptr_name
        )

        if not exist_ptr_record["count"]:
            client.dnsrecord_add(
                a_dnszoneidnsname=dns_zone,
                a_idnsname=ptr_name,
                o_ptrrecord=ptr_record
            )

    def add_host_info() -> None:
        client.host_mod(
            a_fqdn=f'{host_info["vm_name"]}.{host_info["dns_zone"]}',
            o_description=host_info["name"],
            o_userclass=host_info["vm_type"],
            o_nshostlocation=host_info["env"],
            o_l=host_info["rack"],
            o_nshardwareplatform=host_info["ipa_location"],
            o_nsosversion=f'{host_info["os_fullname"]}-{host_info["os_release"]}'
        )

    check_host: dict = client.host_find(f'{host_info["vm_name"]}.{host_info["dns_zone"]}')

    if not check_host["count"]:
        client.host_add(
            a_fqdn=f'{host_info["vm_name"]}.{host_info["dns_zone"]}',
            o_description=host_info["name"],
            o_ip_address=host_info["ip"],
            o_userclass=host_info["vm_type"],
            o_nshostlocation=host_info["env"],
            o_l=host_info["rack"],
            o_nshardwareplatform=host_info["ipa_location"],
            o_nsosversion=f'{host_info["os_fullname"]}-{host_info["os_release"]}'
        )
        add_host_info()
        check_host: dict = client.host_find(f'{host_info["vm_name"]}.{host_info["dns_zone"]}')

    attrs: dict = check_host["result"][0]

    if "description" not in attrs or "userclass" not in attrs or "nshostlocation" not in attrs or "l" not in attrs \
            or "nshardwareplatform" not in attrs or "nsosversion" not in attrs:
        add_host_info()
        check_host: dict = client.host_find(f'{host_info["vm_name"]}.{host_info["dns_zone"]}')
        attrs: dict = check_host["result"][0]

    if attrs["description"][0] != host_info["name"] or attrs["userclass"][0] != host_info["vm_type"] or \
            attrs["nshostlocation"][0] != host_info["env"] or attrs["l"][0] != host_info["rack"]:
        add_host_info()

    exist_a_record: dict = client.dnsrecord_find(
        a_dnszoneidnsname=host_info["dns_zone"],
        o_idnsname=host_info["vm_name"]
    )

    if exist_a_record['count'] == 0:
        client.dnsrecord_add(
            a_dnszoneidnsname=host_info["dns_zone"],
            a_idnsname=host_info["vm_name"],
            o_a_part_ip_address=host_info["ip"],
            o_a_extra_create_reverse=True
        )
        exist_a_record: dict = client.dnsrecord_find(
            a_dnszoneidnsname=host_info["dns_zone"],
            o_idnsname=host_info["vm_name"]
        )

    if "arecord" not in exist_a_record['result'][0]:
        client.dnsrecord_add(
            a_dnszoneidnsname=host_info["dns_zone"],
            a_idnsname=host_info["vm_name"],
            o_a_part_ip_address=host_info["ip"],
            o_a_extra_create_reverse=True
        )

    add_srv_record(host_info["dns_zone"], "_blackbox_ssh._tcp", f'0 100 9022 {host_info["vm_name"]}')
    add_srv_record(host_info["dns_zone"], "_node._tcp", f'0 100 19100 {host_info["vm_name"]}')
    add_srv_record(host_info["dns_zone"], "_process._tcp", f'0 100 19102 {host_info["vm_name"]}')

    #    add_ptr_record(
    #        '.'.join(host_info["ip"].split('.')[0:3][::-1]) + '.in-addr.arpa.',
    #        host_info["ip"].split('.')[3],
    #        f'{host_info["vm_name"]}.{host_info["dns_zone"]}.'
    #    )

    client.hostgroup_add_member(
        a_cn=f'{host_info["env"]}-{host_info["vm_type"]}',
        o_host=f'{host_info["vm_name"]}.{host_info["dns_zone"]}'
    )


if __name__ == '__main__':
    main()
