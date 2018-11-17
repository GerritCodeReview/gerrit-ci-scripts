NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-buck:debian-jessie
NODE_VER ?= 10
WCT_VER ?= 6.9.0

# Targets

build:
	cat Dockerfile | NODE_VER=$(NODE_VER) WCT_VER=$(WCT_VER) envsubst > Dockerfile-$(NODE_VER)-$(WCT_VER)
	docker build -f Dockerfile-$(NODE_VER)-$(WCT_VER) --no-cache=$(NO_CACHE) -t $(IMAGE) .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

