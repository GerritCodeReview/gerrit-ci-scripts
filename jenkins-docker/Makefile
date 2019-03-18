SLAVE_DIRS ?= slave-debian slave-chrome slave-node-wct slave-bazel-nocache slave-bazel slave-bazel-docker slave-sbt slave-mvn slave-release slave-python3 slave-jekyll slave-aws
ALL_DIRS ?= master bazel-cache $(SLAVE_DIRS)
NO_CACHE ?= true

USE_SECURITY ?= true
JENKINS_HOME ?= ~/jenkins_home
NGINX_CERTS ?= ~/.ssl

OPTS = USE_SECURITY=${USE_SECURITY} \
       JENKINS_HOME=${JENKINS_HOME} \
       NGINX_CERTS=${NGINX_CERTS}

default: build

build clean publish:
	for dir in $(ALL_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir $@) || exit 1; done

publish_slave:
	for dir in $(SLAVE_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir build publish) || exit 1; done

ssl_certs:
	if [ ! -f ${NGINX_CERTS}/cert.key ] || [ ! -f ${NGINX_CERTS}/cert.key ]; then \
		openssl req -x509 \
			-newkey rsa:4096 \
			-keyout ${NGINX_CERTS}/cert.key \
			-out ${NGINX_CERTS}/cert.crt \
			-nodes \
			-subj '/CN=gerrit-ci.gerritforge.com'; \
	fi

start: ssl_certs
	$(OPTS) docker-compose up -d

stop:
	$(OPTS) docker-compose down
