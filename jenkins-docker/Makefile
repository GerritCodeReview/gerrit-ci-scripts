SLAVE_DIRS ?= slave-debian slave-chrome slave-node-wct slave-buck slave-bazel-nocache slave-bazel slave-sbt slave-mvn slave-release
ALL_DIRS ?= master $(SLAVE_DIRS)
NO_CACHE ?= true

USE_SECURITY ?= true
JENKINS_API_USER ?= user
JENKINS_API_PASSWORD ?= pass
JENKINS_HOME ?= ~/jenkins_home
NGINX_CERTS ?= ~/.ssl

OPTS = USE_SECURITY=${USE_SECURITY} \
       JENKINS_API_USER=${JENKINS_API_USER} \
       JENKINS_API_PASSWORD=${JENKINS_API_PASSWORD} \
       JENKINS_HOME=${JENKINS_HOME} \
       NGINX_CERTS=${NGINX_CERTS}

default: build

build clean publish:
	for dir in $(ALL_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir $@) || exit 1; done

build_slave:
	for dir in $(SLAVE_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir build) || exit 1; done

start:
	$(OPTS) docker-compose up -d

stop:
	$(OPTS) docker-compose down
