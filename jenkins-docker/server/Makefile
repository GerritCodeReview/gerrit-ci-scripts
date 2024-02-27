NO_CACHE=false
ORGANISATION=gerritforge
NAME=gerrit-ci
USE_SECURITY=false
OAUTH_ID=clientid
OAUTH_SECRET=secret
JENKINS_API_USER=user
JENKINS_API_PASSWORD=pass
# https://get.jenkins.io/war-stable/2.375.4
JENKINS_WAR_VER=2.440.1-lts
JENKINS_WAR_SHA=0a4dee3276867329745bc9d253dad8565fab00b4c2f06e1a22d492d6d464495d
JENKINS_HOME?=~/jenkins_home
DOCKER_GID?=993
IMAGE=${ORGANISATION}/${NAME}:${JENKINS_WAR_VER}
# To bump plugin versions:
# * Make required changes in required_plugins.txt and set PLUGIN_FILE=required_plugins.txt
# * Run `make start`, check the plugins work using the console
# * Replace plugins.txt: `curl -s http://localhost:8080/pluginManager/api/json?depth=1 | jq -r '.plugins[] | "\(.shortName):\(.version)"' | sort > plugins.txt`
# * Change PLUGIN_FILE back to plugins.txt
PLUGIN_FILE=plugins.txt

# Targets

start: build create_env
	-docker rm ${NAME}
	mkdir -p ${JENKINS_HOME}/jobs
	JENKINS_HOME=${JENKINS_HOME} IMAGE=${IMAGE} NAME=${NAME} \
	docker compose -f docker-compose.yaml up -d

log: create_env
	JENKINS_HOME=${JENKINS_HOME} IMAGE=${IMAGE} NAME=${NAME} \
	docker compose -f docker-compose.yaml logs --follow

start_osx: create_env
	-docker rm ${NAME} ${NAME}-socat
	mkdir -p ${JENKINS_HOME}/jobs
	docker run -d --name ${NAME}-socat \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -p 127.0.0.1:1234:1234 \
          bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock
	JENKINS_HOME=${JENKINS_HOME} IMAGE=${IMAGE} NAME=${NAME} \
	docker-compose -f docker-compose.osx.yaml up -d

log_osx: create_env
	JENKINS_HOME=${JENKINS_HOME} IMAGE=${IMAGE} NAME=${NAME} \
	docker compose -f docker-compose.osx.yaml logs --follow

create_env:
	echo \
        "USE_SECURITY=${USE_SECURITY}\n" \
        "OAUTH_ID=${OAUTH_ID}\n" \
        "OAUTH_SECRET=${OAUTH_SECRET}\n" \
        "JENKINS_API_USER=${JENKINS_API_USER}\n" \
        "JENKINS_API_PASSWORD=${JENKINS_API_PASSWORD}\n" \
        "DOCKER_GID=${DOCKER_GID}\n" > jenkins-container.env

build:
	docker build --no-cache=$(NO_CACHE) \
          --build-arg JENKINS_WAR_VER=${JENKINS_WAR_VER} \
          --build-arg JENKINS_WAR_SHA=${JENKINS_WAR_SHA} \
          --build-arg PLUGIN_FILE=$(PLUGIN_FILE) \
          -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	-docker rmi -f ${IMAGE}
	-rm -r ${JENKINS_HOME}

stop:
	for img in $$(docker ps -q -f name=${NAME}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${NAME})" == "" ] && \
          echo -e "\n${NAME} is *STOPPED*\n") || \
          echo -e "\n${NAME} is *RUNNING*\n"

.PHONY: clean image publish
