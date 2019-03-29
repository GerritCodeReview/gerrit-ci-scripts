NO_CACHE=false
DEBIAN_VER ?= jessie
IMAGE=gerritforge/gerrit-release-bazel:debian-$(DEBIAN_VER)

# Targets

build: build_jessie build_stretch

publish: publish_jessie publish_stretch

clean: clean_jessie clean_stretch

build_jessie publish_jessie clean_jessie: DEBIAN_VER=jessie

build_stretch publish_stretch clean_stretch: DEBIAN_VER=stretch

publish_jessie: build_jessie

publish_stretch: build_stretch

build_jessie build_stretch:  Dockerfile Makefile
	@echo "Building Docker for $(DEBIAN_VER)"
	@echo "==================================================="
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) envsubst '$$DEBIAN_VER' > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t $(IMAGE) .

publish_jessie publish_stretch:
	docker push $(IMAGE)

clean_jessie clean_stretch:
	docker rmi -f $(IMAGE)
	-rm -f id_rsa*

.PHONY: clean image publish
