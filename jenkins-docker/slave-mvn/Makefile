NO_CACHE=false
IMAGE=gerrit-ci-slave-mvn

# Targets

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image

