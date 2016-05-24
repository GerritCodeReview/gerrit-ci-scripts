NO_CACHE=false
IMAGE=gerrit-ci
PORT=8080

start: build
	-docker rm ${IMAGE}
	docker run --name ${IMAGE} -d -p ${PORT}:8080 ${IMAGE}

build:  stop
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

clean:
	docker rmi ${IMAGE}

stop:
	for img in $$(docker ps -q -f name=${IMAGE}); do docker kill $$img; done

restart: stop start

status:
	([ "$$(docker ps -q -f name=${IMAGE})" == "" ] && echo -e "\n${IMAGE} is *STOPPED*\n") || echo -e "\n${IMAGE} is *RUNNING*\n"

.PHONY: clean image

