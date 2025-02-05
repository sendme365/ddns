#!/bin/bash
set -e;

# DSM Config
username="$1"
password="$2"
hostname="$3"
ipAddr="$4"

ZONE_ID=$(curl -X GET "https://api.cloudflare.com/client/v4/zones" \
-H "X-Auth-Email: $username" \
-H "X-Auth-Key: $password" | jq -r '.result[0].id')

DNS_RECORD_ID=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$hostname" \
-H "X-Auth-Email: $username" \
-H "X-Auth-Key: $password" | jq -r '.result[0] | select(.name == "'"$hostname"'")'.id )

curl https://api.cloudflare.com/client/v4/zones/"$ZONE_ID"/dns_records/"$DNS_RECORD_ID" \
    -X PUT \
    -H 'Content-Type: application/json' \
    -H "X-Auth-Email: $username" \
    -H "X-Auth-Key: $password" \
    -d '{
    "comment": "Domain verification record",
    "content": "'"${ipAddr}"'",
    "name": "'"${hostname}"'",
    "proxied": false,
    "ttl": 3600,
    "type": "A"
    }'