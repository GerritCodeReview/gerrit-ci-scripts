FROM nginx:stable-alpine

RUN apk update && \
    apk add curl

COPY *.conf /etc/nginx/conf.d/
COPY nginx.sh /var/opt/nginx.sh

ENTRYPOINT ["/var/opt/nginx.sh"]
