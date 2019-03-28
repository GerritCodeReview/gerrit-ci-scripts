NO_CACHE=false
DEBIAN_VER ?= jessie
IMAGE=gerritforge/gerrit-ci-slave-buck:debian-$(DEBIAN_VER)
NODE_VER ?= 10
WCT_VER ?= 6.8.0

# Targets

build: build_jessie build_stretch

publish: publish_jessie publish_stretch

clean: clean_jessie clean_stretch

build_jessie publish_jessie clean_jessie: DEBIAN_VER=jessie

build_stretch publish_stretch clean_stretch: DEBIAN_VER=stretch

publish_jessie: build_jessie

publish_stretch: build_stretch

build_jessie build_stretch: Makefile Dockerfile
	@echo "Building Docker for $(DEBIAN_VER) / Node $(NODE_VER) / WCT $(WCT_VER)"
	@echo "==================================================="
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) NODE_VER=$(NODE_VER) WCT_VER=$(WCT_VER) envsubst > Dockerfile-$(DEBIAN_VER)-$(NODE_VER)-$(WCT_VER)
	docker build -f Dockerfile-$(DEBIAN_VER)-$(NODE_VER)-$(WCT_VER) --no-cache=$(NO_CACHE) -t $(IMAGE) .

publish_jessie publish_stretch:
	docker push $(IMAGE)

clean_jessie clean_stretch:
	docker rmi -f $(IMAGE)
	-rm -f id_rsa*

.PHONY: clean image publish
