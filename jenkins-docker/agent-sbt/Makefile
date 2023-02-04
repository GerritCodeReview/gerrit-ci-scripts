NO_CACHE=false
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-agent-bazel-sbt

# Targets

build:
	docker build --platform=linux/amd64 --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

