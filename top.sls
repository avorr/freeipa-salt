base:
  'MASTER':
    - unenroll
  '*.gtp':
    - enroll
    - kesl
    - sshkeys
    - authorized_keys
  '*.mtp':
    - enroll
    - kesl
    - exporter-node
    - exporter-process
