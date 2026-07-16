include ../chrome-vers.mk

NO_CACHE ?= false
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-agent-node

build:  Dockerfile Makefile
	@for chrome_ver in $(CHROME_VERS); \
	do \
		cat Dockerfile | CHROME_VER=$$chrome_ver envsubst > Dockerfile-$$chrome_ver ; \
		docker build --no-cache=$(NO_CACHE) -f Dockerfile-$$chrome_ver -t $(IMAGE):$$chrome_ver . ; \
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

