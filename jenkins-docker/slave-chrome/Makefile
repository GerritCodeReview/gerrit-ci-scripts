NO_CACHE ?= false
DEBIAN_VER ?= jessie
CHROME_VER ?= 69.0.3497.92
IMAGE=gerritforge/gerrit-ci-slave-chrome:$(DEBIAN_VER)-$(CHROME_VER)

build: build_jessie build_stretch

publish: publish_jessie publish_stretch

clean: clean_jessie clean_stretch

build_jessie publish_jessie clean_jessie: DEBIAN_VER=jessie

build_stretch publish_stretch clean_stretch: DEBIAN_VER=stretch

publish_jessie: build_jessie

publish_stretch: build_stretch

build_jessie build_stretch: Makefile Dockerfile
	@echo "Building Docker for $(DEBIAN_VER) / Chrome v$(CHROME_VER)"
	@echo "==================================================="
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) CHROME_VER=$(CHROME_VER) envsubst > Dockerfile-$(DEBIAN_VER)-$(CHROME_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-$(CHROME_VER) -t $(IMAGE) .

publish_jessie publish_stretch:
	docker push $(IMAGE)

clean_jessie clean_stretch:
	docker rmi -f $(IMAGE)

.PHONY: clean jessie stretch

