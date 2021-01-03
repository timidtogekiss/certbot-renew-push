#/bin/bash

# inputs
# ---------------------------------
# $1 = netbox uri
# $2 = netbox api key


# ---------------------------------
# start dependency management
# ---------------------------------
# just install the dependencies on Debian/Ubuntu/other distros that use apt
if [ -x "$(command -v apt)" ]; then
    apt install python3 python3-pip python3-venv curl
fi

if ! [ -x "$(command -v python3)" ]; then
    echo "Python 3 is not installed. Exiting..." >&2
    exit 1
fi

if ! [ -x "$(command -v pip3)" ]; then
    echo "pip3 is not installed. Exiting..." >&2
    exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
    echo "curl is not installed. Exiting..." >&2
    exit 1
fi
# ---------------------------------
# done with dependency management
# ---------------------------------


apiVersion=$(curl -s -I $1 | grep -Fi API-Version)
if [[ $apiVersion != *"API-Version"* ]]; then
    echo "Netbox API Url is invalid. Exiting..."
    exit 1
fi

#cp settings.example.json settings.json
#sed -n -i "s/.*\"netbox_token\": \"\"/\"netbox_token\": \"$2\"" settings.json
#sed -n -i "s/.*\"netbox_url\": \"\"/\"netbox_url\": \"$1\"" settings.json

python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
deactivate

# shamelessly stolen from here: https://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

installDir=$(echo $dir | sed 's_/_\\/_g')
sed -i "s/\#\!.*/\#\!$installDir\/venv\/bin\/python3/" main.py