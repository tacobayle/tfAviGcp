#!/bin/bash
#
# Validated for Ubuntu 18.04
#
sudo apt-get update
sudo apt install -y mysql-server
#sudo apt install -y python-pip
sudo apt install -y python3-pip
#pip install PyMySQL
pip3 install PyMySQL
echo "cloud init done" | tee /tmp/cloudInitDone.log
