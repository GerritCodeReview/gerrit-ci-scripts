NO_CACHE ?= false
IMAGE=gerritforge/gerrit-ci-slave-debian
MAVEN_VER=3.6.3
GIT_VER=2.26.2

build: build_stretch build_buster

publish: publish_stretch publish_buster

clean: clean_stretch clean_buster

build_stretch publish_stretch clean_stretch: DEBIAN_VER=stretch
build_buster publish_buster clean_buster: DEBIAN_VER=buster

publish_stretch: build_stretch
publish_buster: build_buster

build_stretch build_buster:  id_rsa.pub
	@echo "Building Docker for Debian:$(DEBIAN_VER)"
	@echo "========================================"
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) MAVEN_VER=$(MAVEN_VER) GIT_VER=$(GIT_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t ${IMAGE}:$(DEBIAN_VER) .

publish_stretch publish_buster:
	docker push ${IMAGE}:$(DEBIAN_VER)

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

clean_stretch clean_buster:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub publish
