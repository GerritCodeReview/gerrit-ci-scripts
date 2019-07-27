NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian-stretch-nocache
BAZEL_VER=0.29.0
BUILDIFIER_VER=0.26.0
BAZELISK_VER=0.0.7

# Targets

build:
	docker build --no-cache=$(NO_CACHE) \
        --build-arg BAZEL_VER=${BAZEL_VER} \
        --build-arg BUILDIFIER_VER=${BUILDIFIER_VER} \
        --build-arg BAZELISK_VER=${BAZELISK_VER} \
        -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

