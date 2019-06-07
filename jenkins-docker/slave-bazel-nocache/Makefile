NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian-stretch-nocache
BAZEL_VER=0.25.0
BUILDIFIER_VER=0.22.0
GO_VER=1.12.2

# Targets

build:
	docker build --no-cache=$(NO_CACHE) \
        --build-arg BAZEL_VER=${BAZEL_VER} \
        --build-arg BUILDIFIER_VER=${BUILDIFIER_VER} \
        --build-arg GO_VER=${GO_VER} \
        -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

