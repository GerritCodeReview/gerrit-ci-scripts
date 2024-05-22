include ../chrome-vers.mk

NO_CACHE=false
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-agent-bazel-docker:debian-bullseye
PLATFORMS=linux/amd64,linux/arm64
BUILDER=gerrit-build-agent

# Targets

build:
	docker buildx create --name $(BUILDER) --platform "$(PLATFORMS)" --driver docker-container --use
	docker buildx inspect --bootstrap
	@for chrome_ver in $(CHROME_VERS); \
        do \
		cat Dockerfile | CHROME_VER=$$chrome_ver envsubst > Dockerfile-subst ; \
		docker buildx build --platform "$(PLATFORMS)" -f Dockerfile-subst --no-cache=$(NO_CACHE) -t ${IMAGE}-$$chrome_ver . ; \
	done

publish:
	@for chrome_ver in $(CHROME_VERS); \
        do \
		cat Dockerfile | CHROME_VER=$$chrome_ver envsubst > Dockerfile-subst ; \
		docker buildx build --platform "$(PLATFORMS)" -f Dockerfile-subst --no-cache=$(NO_CACHE) -t ${IMAGE}-$$chrome_ver . --push ; \
	done

clean:
	@for chrome_ver in $(CHROME_VERS); \
        do \
		docker rmi -f ${IMAGE}-$$chrome_ver ; \
	done
	echo y | docker buildx prune
	docker buildx stop $(BUILDER)
	docker buildx rm $(BUILDER)

.PHONY: clean image publish

