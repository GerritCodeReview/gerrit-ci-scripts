include ../chrome-vers.mk

NO_CACHE ?= false
DEBIAN_VER ?= buster
IMAGE=gerritforge/gerrit-ci-slave-chrome:$(DEBIAN_VER)

build: Makefile Dockerfile
	@for chrome_ver in $(CHROME_VERS); \
	do \
		echo "Building Docker for $(DEBIAN_VER) / Chrome v$$chrome_ver"; \
		echo "========================================================"; \
		cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) CHROME_VER=$$chrome_ver envsubst > Dockerfile-$(DEBIAN_VER)-$$chrome_ver; \
		docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-$$chrome_ver -t "$(IMAGE)-$$chrome_ver" .;  \
	done

publish:
	for chrome_ver in $(CHROME_VERS); \
	do \
		docker push $(IMAGE)-$$chrome_ver; \
	done

clean:
	for chrome_ver in $(CHROME_VERS); \
	do \
		docker rmi -f $(IMAGE)-$$chrome_ver; \
	done

.PHONY: build publish clean

