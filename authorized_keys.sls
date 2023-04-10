/home/gt_prom/.ssh/authorized_keys:
  file.managed:
    - name: /home/gt_prom/.ssh/authorized_keys
    - source: salt://ssh_keys/gt_prom.id_rsa.pub
