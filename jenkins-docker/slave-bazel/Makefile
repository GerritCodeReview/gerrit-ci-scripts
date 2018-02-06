NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian

# Targets

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

