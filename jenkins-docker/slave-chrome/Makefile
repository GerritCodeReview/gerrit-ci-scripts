NO_CACHE ?= false
DEBIAN_VER ?= sid
CHROME_VER ?= 69.0.3497.92
IMAGE=gerritforge/gerrit-ci-slave-chrome:$(DEBIAN_VER)-$(CHROME_VER)

build: build_jessie build_stretch

publish: publish_jessie publish_stretch

clean: clean_jessie clean_stretch

build_jessie publish_jessie clean_jessie: DEBIAN_VER=jessie

build_stretch publish_stretch clean_stretch: DEBIAN_VER=stretch

build_sid publish_sid clean_sid: DEBIAN_VER=sid

publish_jessie: build_jessie

publish_stretch: build_stretch

publish_sid: build_sid

build_sid build_jessie build_stretch: Makefile Dockerfile
	@echo "Building Docker for $(DEBIAN_VER) / Chrome v$(CHROME_VER)"
	@echo "==================================================="
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) CHROME_VER=$(CHROME_VER) envsubst > Dockerfile-$(DEBIAN_VER)-$(CHROME_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-$(CHROME_VER) -t $(IMAGE) .

publish_sid publish_jessie publish_stretch:
	docker push $(IMAGE)

clean_sid clean_jessie clean_stretch:
	docker rmi -f $(IMAGE)

.PHONY: clean jessie stretch

