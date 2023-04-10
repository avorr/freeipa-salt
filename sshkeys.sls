install_inotify:
  pip.installed:
    - name: pyinotify

/etc/salt/minion.d/beacons.conf:
  file.managed:
    - name: /etc/salt/minion.d/beacons.conf
    - source: salt://files/beacons.conf

#important_file:
#  file.managed:
#    - name: /home/gt_prom/.ssh/authorized_keys
#    - contents: |
#        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCfhXw9s+T4Xs/y7HiFzM5bxh0fOJMxSUq9pJzPYwL6lmfYc/p2jeNwjZUWo1kEtwa9zRJlFghg9NIvdyumA8vWYCKuyZMFifCSie5sDlCZkytftALfw1Jocalq3IGyfX1EaQ83L1BdO68atTiTj47u8vBgkTBdVDKuM5KM5NmUdmS0kg98t21etglfg7XjADsqy2T35BG+h7eYEn8ZbDIT4n9NWzs2A+HPedQjd1WETImSr7j9rMlN8vwBqJWnJRpxhVe6Nddd0M75a5beHraKR2W7iYBVeFgpG9TVR/oH4X7lpkTmvHkyqyy88FZnSWq/r9LEprLQKVzSUMsObuGs0csNO7OwNkTQiau6OvMaecQhsXt3ivX0yHq1bvRmhQV6SWeROVI+yfu0I5kY3JjyHym2qmCXrt61t5iEcE4f7PDHr+iFfP674zxMBetnYYBTpc7TLLqkRBqDJodLnbyMzh8psx+Ly/Id3skmWQFgK3tkSc91iFmEt/yh+DRats= ealeksivanov@SBTOV-AD002121

#sshkeys:
#  ssh_auth.present:
#    - user: gt_prom
#    - source: salt://ssh_keys/gt_prom.id_rsa.pub
