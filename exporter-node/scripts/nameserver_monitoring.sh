#!/bin/bash
#
## Description: Check resolv.conf
#
regex="^nameserver +([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$)"
NAMESERVER_TOTAL_COUNT=0
echo '# HELP nameserver_ip Currents of nameservers in /etc/resolv.conf'
echo '# TYPE nameserver_ip gauge'
while read line; do
    if [[ $line =~ $regex ]]; then
        let NAMESERVER_TOTAL_COUNT++
        echo "nameserver_ip{nameserver=\"${BASH_REMATCH[1]}\"} 1"
    fi
done < /etc/resolv.conf

echo '# HELP nameservers_total_count Total number of nameservers in /etc/resolv.conf'
echo '# TYPE nameservers_total_count gauge'
echo "nameservers_total_count ${NAMESERVER_TOTAL_COUNT}"