#base:
#  'MASTER':
#    - enroll
#    - kesl
#    - sshkeys
#    - authorized_keys
#  '*.mtp':
#    - enroll
#    - kesl
#    - exporter-node
#    - exporter-process
#    - motd
#    - sshkeys

base:
  'MASTER':
    - unenroll
  '*.gtp':
    - enroll
    - kesl
    - exporter-node
    - exporter-process
#    - motd
    - sshkeys
  '*.mtp':
    - enroll
    - kesl
    - exporter-node
    - exporter-process
    - motd
    - sshkeys