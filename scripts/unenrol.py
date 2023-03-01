#!/usr/bin/python3
import os

# import salt.key
# import salt.client
# import salt.config
# import salt.wheel
import json
import requests
from python_freeipa import ClientMeta


def main() -> None:
    portal_info: dict = {
        'url': os.getenv("PORTAL_URL"),
        'token': os.getenv("PORTAL_TOKEN"),
    }

    def portal_api(api_name: str) -> dict:
        """
        Func to work with Portal REST-API
        :param api_name:
        :return: dict
        """
        headers: dict = {
            "user-agent": 'Salt Master',
            "Content-type": 'application/json',
            "Accept": "text/plain",
            "authorization": "Token %s" % portal_info["token"]
        }
        # print(headers)
        response = requests.get(f'{portal_info["url"]}/api/{api_name}', headers=headers, verify=False, timeout=20)
        print(response.status_code)
        return dict(data=json.loads(response.content), status_code=response.status_code)

    portal_vms: list = portal_api("v1/servers")["data"]
    print(portal_vms)

    # from tools import write_to_file
    # write_to_file(f"{portal_vms=}")

    # from all_portal_vms import all_portal_vms

    # print(all_portal_vms)

    # for i in portal_vms['servers']:
    #     print(i)

    return
    # master_opts = salt.config.master_config('/etc/salt/master')
    # minion_opts = salt.config.minion_config('/etc/salt/minion')
    # all_minions = salt.key.get_key(master_opts).all_keys().get('minions')
    all_minions = [
        'infra-salt-minion-01.pd15.admin.gtp',
        'infra-salt-minion-02.pd15.admin.gtp',
        'MASTER'
    ]

    # wheel = salt.wheel.WheelClient(master_opts)
    # local = salt.client.LocalClient()
    # minions_ping = local.cmd('*', 'test.ping')
    minions_ping = {'infra-salt-minion-01.pd15.admin.gtp': True,
                    'infra-salt-minion-02.pd15.admin.gtp': True,
                    'MASTER': True}
    # print(wheel.cmd('key.delete', ['infra-salt-minion-01.pd15.admin.gtp']))

    creds: dict = {
        "login": os.getenv("LOGIN"),
        "password": os.getenv("PASSWORD"),
    }

    ipa_servers: str = os.getenv("IPA_SERVERS").split(",")

    client = ClientMeta(ipa_servers[0], verify_ssl=False)
    client.login(creds["login"], creds["password"])

    # user = client.user_find("apvorobev")

    # print(user)

    # host = client.host_find("infra-salt-minion-02.pd15.admin.gtp")
    all_hosts = client.host_find()
    # delete_host = client.host_del()
    # all_ipa_hosts = client.

    # print(host['result'][0]['cn'])
    count = 0
    for i in all_hosts['result']:
        print(i['cn'])
        print(i)
        count += 1
        # for k in i:
        #     print(k)
    print(count)
    # if not os.path.exists('/opt/test'):
    #     os.mknod('/opt/test')


if __name__ == '__main__':
    main()
