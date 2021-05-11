NO_CACHE ?= false
NODE_VER ?= 10
WCT_VER ?= 6.8.0
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-slave-node-wct:$(NODE_VER)-$(WCT_VER)-latest

build:  Dockerfile Makefile
	cat Dockerfile | NODE_VER=$(NODE_VER) WCT_VER=$(WCT_VER) envsubst > Dockerfile-$(NODE_VER)-$(WCT_VER)-latest
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(NODE_VER)-$(WCT_VER)-latest -t $(IMAGE) .

publish: build
	docker push $(IMAGE)

clean:
	docker rmi -f $(IMAGE)
	-rm -f id_rsa*

.PHONY: clean

