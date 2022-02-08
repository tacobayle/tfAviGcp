#!/bin/bash
sudo apt-get update
sudo apt install -y python3-pip
sudo apt install -y jq
pip3 install ansible==${ansibleVersion}
pip3 install avisdk==${avisdkVersion}
pip3 install dnspython
pip3 install netaddr
pip3 install google-auth
pip3 install requests
sudo -u ubuntu ansible-galaxy install -f avinetworks.avisdk
sudo -u ubuntu mkdir -p /home/${username}/.ssh
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
sudo mkdir -p /etc/ansible
sudo tee /etc/ansible/ansible.cfg > /dev/null <<EOT
[defaults]
inventory      = /opt/ansible/inventory/gcp.yaml
private_key_file = /home/${username}/.ssh/${ssh_private_key}
host_key_checking = False
host_key_auto_add = True
EOT
echo "cloud init done" | tee /tmp/cloudInitDone.log
