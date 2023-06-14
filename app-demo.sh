#!/bin/bash

# replace DOMAIN and IP with your own values from the ingress and service
DOMAIN="go-serve.local"
IP="192.168.1.241"

curl -sH "Host: $DOMAIN" $IP/api -w '\n\n'

for i in {1..4}; do
    echo -n "creating record $i: "
    curl -sH "Host: $DOMAIN" -X POST $IP/api -w '\n'
done

echo -e "\nrecords before patching:"
curl -sH "Host: $DOMAIN" $IP/api | jq .

echo -e "\nwaiting for 2 seconds..."
sleep 2

echo -ne "patching record with id=2: "
curl -sH "Host: $DOMAIN" -X PATCH $IP/api?id=2 -w '\n'

echo "records after patching:"
curl -sH "Host: $DOMAIN" $IP/api | jq .
