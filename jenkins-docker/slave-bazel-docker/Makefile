NO_CACHE=false
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-slave-bazel-docker:debian-buster-latest

# Targets

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE}

publish:
	docker push ${IMAGE}-latest

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

