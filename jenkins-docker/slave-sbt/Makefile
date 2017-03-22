NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-bazel-sbt

# Targets

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image

