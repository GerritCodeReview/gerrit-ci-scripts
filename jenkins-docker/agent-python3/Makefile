NO_CACHE ?= false
DEBIAN_VER ?= bookworm
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-agent-python3:$(DEBIAN_VER)

build:  Dockerfile Makefile
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t $(IMAGE) .

publish: build
	docker push $(IMAGE)

clean:
	docker rmi -f $(IMAGE)
	-rm -f id_rsa*

.PHONY: clean

