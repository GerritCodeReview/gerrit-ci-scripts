NO_CACHE ?= false
DEBIAN_VER ?= stretch
CHROME_VER ?= 80.0.3987.149
IMAGE=gerritforge/gerrit-ci-slave-chrome:$(DEBIAN_VER)-$(CHROME_VER)

build: build_stretch

publish: publish_stretch

clean: clean_stretch

build_stretch publish_stretch clean_stretch: DEBIAN_VER=stretch

publish_stretch: build_stretch

build_stretch: Makefile Dockerfile
	@echo "Building Docker for $(DEBIAN_VER) / Chrome v$(CHROME_VER)"
	@echo "==================================================="
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) CHROME_VER=$(CHROME_VER) envsubst > Dockerfile-$(DEBIAN_VER)-$(CHROME_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-$(CHROME_VER) -t $(IMAGE) .

publish_stretch:
	docker push $(IMAGE)

clean_stretch:
	docker rmi -f $(IMAGE)

.PHONY: clean stretch

