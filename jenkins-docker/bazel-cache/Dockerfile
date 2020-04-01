FROM nginx:1.17.9-alpine

ENV NGINX_WEBDAV_ALLOW 0.0.0.0/0

COPY default.conf /etc/nginx/conf.d/default.conf.template

COPY entrypoint.sh /

RUN mkdir -p /data/www && \
    mkdir -p /data/client_temp && \
    chown -R nginx:nginx /data

RUN apk add gettext

VOLUME [ "/data" ]

ENTRYPOINT /entrypoint.sh
