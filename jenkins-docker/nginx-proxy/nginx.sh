#!/bin/sh

if [ ! -f /etc/nginx/cert.key ] || [ ! -f /etc/nginx/cert.crt ]; then
  openssl req -x509 \
    -newkey rsa:4096 \
    -keyout /etc/nginx/cert.key \
    -out /etc/nginx/cert.crt \
    -nodes \
    -subj '/CN=gerrit-ci.gerritforge.com'
fi

if [ ! -f /etc/ssl/certs/sso_ca.crt ]; then
  rm -f /etc/nginx/conf.d/jenkins-cert-auth.conf
fi

nginx -g 'daemon off;'
