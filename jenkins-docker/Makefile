NO_CACHE=false
IMAGE=gerrit-ci
PORT=8080
USE_SECURITY=false
OAUTH_ID=clientid
OAUTH_SECRET=secret
JENKINS_API_USER=user
JENKINS_API_PASSWORD=pass

# Targets

start: build
	-docker rm ${IMAGE}
	docker run --name ${IMAGE} -d -e USE_SECURITY=${USE_SECURITY} -e OAUTH_ID=${OAUTH_ID} -e OAUTH_SECRET=${OAUTH_SECRET} -e JENKINS_API_USER=${JENKINS_API_USER} -e JENKINS_API_PASSWORD=${JENKINS_API_PASSWORD} -p ${PORT}:8080 ${IMAGE}

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

clean:
	docker rmi ${IMAGE}

stop:
	for img in $$(docker ps -q -f name=${IMAGE}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${IMAGE})" == "" ] && echo -e "\n${IMAGE} is *STOPPED*\n") || echo -e "\n${IMAGE} is *RUNNING*\n"

.PHONY: clean image

