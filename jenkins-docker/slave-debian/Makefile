NO_CACHE ?= false
IMAGE=gerritforge/gerrit-ci-slave-debian
CHROME ?= 65.0.3325.181

build: build_stretch build_jessie

publish: publish_stretch publish_jessie

build_stretch: stretch docker_build

publish_stretch: stretch docker_publish

build_jessie: jessie docker_build

publish_jessie: jessie docker_publish

docker_build:  id_rsa.pub
	@echo "Building Docker for Debian:$(DEBIAN_VER)"
	@echo "========================================"
	cat Dockerfile | CHROME=$(CHROME) DEBIAN_VER=$(DEBIAN_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) chrome=$(CHROME) -f Dockerfile-$(DEBIAN_VER) -t ${IMAGE}:$(DEBIAN_VER)-chrome-$(CHROME) .

jessie stretch:
	$(eval DEBIAN_VER := $@)

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

docker_publish: docker_build
	docker push ${IMAGE}:$(DEBIAN_VER)

clean:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub publish

