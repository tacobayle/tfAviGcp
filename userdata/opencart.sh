#!/bin/bash
#
# Tested for ubbuntu 18.04
#
sudo apt-get update
sudo apt-add-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt install -y php7.4
sudo apt install -y php7.4-{bcmath,bz2,intl,gd,mbstring,mysql,zip,curl,xml,dev}
sudo apt install -y apache2
sudo apt install -y libapache2-mod-php
sudo apt install -y libmcrypt-dev
sudo apt-get -y install unzip
wget ${opencartDownloadUrl}
sudo mkdir /var/www/opencart.${domainName}/
sudo unzip opencart-3.0.3.5.zip -d /var/www/opencart.${domainName}/
sudo mv /var/www/opencart.${domainName}/upload/config-dist.php /var/www/opencart.${domainName}/upload/config.php
sudo mv /var/www/opencart.${domainName}/upload/.htaccess.txt /var/www/opencart.${domainName}/upload/.htaccess
sudo mv /var/www/opencart.${domainName}/upload/admin/config-dist.php /var/www/opencart.${domainName}/upload/admin/config.php
sudo rm -f /var/www/opencart.${domainName}/*
sudo mv -f /var/www/opencart.${domainName}/upload/* /var/www/opencart.${domainName}/
sudo mv -f /var/www/opencart.${domainName}/upload/.* /var/www/opencart.${domainName}/
sudo rmdir /var/www/opencart.${domainName}/upload/
sudo chmod -R 755 /var/www/opencart.${domainName}/
sudo chown -R www-data:www-data /var/www/opencart.${domainName}/
echo "cloud init done" | tee /tmp/cloudInitDone.log
