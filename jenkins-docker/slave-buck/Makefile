NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave-buck:debian-jessie
CHROME_VER ?= 66.0.3359.181

# Targets

build:
	cat Dockerfile | CHROME_VER=$(CHROME_VER) envsubst > Dockerfile-$(CHROME_VER)
	docker build -f Dockerfile-$(CHROME_VER) --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean image publish

