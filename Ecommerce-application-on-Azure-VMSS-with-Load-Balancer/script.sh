#!/bin/sh

sudo apt-get update 
sudo apt-get install apache2 -y
mkdir web-dir
cd web-dir
wget https://www.free-css.com/assets/files/free-css-templates/download/page293/hexashop.zip
sudo apt-get install zip -y
unzip hexashop.zip
cd templatemo_571_hexashop
sudo mv * /var/www/html/
cd /var/www/html/
sudo systemctl enable apache2
sudo systemctl start apache2
