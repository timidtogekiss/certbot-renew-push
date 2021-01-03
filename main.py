import requests
from paramiko import SSHClient
from scp import SCPClient
import sys
import json

def gather_hosts(certdomain, netbox_token, netbox_url): 
    headers = {"Authorization": "token "+netbox_token}

    r = requests.get(netbox_url+"virtualization/virtual-machines?tag=certauthority_"+certdomain, headers=headers)
    #r2 = requests.get(netbox_url+"dcim/devices?tag=certauthority_"+certdomain, headers=headers)
    r.raise_for_status()
    return r.json()

def copy_certs(vms, certificate_folder_path):
    for vm in vms.results: 
        ssh = SSHClient()
        ssh.load_system_host_keys()
        ip_address = vm.primary_ip4.address.split("/")[0]
        ssh.connect(ip_address)

        scp = SCPClient(ssh.get_transport())
        scp.put(certificate_folder_path+"privkey.pem", remote_path="/etc/ssl/"+certificate_folder_path)
        scp.put(certificate_folder_path+"fullchain.pem", remote_path="/etc/ssl/"+certificate_folder_path)
        scp.close()
        ssh.close()

# argv variables:
# 0: script name
# 1: $RENEWED_LINEAGE from certbot renewal
def main():
    if (len(sys.argv) != 2): 
        print()
        # throw exception
    else: 
        with open('settings.json','r') as f: 
            settings = f.read()
        
        certificate_folder_path = sys.argv[1]
        temp = certificate_folder_path.split('/')
        certificate_name = temp[len(temp) - 1]

        vms = gather_hosts(certificate_name, settings.netbox_token, settings.netbox_url)
        copy_certs(vms, certificate_folder_path)
