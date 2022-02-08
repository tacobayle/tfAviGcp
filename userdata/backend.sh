#!/bin/bash
sudo apt update
sudo apt install -y apache2
sudo apt install -y docker.io
sudo usermod -a -G docker ${username}
sudo mv /var/www/html/index.html /var/www/html/index.html.old
echo -e "Hello World - cloud is GCP - Node is $(hostname)" | sudo tee /var/www/html/index.html
git clone ${url_demovip_server}
cd $(basename ${url_demovip_server})
sudo docker build . --tag demovip_server:latest
ifPrimary=`ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//"`
ip=$(ip -f inet addr show $ifPrimary | awk '/inet / {print $2}' | awk -F/ '{print $1}')
sudo docker run -d -p $ip:8080:80 demovip_server:latest
echo "cloud init done" | tee /tmp/cloudInitDone.log
# while true
# do
# echo -e "HTTP/1.1 200 OK\n\nHello World - cloud is GCP - Node is $(hostname)" | nc -N -l -p 80
# done
