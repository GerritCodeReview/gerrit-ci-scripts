NO_CACHE ?= false
IMAGE=gerritforge/gerrit-ci-slave-debian
VERSIONS=jessie stretch

build publish:
	for ver in $(VERSIONS); do make $@_$$ver; done

build_jessie: jessie docker_build

build_stretch: stretch docker_build

publish_stretch: stretch docker_publish

build_jessie: jessie docker_build

publish_jessie: jessie docker_publish

docker_build:
	@echo "Building Docker for Debian:$(DEBIAN_VER)"
	@echo "========================================"
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t ${IMAGE}:$(DEBIAN_VER) .

jessie stretch:
	$(eval DEBIAN_VER := $@)

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

docker_publish: docker_build
	docker push ${IMAGE}:$(DEBIAN_VER)

clean:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub publish docker_build

