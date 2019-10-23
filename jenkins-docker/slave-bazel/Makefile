include ../chrome-vers.mk

NO_CACHE=false
SCM_VER=${shell git describe --always HEAD}
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian-buster-${SCM_VER}

# Targets

build:
<<<<<<< HEAD
	@for chrome_ver in $(CHROME_VERS); \
        do \
		cat Dockerfile | CHROME_VER=$$chrome_ver envsubst > Dockerfile-subst ; \
		docker build --no-cache=$(NO_CACHE) -f Dockerfile-subst -t ${IMAGE}-$$chrome_ver . ; \
	done
=======
	SCM_VER=$(SCM_VER) envsubst Dockerfile > Dockerfile.out
	docker build -f Dockerfile.out --no-cache=$(NO_CACHE) -t ${IMAGE} .
>>>>>>> 7deeb7c5be (Use immutable Docker image versions)

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

