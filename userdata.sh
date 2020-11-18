#!/bin/bash
if command -v apt-get >/dev/null; then
  apt update
  package="apache2"
  apt install -y $package
else command -v yum >/dev/null;
  yum -y update 
  package="httpd"
  yum -y install $package
fi
echo "Hello World from PlayQ Test" > /var/www/html/index.html
systemctl start $package
systemctl enable $package
