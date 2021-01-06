#!/bin/bash

netbox_token="$(jq -r '.netbox.token' settings.json)"
netbox_url="$(jq -r '.netbox.api_url' settings.json)"
netbox_tag_base="$(jq -r '.netbox.tag_base' settings.json)"
ssh_username="$(jq -r '.ssh.user' settings.json)"
ssh_key="$(jq -r '.ssh.key_path' settings.json)"
dest_path="$(jq -r '.dest_path' settings.json)"

if [[ -z $netbox_token || -z $netbox_url || -z $netbox_tag_base ]]; then
    echo "Netbox settings missing. Exiting..."
    exit 1
fi

certificateName="$(echo $RENEWED_LINEAGE | sed 's/.*\///')"
certificateName="$(echo $certificateName | sed 's/\./\-/')"

searchUrl="${netbox_url}virtualization/virtual-machines/?tag=${netbox_tag_base}${certificateName}"
echo $searchUrl

curl -sS -H "Authorization: token $netbox_token" "${searchUrl}" | jq -r '.results[] .primary_ip4.address' | sed "s/\/.*//" | while read ip_address; do
    scp $RENEWED_LINEAGE/fullchain.pem -i $ssh_key $ssh_username@$ip_address:$dest_path
    scp $RENEWED_LINEAGE/privkey.pem -i $ssh_key $ssh_username@$ip_address:$dest_path
done
