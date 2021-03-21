#!/bin/sh
#
#alias ll='ls -lah --color'

apt-get update && apt-get install -y libaio1 wget unzip

mkdir -p /opt/oracle
cd /opt/oracle
wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basiclite-linux.x64-21.1.0.0.0.zip
unzip instantclient-basiclite-linux.x64-21.1.0.0.0.zip


echo /opt/oracle/instantclient_21_1 > /etc/ld.so.conf.d/oracle-instantclient.conf
ldconfig

cp /app/wallet/* /opt/oracle/instantclient_21_1/network/admin/
