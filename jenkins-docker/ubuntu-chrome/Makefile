NO_CACHE=false
IMAGE=gerritforge/ubuntu
VERSION=15.04-chrome60

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE}:${VERSION} .

publish:
	docker push ${IMAGE}:${VERSION}

clean:
	docker rmi -f ${IMAGE}:${VERSION}

.PHONY: build clean publish

