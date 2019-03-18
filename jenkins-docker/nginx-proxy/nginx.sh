#!/bin/sh

if [ ! -f /etc/ssl/certs/cert.key ] || [ ! -f /etc/ssl/certs/cert.crt ]; then
  echo "ERROR: Missing SSL-key pair."
  echo "Expected to find `/etc/ssl/certs/cert.key` and `/etc/ssl/certs/cert.crt`"
  exit 1
fi

if [ ! -f /etc/ssl/certs/auth_ca.crt ]; then
  rm -f /etc/nginx/conf.d/jenkins-cert-auth.conf
fi

nginx -g 'daemon off;'
