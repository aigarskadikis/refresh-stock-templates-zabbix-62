#!/bin/bash

# remove old dir. start fresh
rm -rf /tmp/6.2.zip
rm -rf /tmp/zabbix-release-6.2

# generate a SID by using:
# "Administration" => "General" => "API tokens"
SID=$(cat ~/.zabbixapi)

# API endpoint
JSONRPC=http://demo.zabbix.demo/api_jsonrpc.php

# download latest 6.2 branch
curl -kL https://github.com/zabbix/zabbix/archive/refs/heads/release/6.2.zip -o /tmp/6.2.zip

# unzip
cd /tmp
unzip 6.2.zip

# go back to previous directory where PHP program is located
cd -

# start template import
find /tmp/zabbix-release-6.2/templates -type f -name '*.yaml' | \
while IFS= read -r TEMPLATE
do {
php delete_missing.php $SID $JSONRPC $TEMPLATE | jq .result | grep "true" | tr '\n' '\0'
echo " " | tr '\n' '\0'
# if 'true' not received the print the template name
[[ $? -ne 0 ]] && echo -e "\n$TEMPLATE\n"
} done

find /tmp/zabbix-release-6.2/templates/media -type f -name '*.yaml' | \
while IFS= read -r MEDIA
do {
php media_type.php $SID $JSONRPC $MEDIA | jq .result | grep "true"
# if 'true' not received the print the template name
[[ $? -ne 0 ]] && echo $MEDIA
} done

