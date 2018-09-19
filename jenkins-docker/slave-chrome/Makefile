NO_CACHE ?= false
DEBIAN_VER ?= jessie
CHROME_VER ?= 69.0.3497.92
IMAGE=gerritforge/gerrit-ci-slave-chrome:$(DEBIAN_VER)-$(CHROME_VER)

build: build_jessie build_stretch

publish: publish_jessie publish_stretch

build_jessie: jessie docker_build

build_stretch: stretch docker_build

publish_jessie: jessie docker_publish

publish_stretch: stretch docker_publish

docker_build: Makefile Dockerfile
	@echo "Building Docker for $(DEBIAN_VER) / Chrome v$(CHROME_VER)"
	@echo "==================================================="
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) CHROME_VER=$(CHROME_VER) envsubst > Dockerfile-$(DEBIAN_VER)-$(CHROME_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-$(CHROME_VER) -t $(IMAGE) .

docker_publish: build
	docker push $(IMAGE)

clean:
	docker rmi -f $(IMAGE)

jessie stretch:
	$(eval DEBIAN_VER := $@)

.PHONY: clean jessie stretch

