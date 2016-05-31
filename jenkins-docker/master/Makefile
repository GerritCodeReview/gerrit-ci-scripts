NO_CACHE=false
IMAGE=gerrit-ci
USE_SECURITY=false
OAUTH_ID=clientid
OAUTH_SECRET=secret
JENKINS_API_USER=user
JENKINS_API_PASSWORD=pass
DOCKER_PORT=$(shell lsof -i tcp | grep LISTEN | grep docker | cut -d ':' -f 2 \
              | cut -d ' ' -f 1)

# Targets

start: build
	-docker rm ${IMAGE}
	docker run --name ${IMAGE} -d -e USE_SECURITY=${USE_SECURITY} \
          -e OAUTH_ID=${OAUTH_ID} \
          -e OAUTH_SECRET=${OAUTH_SECRET} \
          -e JENKINS_API_USER=${JENKINS_API_USER} \
          -e JENKINS_API_PASSWORD=${JENKINS_API_PASSWORD} \
          -e DOCKER_HOST="http://127.0.0.1:${DOCKER_PORT}" \
          --net=host ${IMAGE}

id_rsa:
	ssh-keygen -f id_rsa -t rsa -b 2048 -N ''
	chmod a+r id_rsa*

build: id_rsa
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

clean:
	-docker rmi -f ${IMAGE}
	-rm -f id_rsa*

stop:
	for img in $$(docker ps -q -f name=${IMAGE}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${IMAGE})" == "" ] && \
          echo -e "\n${IMAGE} is *STOPPED*\n") || \
          echo -e "\n${IMAGE} is *RUNNING*\n"

.PHONY: clean image

