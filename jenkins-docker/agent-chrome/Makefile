NO_CACHE ?= false
DEBIAN_VER ?= buster
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-agent-chrome:$(DEBIAN_VER)
CHROME_VERS = latest 69.0.3497.92

build: Makefile Dockerfile
	@for chrome_ver in $(CHROME_VERS); \
	do \
		echo "Building Docker for $(DEBIAN_VER) / Chrome v$$chrome_ver"; \
		echo "========================================================"; \
		cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) CHROME_VER=$$chrome_ver envsubst > Dockerfile-$(DEBIAN_VER)-$$chrome_ver; \
		docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-$$chrome_ver -t "$(IMAGE)-$$chrome_ver" .;  \
	done

publish:
	echo -n "CHROME_VERS ?=" > ../chrome-vers.mk; \
	for chrome_ver in $(CHROME_VERS); \
	do \
		echo "Pushing $(IMAGE)-$$chrome_ver"; \
		docker push $(IMAGE)-$$chrome_ver; \
		chrome_curr_ver=$$(docker run --entrypoint=/usr/bin/google-chrome -ti $(IMAGE)-$$chrome_ver --version | awk '{print $$3}'); \
		docker tag $(IMAGE)-$$chrome_ver $(IMAGE)-$$chrome_curr_ver; \
		echo "Pushing $(IMAGE)-$$chrome_curr_ver"; \
		docker push $(IMAGE)-$$chrome_curr_ver; \
		echo -n " $$chrome_curr_ver" >> ../chrome-vers.mk; \
	done; \
	echo "" >> ../chrome-vers.mk

clean:
	for chrome_ver in $(CHROME_VERS); \
	do \
		docker rmi -f $(IMAGE)-$$chrome_ver; \
	done

.PHONY: build publish clean

