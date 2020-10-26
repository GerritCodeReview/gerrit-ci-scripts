NO_CACHE=true
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian-buster-nocache-80.0.3987.149

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean publish
