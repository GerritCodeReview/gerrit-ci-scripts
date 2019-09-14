include ../chrome-vers.mk

NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-bazel-docker:debian-buster

# Targets

build:
	@for chrome_ver in $(CHROME_VERS); \
        do \
		cat Dockerfile | CHROME_VER=$$chrome_ver envsubst > Dockerfile-subst ; \
		docker build -f Dockerfile-subst --no-cache=$(NO_CACHE) -t ${IMAGE}-$$chrome_ver . ; \
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

