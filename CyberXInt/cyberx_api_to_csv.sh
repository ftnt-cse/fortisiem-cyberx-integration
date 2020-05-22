#!/bin/bash
# FortiSIEM Collect CyberX Devices over API and Dump CSV File
# cdurkin@fortinet.com - US ATP Team
# Version 1.1 - 5th March 2020
# Version 1.2 - 10th March 2020 (added Mac Addresses, Firmware and Protocols)

APIKEY="2eaefbc4e26649deb3f4f57308a39608"
CYBERX_IP="192.168.1.180"

curl --insecure -s --header "Authorization: $APIKEY" --header "Accept: application/json" --header "Content-Type: application/json" -XGET https://$CYBERX_IP/api/v1/devices > all_cyberx_devices.json

#cat all_cyberx_devices.json | jq -r '.[] | [.ipAddresses[0]?, .vendor // "Generic", .type, .name, .operatingSystem, .scanner, .hasDynamicAddress, .id, .engineeringStation] | @csv' | sed 's/"//g' | sed '/^,/d' | sed '/Multicast\/Broadcast/d' > all_cyberx_devices.csv 

cat all_cyberx_devices.json | jq -r '.[] | [.ipAddresses[0]?, .vendor // "Generic", .type, .name, .operatingSystem, .macAddresses[0]?, .firmware[]?.firmwareVersion, ([.protocols[].name]| join(";")), .scanner, .hasDynamicAddress, .id, .engineeringStation] | @csv' | sed 's/"//g' | sed '/^,/d' | sed '/Multicast\/Broadcast/d' > all_cyberx_devices.csv


sed -i 's/$/,CyberX_API/g' all_cyberx_devices.csv
sed  -i '1i ip,vendor,type,name,os,mac,firmware,protocols,scanner,dhcp,id,engineeringStation,method' all_cyberx_devices.csv

# Field Mapping
#ip -> Device IP
#vendor -> Device Type Vendor
#type -> Device Type Model
#name -> Device Name
#os -> Device OS Edition
#mac -> Property Device MAC Address
#firmware -> Device Image File
#protocols -> CyberX Protocols (custom field)
#scanner -> CyberX Scanner (custom field)
#dhcp -> CyberX Dynamic Address (custom field)
#id -> CyberX ID (custom field)
#engineeringStation -> CyberX EngineeringStation (custom field)
#method -> Device Discover Method

#Device Map Fixes (Here or in FSM GUI)
#VMWARE INC. -> VMware
#FORTINET INC. -> Fortinet
#Unknown -> Generic
#Fortinet,Router -> Fortinet,FortiOS
sed -i 's/,VMWARE INC.,/,VMware,/g' all_cyberx_devices.csv 
sed -i 's/,FORTINET INC.,/,Fortinet,/g' all_cyberx_devices.csv
sed -i 's/,Unknown,/,Generic,/g' all_cyberx_devices.csv
sed -i 's/,Fortinet,Router,/,Fortinet,FortiOS,/g' all_cyberx_devices.csv

cp all_cyberx_devices.csv /tmp/cyberx_devices.csv

