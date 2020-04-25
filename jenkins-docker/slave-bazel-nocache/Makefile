NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian-stretch-nocache
BAZEL_VER=3.1.0
BUILDIFIER_VER=2.2.1
BAZELISK_VER=1.4.0
NODE_VER=10
WCT_VER=6.8.0

# Targets

build:
	cat Dockerfile | \
        BAZEL_VER=${BAZEL_VER} \
        BUILDIFIER_VER=${BUILDIFIER_VER} \
        BAZELISK_VER=${BAZELISK_VER} \
        NODE_VER=${NODE_VER} \
        WCT_VER=${WCT_VER} envsubst > Dockerfile-subst
	docker build --no-cache=$(NO_CACHE) \
        -f Dockerfile-subst \
        -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

