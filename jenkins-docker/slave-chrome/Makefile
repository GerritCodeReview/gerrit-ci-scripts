NO_CACHE ?= false
DEBIAN_VER ?= buster
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-slave-chrome:$(DEBIAN_VER)-latest

build: Makefile Dockerfile
	echo "Building Docker for $(DEBIAN_VER)"
	echo "========================================================"
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) envsubst > Dockerfile-$(DEBIAN_VER)-latest
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-latest -t "$(IMAGE)" .

publish:
	docker push $(IMAGE)

clean:
	docker rmi -f $(IMAGE)

.PHONY: build publish clean

