include ../chrome-vers.mk

NO_CACHE=false
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-agent-bazel:debian-bookworm

# Targets

build:
	@for chrome_ver in $(CHROME_VERS); \
        do \
		docker build --build-arg CHROME_VER=$$chrome_ver --no-cache=$(NO_CACHE) -f Dockerfile -t ${IMAGE}-$$chrome_ver . ; \
	done

publish:
	@for chrome_ver in $(CHROME_VERS); \
        do \
		docker push ${IMAGE}-$$chrome_ver ; \
	done

clean:
	@for chrome_ver in $(CHROME_VERS); \
        do \
		docker rmi -f ${IMAGE}-$$chrome_ver ; \
	done

.PHONY: clean image publish

