#!/bin/bash

# exit if curl not installed
if ! [ -x "$(command -v curl)" ]; then
    echo "curl is not installed. Exiting..." >&2
    exit 1
fi

# exit if jq not installed
if ! [ -x "$(command -v jq)" ]; then
    echo "jq is not installed. Exiting..." >&2
    exit 1
fi

#load settings
netbox_token="$(jq -r '.netbox.token' settings.json)"
netbox_url="$(jq -r '.netbox.api_url' settings.json)"
netbox_tag_base="$(jq -r '.netbox.tag_base' settings.json)"
ssh_username="$(jq -r '.ssh.user' settings.json)"
ssh_key="$(jq -r '.ssh.key_path' settings.json)"
dest_path="$(jq -r '.dest_path' settings.json)"

# check netbox settings are defined
if [[ -z $netbox_token || -z $netbox_url || -z $netbox_tag_base ]]; then
    echo "Netbox settings missing. Exiting..."
    exit 1
fi

# get domain name in netbox-friendly format from certbot
certificateName="$(echo $RENEWED_LINEAGE | sed 's/.*\///')"
certificateName="$(echo $certificateName | sed 's/\./\-/')"

searchUrl="${netbox_url}virtualization/virtual-machines/?tag=${netbox_tag_base}${certificateName}"
echo $searchUrl

# get ip addresses to deploy to from netbox. for each ip address, scp the fullchain and private key to the destination folder
curl -sS -H "Authorization: token $netbox_token" "${searchUrl}" | jq -r '.results[] .primary_ip4.address' | sed "s/\/.*//" | while read ip_address; do
    scp $RENEWED_LINEAGE/fullchain.pem -i $ssh_key $ssh_username@$ip_address:"${dest_path}${certificateName}"
    scp $RENEWED_LINEAGE/privkey.pem -i $ssh_key $ssh_username@$ip_address:"${dest_path}${certificateName}"
done
