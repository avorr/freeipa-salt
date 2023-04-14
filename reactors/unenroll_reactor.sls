unenroll:
  runner.state.orchestrate:
    - args:
        - mods: orchestrate.unenroll
        - pillar:
            minion_id: {{ data["id"] }}

