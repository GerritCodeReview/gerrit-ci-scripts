include ../chrome-vers.mk

NO_CACHE=false
SCM_VER=${shell git describe --always HEAD}
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-slave-bazel:debian-buster-${SCM_VER}

# Targets

build:
	@for chrome_ver in $(CHROME_VERS); \
        do \
		cat Dockerfile | SCM_VER=$(SCM_VER) CHROME_VER=$$chrome_ver envsubst > Dockerfile-subst ; \
		docker build --no-cache=$(NO_CACHE) -f Dockerfile-subst -t ${IMAGE}-$$chrome_ver . ; \
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

