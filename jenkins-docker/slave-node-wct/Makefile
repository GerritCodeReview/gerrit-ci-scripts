include ../chrome-vers.mk

NO_CACHE ?= false
NODE_VER ?= 10
WCT_VER ?= 6.8.0
IMAGE=gerritforge/gerrit-ci-slave-node-wct:$(NODE_VER)-$(WCT_VER)

build:  Dockerfile Makefile
	@for chrome_ver in $(CHROME_VERS); \
	do \
		cat Dockerfile | NODE_VER=$(NODE_VER) WCT_VER=$(WCT_VER) CHROME_VER=$$chrome_ver envsubst > Dockerfile-$(NODE_VER)-$(WCT_VER)-$$chrome_ver ; \
		docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(NODE_VER)-$(WCT_VER)-$$chrome_ver -t $(IMAGE)-$$chrome_ver . ; \
	done

publish: build
	@for chrome_ver in $(CHROME_VERS); \
	do \
		docker push $(IMAGE)-$$chrome_ver; \
	done

clean:
	@for chrome_ver in $(CHROME_VERS); \
        do \
		docker rmi -f $(IMAGE); \
	done
	-rm -f id_rsa*

.PHONY: clean

