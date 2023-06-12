#!/bin/bash

curl -sH "Host: go-serve.local" 192.168.1.241/api -w '\n\n'

for i in {1..4}; do
    echo -n "creating record $i: "
    curl -sH "Host: go-serve.local" -X POST 192.168.1.241/api -w '\n'
done

echo -e "\nrecords before patching:"
curl -sH "Host: go-serve.local" 192.168.1.241/api | jq .

echo -e "\nwaiting for 2 seconds..."
sleep 2

echo -ne "patching record with id=2: "
curl -sH "Host: go-serve.local" -X PATCH 192.168.1.241/api?id=2 -w '\n'

echo "records after patching:"
curl -sH "Host: go-serve.local" 192.168.1.241/api | jq .
