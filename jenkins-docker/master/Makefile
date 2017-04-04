NO_CACHE=false
IMAGE=gerritforge/gerrit-ci
USE_SECURITY=false
OAUTH_ID=clientid
OAUTH_SECRET=secret
JENKINS_API_USER=user
JENKINS_API_PASSWORD=pass

# Targets

start: build
	-docker rm ${IMAGE}
	docker run --name ${IMAGE} -d -e USE_SECURITY=${USE_SECURITY} \
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
	for img in $$(docker ps -q -f name=${IMAGE}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${IMAGE})" == "" ] && \
          echo -e "\n${IMAGE} is *STOPPED*\n") || \
          echo -e "\n${IMAGE} is *RUNNING*\n"

.PHONY: clean image publish

