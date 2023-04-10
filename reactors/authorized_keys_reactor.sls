/home/gt_prom/.ssh/authorized_keys:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - authorized_keys
