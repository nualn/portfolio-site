#!/bin/sh

image_name="server_image"
container_name="server_container"
zip_name="server.zip"
vm_user=$(gcloud compute os-login describe-profile | grep username | awk '{ print $2 }')
server_ip=$(gcloud compute instances list | grep personal-site | awk '{ print $5 }')

zip -r server.zip . -x "deploy.sh" -x "README.md" -x ".git"

scp $zip_name $vm_user@$server_ip:$zip_name

ssh $vm_user@$server_ip /bin/sh << EOF
    sudo unzip -o $zip_name -d ./server
    cd server
    sudo docker-compose restart
EOF

rm server.zip