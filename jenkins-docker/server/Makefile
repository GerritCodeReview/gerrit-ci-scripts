NO_CACHE=false
ORGANISATION=gerritforge
NAME=gerrit-ci
NAME_INTERNAL=${NAME}-internal
USE_SECURITY=false
OAUTH_ID=clientid
OAUTH_SECRET=secret
JENKINS_API_USER=user
JENKINS_API_PASSWORD=pass
# https://get.jenkins.io/war-stable/2.375.4
JENKINS_WAR_VER=2.375.4
JENKINS_WAR_SHA=9a82a8cf68eb143e2f3e14cb8eb591de1a4b6596259fce9e4c15b4b24a0d4125
JENKINS_HOME?=~/jenkins_home
JENKINS_HOME_INTERNAL?=${JENKINS_HOME}-internal
DOCKER_GID?=993
IMAGE=${ORGANISATION}/${NAME}:${JENKINS_WAR_VER}
IMAGE_INTERNAL=${ORGANISATION}/${NAME_INTERNAL}:${JENKINS_WAR_VER}
GERRIT_CI_PEM=./tls/gerrit-ci.pem
JENKINS_CSS_PATH=./css
PLUGIN_MANAGER_PATH=./plugin-manager
UID=1000
GID=1000
REMOTE_DOCKER_HOST=unix:///var/run/docker.sock
# To bump plugin versions:
# * Make required changes in required_plugins.txt and set PLUGIN_FILE=required_plugins.txt
# * Run `make start`, check the plugins work using the console
# * Replace plugins.txt: `curl -s http://localhost:8080/pluginManager/api/json?depth=1 | jq -r '.plugins[] | "\(.shortName):\(.version)"' | sort > plugins.txt`
# * Change PLUGIN_FILE back to plugins.txt
PLUGIN_FILE=plugins.txt

# Targets

start: build create_env ${GERRIT_CI_PEM}
	-docker rm ${NAME}
	mkdir -p ${JENKINS_HOME}/jobs
	JENKINS_HOME=${JENKINS_HOME} IMAGE=${IMAGE} NAME=${NAME} GERRIT_CI_PEM=${GERRIT_CI_PEM} JENKINS_CSS_PATH=${JENKINS_CSS_PATH} PLUGIN_MANAGER_PATH=${PLUGIN_MANAGER_PATH} \
	docker compose -f docker-compose.yaml up -d

log: create_env
	JENKINS_HOME=${JENKINS_HOME} IMAGE=${IMAGE} NAME=${NAME} \
	docker compose -f docker-compose.yaml logs --follow

start_osx: create_env ${GERRIT_CI_PEM}
	-docker rm ${NAME} ${NAME}-socat
	mkdir -p ${JENKINS_HOME}/jobs
	docker run -d --name ${NAME}-socat \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -p 127.0.0.1:1234:1234 \
          bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock
	JENKINS_HOME=${JENKINS_HOME} IMAGE=${IMAGE} NAME=${NAME} GERRIT_CI_PEM=${GERRIT_CI_PEM} JENKINS_CSS_PATH=${JENKINS_CSS_PATH} PLUGIN_MANAGER_PATH=${PLUGIN_MANAGER_PATH}\
	docker-compose -f docker-compose.osx.yaml up -d

log_osx: create_env
	JENKINS_HOME=${JENKINS_HOME} IMAGE=${IMAGE} NAME=${NAME} \
	docker compose -f docker-compose.osx.yaml logs --follow

create_env:
	printf \
        "USE_SECURITY=%s\nOAUTH_ID=%s\nOAUTH_SECRET=%s\nJENKINS_API_USER=%s\nJENKINS_API_PASSWORD=%s\nDOCKER_GID=%s\nREMOTE_DOCKER_HOST=%s\n" \
        "${USE_SECURITY}" \
        "${OAUTH_ID}" \
        "${OAUTH_SECRET}" \
        "${JENKINS_API_USER}" \
        "${JENKINS_API_PASSWORD}" \
        "${DOCKER_GID}" \
        "${REMOTE_DOCKER_HOST}" > jenkins-container.env

start_internal: build_internal create_env ${GERRIT_CI_PEM}
	-docker rm ${NAME_INTERNAL}
	mkdir -p ${JENKINS_HOME_INTERNAL}/jobs
	JENKINS_HOME=${JENKINS_HOME_INTERNAL} IMAGE=${IMAGE_INTERNAL} NAME=${NAME_INTERNAL} GERRIT_CI_PEM=${GERRIT_CI_PEM} JENKINS_CSS_PATH=${JENKINS_CSS_PATH} \
	docker compose -f docker-compose-internal.yaml up -d

${GERRIT_CI_PEM}:
	mkdir -p $(dir ${GERRIT_CI_PEM}) && \
	openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=US/ST=California/L=Sunnyvale/O=GerritForge/OU=CI/CN=gerrit-ci.gerritforge.com" && \
	cat key.pem cert.pem | tee ${GERRIT_CI_PEM} && \
	rm -f key.pem cert.pem

build:
	docker build --no-cache=$(NO_CACHE) \
          --build-arg JENKINS_WAR_VER=${JENKINS_WAR_VER} \
          --build-arg JENKINS_WAR_SHA=${JENKINS_WAR_SHA} \
          --build-arg PLUGIN_FILE=$(PLUGIN_FILE) \
          --build-arg SERVER_TYPE=external \
          -t ${IMAGE} .

build_internal:
	docker build --no-cache=$(NO_CACHE) \
          --build-arg JENKINS_WAR_VER=${JENKINS_WAR_VER} \
          --build-arg JENKINS_WAR_SHA=${JENKINS_WAR_SHA} \
          --build-arg PLUGIN_FILE=$(PLUGIN_FILE) \
          --build-arg SERVER_TYPE=internal \
          -t ${IMAGE_INTERNAL} .


publish:
	docker push ${IMAGE}

publish_internal:
	docker push ${IMAGE_INTERNAL}


clean:
	-docker rmi -f ${IMAGE}
	-rm -r ${JENKINS_HOME}

clean_internal:
	-docker rmi -f ${IMAGE_INTERNAL}
	-rm -r ${JENKINS_HOME_INTERNAL}

stop:
	for img in $$(docker ps -q -f name=${NAME}); do docker kill $$img; done

stop_internal:
	for img in $$(docker ps -q -f name=${NAME_INTERNAL}); do docker kill $$img; done


restart: stop start

restart_internal: stop_internal start_internal

status:
	([ "$$(docker ps -q -f name=${NAME})" == "" ] && \
          echo -e "\n${NAME} is *STOPPED*\n") || \
          echo -e "\n${NAME} is *RUNNING*\n"

status_internal:
	([ "$$(docker ps -q -f name=${NAME_INTERNAL})" == "" ] && \
          echo -e "\n${NAME_INTERNAL} is *STOPPED*\n") || \
          echo -e "\n${NAME_INTERNAL} is *RUNNING*\n"


.PHONY: clean image publish
