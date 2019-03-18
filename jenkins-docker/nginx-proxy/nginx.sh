#!/bin/sh

if [ ! -f /etc/ssl/certs/cert.key ] || [ ! -f /etc/ssl/certs/cert.crt ]; then
  openssl req -x509 \
    -newkey rsa:4096 \
    -keyout /etc/ssl/certs/cert.key \
    -out /etc/ssl/certs/cert.crt \
    -nodes \
    -subj '/CN=gerrit-ci.gerritforge.com'
fi

if [ ! -f /etc/ssl/certs/auth_ca.crt ]; then
  rm -f /etc/nginx/conf.d/jenkins-cert-auth.conf
fi

nginx -g 'daemon off;'
