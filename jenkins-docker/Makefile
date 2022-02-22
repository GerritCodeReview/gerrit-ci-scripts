AGENT_DIRS ?= agent-debian agent-chrome agent-node-wct agent-bazel-nocache agent-bazel agent-bazel-docker agent-sbt agent-mvn agent-release agent-python3 agent-jekyll agent-aws
ALL_DIRS ?= server bazel-cache $(AGENT_DIRS)
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

publish_agent:
	for dir in $(AGENT_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir build publish) || exit 1; done

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

start stop restart:
	make -C server $@
