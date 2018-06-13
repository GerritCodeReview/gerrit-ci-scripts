NO_CACHE ?= false
IMAGE=gerritforge/gerrit-ci-slave-debian

build: build_stretch build_jessie

build_stretch: stretch docker_build

build_jessie: jessie docker_build

docker_build:  id_rsa.pub
	@echo "Building Docker for Debian:$(DEBIAN_VER)"
	@echo "========================================"
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t ${IMAGE}:$(DEBIAN_VER) .

jessie stretch:
	$(eval DEBIAN_VER := $@)

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub publish

