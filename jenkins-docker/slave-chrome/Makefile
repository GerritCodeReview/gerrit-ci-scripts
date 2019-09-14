NO_CACHE ?= false
DEBIAN_VER ?= buster
CHROME_VER ?= 69.0.3497.92
IMAGE=gerritforge/gerrit-ci-slave-chrome:$(DEBIAN_VER)-$(CHROME_VER)

build: build_buster

publish: publish_buster

clean: clean_buster

build_buster publish_buster clean_buster: DEBIAN_VER=buster

publish_buster: build_buster

build_buster: Makefile Dockerfile
	@echo "Building Docker for $(DEBIAN_VER) / Chrome v$(CHROME_VER)"
	@echo "==================================================="
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) CHROME_VER=$(CHROME_VER) envsubst > Dockerfile-$(DEBIAN_VER)-$(CHROME_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-$(CHROME_VER) -t $(IMAGE) .

publish_buster:
	docker push $(IMAGE)

clean_buster:
	docker rmi -f $(IMAGE)

.PHONY: clean buster

