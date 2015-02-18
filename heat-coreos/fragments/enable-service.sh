#!/bin/bash -v
setenforce 0

#Ubuntu Installation
apt-get install docker.io
service docker.io start

#Fedora Installation
#yum -y install docker-io
#cp /usr/lib/systemd/system/docker.service /etc/systemd/system/
#sed -i -e '/ExecStart/ { s,fd://,tcp://0.0.0.0:2345, }' /etc/systemd/system/docker.service
#systemctl start docker.service
