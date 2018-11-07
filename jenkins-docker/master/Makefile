NO_CACHE=false
ORGANISATION=gerritforge
NAME=gerrit-ci
USE_SECURITY=false
OAUTH_ID=clientid
OAUTH_SECRET=secret
JENKINS_API_USER=user
JENKINS_API_PASSWORD=pass
JENKINS_WAR_VER=2.60.3
JENKINS_WAR_SHA=e62d9ed7eb3d29b08719e639c959cd328776ba50
IMAGE=${ORGANISATION}/${NAME}:${JENKINS_WAR_VER}

# Targets

start: build
	-docker rm ${NAME}
	docker run --name ${NAME} -d -e USE_SECURITY=${USE_SECURITY} \
          --privileged \
          -e OAUTH_ID=${OAUTH_ID} \
          -e OAUTH_SECRET=${OAUTH_SECRET} \
          -e JENKINS_API_USER=${JENKINS_API_USER} \
          -e JENKINS_API_PASSWORD=${JENKINS_API_PASSWORD} \
          -v $$(pwd)/jenkins_home:/var/jenkins_home \
          -v /var/run/docker.sock:/var/run/docker.sock \
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
	for img in $$(docker ps -q -f name=${NAME}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${NAME})" == "" ] && \
          echo -e "\n${NAME} is *STOPPED*\n") || \
          echo -e "\n${NAME} is *RUNNING*\n"

.PHONY: clean image publish

