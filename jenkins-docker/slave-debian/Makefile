NO_CACHE ?= false
IMAGE=gerritforge/gerrit-ci-slave-debian

build: build_stretch build_jessie

publish: publish_stretch publish_jessie

clean: clean_stretch clean_jessie

build_jessie publish_jessie clean_jessie: DEBIAN_VER=jessie

build_stretch publish_stretch clean_stretch: DEBIAN_VER=stretch

publish_jessie: build_jessie

publish_stretch: build_stretch

build_jessie build_stretch:  id_rsa.pub
	@echo "Building Docker for Debian:$(DEBIAN_VER)"
	@echo "========================================"
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t ${IMAGE}:$(DEBIAN_VER) .

publish_jessie publish_stretch:
	docker push ${IMAGE}:$(DEBIAN_VER)

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

clean_stretch clean_jessie:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub publish

