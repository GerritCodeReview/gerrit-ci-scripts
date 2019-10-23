NO_CACHE=false
SCM_VER=${shell git describe --always HEAD}
IMAGE=gerritforge/gerrit-ci-slave-mvn-${SCM_VER}

# Targets

build:
	SCM_VER=$(SCM_VER) envsubst Dockerfile > Dockerfile.out
	docker build -f Dockerfile.out --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

