NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-buck
VERSION=ubuntu15.04-chrome60

# Targets

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE}:${VERSION} .

publish:
	docker push ${IMAGE}:${VERSION}

clean:
	docker rmi -f ${IMAGE}:${VERSION}

.PHONY: clean image publish

