base:
  'MASTER':
    - unenrol
  '*.gtp':
    - enrol
    - kesl
    - sshkeys
    - authorized_keys
  '*.mtp':
    - enrol
    - kesl
    - exporter-node
    - exporter-process
