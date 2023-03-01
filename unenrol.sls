salt://scripts/unenrol.py:
  cmd.run:
    - name: {{ grains.pythonexecutable }} /srv/salt/scripts/unenrol.py
    - env:
      - BATCH: true
