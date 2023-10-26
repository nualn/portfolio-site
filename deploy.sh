#!/bin/sh

image_name="server_image"
container_name="server_container"
vm_user=$(gcloud compute os-login describe-profile | grep username | awk '{ print $2 }')
server_ip=$(gcloud compute instances list | grep personal-site | awk '{ print $5 }')

docker build -t $image_name .

docker save -o $image_name.tar $image_name

scp $image_name.tar $vm_user@$server_ip:$image_name.tar

ssh $vm_user@$server_ip /bin/sh << EOF
    sudo docker load < $image_name.tar
    sudo docker stop $container_name
    sudo docker rm $container_name
    sudo docker run -d --name $container_name -p 80:80 $image_name
    sudo docker image prune -f
EOF

rm $image_name.tar