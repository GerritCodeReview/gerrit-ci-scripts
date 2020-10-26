NO_CACHE=false
IMAGE=gerritforge/gerrit-release-bazel:debian-buster

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean publish
