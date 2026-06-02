#!/bin/bash

PREFIX=$1
INTERFACE=$2
SUBNET=$3
HOST=$4

if [[ $EUID -ne 0 ]]; then
   echo "Error: must be with root"
   exit 1
fi

REGEX_PREFIX='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$'
REGEX_INTERFACE='^[a-zA-Z0-9._-]+$'
REGEX_NUMBER='^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$'

if [[ ! $PREFIX =~ $REGEX_PREFIX ]]; then
   echo "Error: Prefix must be first argument. example 192.168"
   exit 1
fi

if [[ ! $INTERFACE =~ $REGEX_INTERFACE ]]; then
   echo "Error: Inerface must be second argument."
   exit 1
fi

validate_ip() {

    if [[ -n "$SUBNET" ]]; then
        [[ ! $SUBNET =~ $REGEX_NUMBER ]] && { echo "Error SUBNET must be is 1-255"; exit 1; }
        SUBNET_START=$SUBNET
        SUBNET_END=$SUBNET
    else
        SUBNET_START=1
        SUBNET_END=255
    fi

    if [[ -n "$HOST" ]]; then
        [[ ! $HOST =~ $REGEX_NUMBER ]] && { echo "Error HOST must be is 1-255"; exit 1; }
        HOST_START=$HOST
        HOST_END=$HOST
    else
        HOST_START=1
        HOST_END=255
    fi
    echo "$SUBNET_START $SUBNET_END $HOST_START $HOST_END"
}
read -r SUBNET_START SUBNET_END HOST_START HOST_END <<< $(validate_ip)

trap 'echo "Ping exit (Ctrl-C)"; exit 1' 2

for (( subnet=$SUBNET_START; subnet<=$SUBNET_END; subnet++ ))
do
    for (( host=$HOST_START; host<=$HOST_END; host++ ))
    do
        IP="${PREFIX}.${subnet}.${host}"
        echo "[*] IP : $IP"
        arping -c 3 -i "$INTERFACE" "$IP" 2> /dev/null
    done
done
