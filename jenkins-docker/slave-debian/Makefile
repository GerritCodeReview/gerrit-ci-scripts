NO_CACHE ?= false
IMAGE=gerritforge/gerrit-ci-slave-debian

build: build_stretch

publish: publish_stretch

clean: clean_stretch

build_stretch publish_stretch clean_stretch: DEBIAN_VER=stretch

publish_stretch: build_stretch

build_stretch:  id_rsa.pub
	@echo "Building Docker for Debian:$(DEBIAN_VER)"
	@echo "========================================"
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t ${IMAGE}:$(DEBIAN_VER) .

publish_stretch:
	docker push ${IMAGE}:$(DEBIAN_VER)

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

clean_stretch:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub publish

