#!/bin/sh

cat /etc/nginx/conf.d/default.conf.template | envsubst > /etc/nginx/conf.d/default.conf
nginx -g "daemon off;"
