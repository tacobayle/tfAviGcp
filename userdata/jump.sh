#!/bin/bash
sudo apt-get update
sudo apt install -y python3-pip
sudo apt install -y python-pip
sudo apt install -y jq
sudo apt install -y python-jmespath
pip install ansible==${ansibleVersion}
pip install avisdk==${avisdkVersion}
pip3 install avisdk==${avisdkVersion}
pip install requests
pip install google-auth
pip install dnspython
pip install netaddr
pip install gdown
# pip3 install requests
# pip3 install google-auth
# pip3 install dnspython
# pip3 and ubuntu 20.04 seem to bug with google ansible module!!!
sudo -u ubuntu ansible-galaxy install -f avinetworks.avisdk
sudo mkdir -p /opt/ansible/inventory
sudo chmod -R 757 /opt/ansible/inventory
sudo tee /opt/ansible/inventory/gcp.yaml > /dev/null <<EOT
---
plugin: gcp_compute
projects:
  - ${googleProject}
auth_kind: serviceaccount
service_account_file: /opt/ansible/inventory/${basename(ansibleGcpServiceAccount)}
keyed_groups:
  - key: labels
    prefix: ${ansiblePrefixGroup}
EOT
#sudo chmod -R 755 /opt/ansible
sudo mkdir -p /etc/ansible
sudo tee /etc/ansible/ansible.cfg > /dev/null <<EOT
[defaults]
inventory      = /opt/ansible/inventory/gcp.yaml
private_key_file = /home/${username}/.ssh/${basename(privateKey)}
host_key_checking = False
host_key_auto_add = True
EOT
echo "cloud init done" | tee /tmp/cloudInitDone.log
