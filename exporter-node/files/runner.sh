#!/bin/bash

for script in $(ls {{ node_exporter_path }}/scripts/*.sh); do
    sh $script > "$script.prom"
done

for script in $(ls {{ node_exporter_path }}/scripts/*.py); do
    python $script > "$script.prom"
done