FROM nginx:stable-alpine

RUN apk update && \
    apk add curl

COPY *.conf /etc/nginx/conf.d/
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.sh /var/opt/nginx.sh

ENTRYPOINT ["/var/opt/nginx.sh"]
