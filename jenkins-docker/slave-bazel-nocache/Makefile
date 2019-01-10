NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian-jessie-nocache
BAZEL_VER=0.19.0
BUILDIFIER_VER=0.20.0

# Targets

build:
	docker build --no-cache=$(NO_CACHE) \
        --build-arg BAZEL_VER=${BAZEL_VER} \
        --build-arg BUILDIFIER_VER=${BUILDIFIER_VER} \
        -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

