#!/usr/bin/env bash

sudo apt install jq openssl docker.io -y

sudo systemctl start docker

cert_dir=${HOME}/portainer-certs

if [[ ! -d ${cert_dir} ]]; then
    mkdir -p ${cert_dir}
fi

mylocate=$(curl -XGET "http://ip-api.com/json/?fields=22" | jq .)

countryCode=$(echo $mylocate | jq .'countryCode')
region=$(echo $mylocate | jq .'region')
city=$(echo $mylocate | jq .'city')

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:4096 -keyout ${cert_dir}/portainer.key -out ${cert_dir}/portainer.crt -subj "/C=${countryCode//\"/}/ST=${region//\"/}/L=${city//\"/}/O=${USER}/CN=portainer.local"

docker run -d -p 443:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v ${cert_dir}:/certs -v portainer_data:/data portainer/portainer-ce --ssl --sslcert /certs/portainer.crt --sslkey /certs/portainer.key