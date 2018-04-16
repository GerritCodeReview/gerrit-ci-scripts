#!/bin/bash

# install reqs.
yum install -y docker ppp telnet

mkdir -p .ssh

# recognize gerritforge.
echo '[gerrit-ci.gerritforge.com]:1022,[8.26.94.23]:1022 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUylKwtTDROpPce/sCfdMMR+N116TsZx5n4YHO8qPLaEhEXld+1T+hWe/HuITafW182hTnOjMHlK/GwH9A7KOS9XHHdBtHCYx0lH78kb+fvZsUtyuGlbQNXzQuyBIpJoYOtMRhn5aHR1sn1USHnnZp1V1dpDu/HYHjpj4pyA8I4i2BE89OVblxyggdulvgLfaLFJ+6Q9U+Mf+SHpufgsXDNlG/KTQVHioONoOnu47qbhJLSK+w5Q3dzaLa2CTPCZgdOFf3g6AQJWMKDEkTnReT9bR97lg1T59GoK2pLpem1gokiUQ052/qH/cL/b38XtW/IJCK9HmrV5Whc26dDg95' > .ssh/known_hosts

# Docker on port 2375
sed -i 's|$OPTIONS|$OPTIONS -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375|' /lib/systemd/system/docker.service

systemctl daemon-reload
systemctl start docker
systemctl restart docker
