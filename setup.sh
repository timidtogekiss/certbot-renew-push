#/bin/bash

# $1 = netbox uri
# $2 = netbox api key

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

apiHeaders=(`curl -s -o /dev/null -D - $1`)

if [[ -z $apiHeaders ] || ! [ $apiHeaders == *"API-Version"* && $apiHeaders == *"200 OK"* ]]; then
    echo "Netbox API Url is invalid. Exiting..."
    exit 1
fi

cp settings.example.json settings.json
sed -n -i "\"netbox_token\": \"\"/\"netbox_token\": \"$2\"" settings.json
sed -n -i "\"netbox_url\": \"\"/\"netbox_url\": \"$1\"" settings.json

python3 -m venv venv
venv/Scripts/activate
pip3 install -r requirements.txt
deactivate