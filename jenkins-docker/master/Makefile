NO_CACHE=false
IMAGE=gerritforge/gerrit-ci
CONTAINER_NAME=gerrit-ci
USE_SECURITY=false
OAUTH_ID=clientid
OAUTH_SECRET=secret
JENKINS_API_USER=user
JENKINS_API_PASSWORD=pass

JENKINS_WAR_VER=2.107.3
JENKINS_WAR_SHA=fc2d2eac8d3a04ffe6b4dc14eac52b2412f6c212

# Targets

start: build
	-docker rm ${CONTAINER_NAME}
	docker run --name ${CONTAINER_NAME} -d -e USE_SECURITY=${USE_SECURITY} \
          -e OAUTH_ID=${OAUTH_ID} \
          -e OAUTH_SECRET=${OAUTH_SECRET} \
          -e JENKINS_API_USER=${JENKINS_API_USER} \
          -e JENKINS_API_PASSWORD=${JENKINS_API_PASSWORD} \
          --net=host ${IMAGE}

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

stop:
	for img in $$(docker ps -q -f name=${CONTAINER_NAME}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${CONTAINER_NAME})" == "" ] && \
          echo -e "\n${CONTAINER_NAME} is *STOPPED*\n") || \
          echo -e "\n${CONTAINER_NAME} is *RUNNING*\n"

.PHONY: clean image publish

