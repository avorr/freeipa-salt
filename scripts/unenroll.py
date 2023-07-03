#!/usr/bin/python3

import os
import json
import urllib3
from python_freeipa import ClientMeta

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def main() -> None:
    ipa_cred: dict = {
        "login": os.getenv("IPA_LOGIN"),
        "password": os.getenv("IPA_PASSWORD"),
    }

    ipa_servers: list = json.loads(os.getenv("IPA_SERVERS").replace("'", "\""))

    minion_id: str = os.getenv("MINION_ID")
    client = ClientMeta(ipa_servers[0], verify_ssl=False)
    client.login(ipa_cred["login"], ipa_cred["password"])

    check_host: dict = client.host_find(minion_id)

    def remove_srv_record(dns_zone: str, idnsname: str, srv_record: str):

        check_srv_record: dict = client.dnsrecord_find(dns_zone, o_idnsname=idnsname)

        if check_srv_record["count"] == 1:
            if "srvrecord" in check_srv_record["result"][0]:
                if srv_record in check_srv_record["result"][0]["srvrecord"]:
                    srv_record_index: int = check_srv_record["result"][0]["srvrecord"].index(srv_record)
                    check_srv_record["result"][0]["srvrecord"].pop(srv_record_index)
                    client.dnsrecord_mod(
                        a_dnszoneidnsname=dns_zone,
                        a_idnsname=idnsname,
                        o_srvrecord=check_srv_record["result"][0]["srvrecord"]
                    )

    if check_host["count"] == 1:
        client.host_del(a_fqdn=minion_id, updatedns=True)
        hostname: str = check_host["result"][0]["serverhostname"][0]
        dns_zone: str = minion_id[len(hostname) + 1:]
        remove_srv_record(dns_zone, "_blackbox_ssh._tcp", f"0 100 9022 {hostname}")
        remove_srv_record(dns_zone, "_node._tcp", f"0 100 19100 {hostname}")
        remove_srv_record(dns_zone, "_process._tcp", f"0 100 19102 {hostname}")


if __name__ == '__main__':
    main()
