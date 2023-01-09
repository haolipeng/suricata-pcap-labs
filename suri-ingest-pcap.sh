#!/usr/bin/env bash

SESSION_USER=$(logname)

PCAPFILE=$1

if (( $EUID != 0 )); then
     echo -e "Please run this script as root or with \"sudo\".\n"
     exit 1
fi

if [ -z $PCAPFILE ] || [ ! -f $PCAPFILE ]; then
    echo "File ${PCAPFILE} doesnt seem to be there - please supply a pcap file."
    exit 1;
fi

# cleanup Suri logs
echo "" > /var/log/suricata/eve.json

# cleanup evebox
rm /home/$SESSION_USER/Training/evebox/*

sudo systemctl restart evebox.service

## process pcap
suricata -c /etc/suricata/suricata.yaml -k none -r $1 --runmode=autofp  --user=$SESSION_USER -l /var/log/suricata/

#print out alerts
echo -e "\nAlerts:\n"
grep '"event_type":"alert"' /var/log/suricata/eve.json  |jq '"\(.timestamp) | \(.alert.gid):\(.alert.signature_id):\(.alert.rev) | \(.alert.signature) | \(.alert.category) | \(.src_ip):\(.src_port) -> \(.dest_ip):\(.dest_port)"'
