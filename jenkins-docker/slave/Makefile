NO_CACHE=false
IMAGE=gerrit-ci-slave

# Targets

start: build
	-docker rm ${IMAGE}
	docker run --name ${IMAGE} -d ${IMAGE}

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

build:  id_rsa.pub
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

clean:
	docker rmi ${IMAGE}

stop:
	for img in $$(docker ps -q -f name=${IMAGE}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${IMAGE})" == "" ] && \
          echo -e "\n${IMAGE} is *STOPPED*\n") || \
          echo -e "\n${IMAGE} is *RUNNING*\n"

.PHONY: clean image id_rsa.pub

