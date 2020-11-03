NO_CACHE ?= false
IMAGE=gerritforge/gerrit-ci-slave-debian
MAVEN_VER=3.6.3
GIT_VER=2.26.2
DEBIAN_VER=buster

build:  id_rsa.pub
	@echo "Building Docker for Debian:$(DEBIAN_VER)"
	@echo "========================================"
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) MAVEN_VER=$(MAVEN_VER) GIT_VER=$(GIT_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t ${IMAGE}:$(DEBIAN_VER) .

publish:
	docker push ${IMAGE}:$(DEBIAN_VER)

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

clean:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub publish
