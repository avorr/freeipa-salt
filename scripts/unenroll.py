#!/usr/bin/python3

import os
import json
import urllib3
from python_freeipa import ClientMeta

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def main() -> None:
    creds: dict = {
        "login": os.getenv("IPA_LOGIN"),
        "password": os.getenv("IPA_PASSWORD"),
    }

    ipa_servers: list = json.loads(os.getenv("IPA_SERVERS").replace("'", "\""))

    minion_id: str = os.getenv("MINION_ID")
    client = ClientMeta(ipa_servers[0], verify_ssl=False)
    client.login(creds["login"], creds["password"])

    check_host: dict = client.host_find(minion_id)
    if check_host['count'] == 1:
        client.host_del(a_fqdn=minion_id, updatedns=True)


if __name__ == '__main__':
    main()

