#!/bin/bash

netbox_token="$(jq '.netbox.token' settings.json)"
netbox_url="$(jq '.netbox.api_url' settings.json)"
netbox_tag_base="$(jq '.netbox.tag_base' settings.json)"
ssh_username="$(jq '.ssh.user' settings.json)"
ssh_key="$(jq '.ssh.key_path' settings.json)"
dest_path="$(jq '.dest_path' settings.json)"

if [[ -z $netbox_token || -z $netbox_url || -z $netbox_tag_base]]; then
    echo "Netbox settings missing. Exiting..."
    exit 1
fi

certificateName="$(echo $RENEWED_LINEAGE | sed 's/.*\///')"

searchUrl="$($netbox_url)virtualization/virtual-machines/?tag=$($netbox_tag_base)$($certificateName)"

curl -sS -H "Authorization: token d4cf122bc7fa6f16c6211d47ccd7f9363760a441" $searchUrl | jq -r '.results[] .primary_ip4.address' | sed "s/\/.*//" | while read ip_address; do
    scp $RENEWED_LINEAGE/fullchain.pem -i $ssh_key $ssh_username@$ip_address:$dest_path
    scp $RENEWED_LINEAGE/privkey.pem -i $ssh_key $ssh_username@$ip_address:$dest_path
done
