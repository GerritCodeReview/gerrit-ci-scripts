NO_CACHE=false
ORGANISATION=gerritforge
NAME=gerrit-ci
USE_SECURITY=false
OAUTH_ID=clientid
OAUTH_SECRET=secret
JENKINS_API_USER=user
JENKINS_API_PASSWORD=pass
JENKINS_WAR_VER=2.204.1
JENKINS_WAR_SHA=924d2c9fabfdcacee1bae757337a07d7599eaa35
JENKINS_HOME?=~/jenkins_home
DOCKER_GID?=993
IMAGE=${ORGANISATION}/${NAME}:${JENKINS_WAR_VER}

# Targets

start: build
	-docker rm ${NAME}
	mkdir -p ${JENKINS_HOME}/jobs
	docker run --name ${NAME} -d -e USE_SECURITY=${USE_SECURITY} \
          -e OAUTH_ID=${OAUTH_ID} \
          -e OAUTH_SECRET=${OAUTH_SECRET} \
          -e JENKINS_API_USER=${JENKINS_API_USER} \
          -e JENKINS_API_PASSWORD=${JENKINS_API_PASSWORD} \
          -e DOCKER_GID=${DOCKER_GID} \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v ${JENKINS_HOME}/jobs:/var/jenkins_home/jobs \
          -v ${JENKINS_HOME}/.netrc:/var/jenkins_home/.netrc \
          -v ${JENKINS_HOME}/.secrets:/var/jenkins_home/.secrets \
          --net=host ${IMAGE}

start_osx:
	-docker rm ${NAME} ${NAME}-socat
	mkdir -p ${JENKINS_HOME}/jobs
	docker run -d --name ${NAME}-socat \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -p 127.0.0.1:1234:1234 \
          bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock
	docker run --name ${NAME} -d -e USE_SECURITY=${USE_SECURITY} \
          -e OAUTH_ID=${OAUTH_ID} \
          -e OAUTH_SECRET=${OAUTH_SECRET} \
          -e JENKINS_API_USER=${JENKINS_API_USER} \
          -e JENKINS_API_PASSWORD=${JENKINS_API_PASSWORD} \
          -e DOCKER_GID=${DOCKER_GID} \
          -e DOCKER_HOST="tcp://host.docker.internal:1234" \
          -v ${JENKINS_HOME}/jobs:/var/jenkins_home/jobs \
          -v ${JENKINS_HOME}/.netrc:/var/jenkins_home/.netrc \
          -v ${JENKINS_HOME}/.netrc:/var/jenkins_home/.secrets \
          -p 8080:8080 ${IMAGE}

id_rsa:
	ssh-keygen -f id_rsa -t rsa -b 2048 -N ''
	chmod a+r id_rsa*

build: id_rsa
	docker build --no-cache=$(NO_CACHE) \
        --build-arg JENKINS_WAR_VER=${JENKINS_WAR_VER} \
        --build-arg JENKINS_WAR_SHA=${JENKINS_WAR_SHA} -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	-docker rmi -f ${IMAGE}
	-rm -f id_rsa*
	-rm -r ${JENKINS_HOME}

stop:
	for img in $$(docker ps -q -f name=${NAME}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${NAME})" == "" ] && \
          echo -e "\n${NAME} is *STOPPED*\n") || \
          echo -e "\n${NAME} is *RUNNING*\n"

.PHONY: clean image publish

