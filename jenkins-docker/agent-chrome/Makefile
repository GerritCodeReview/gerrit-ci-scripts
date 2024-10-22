NO_CACHE ?= false
DEBIAN_VER ?= bookworm
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-agent-chrome:$(DEBIAN_VER)
CHROME_VERS = latest 69.0.3497.92

build: Makefile Dockerfile
	# Due to issues with echo on Mac (see https://stackoverflow.com/questions/11675070/makefile-echo-n-not-working)
	# we use printf as a alternative.
	printf "CHROME_VERS ?= latest" > ../chrome-vers.mk; \
	for chrome_ver in $(CHROME_VERS); \
	do \
		echo "Building Docker for $(DEBIAN_VER) / Chrome v$$chrome_ver"; \
		echo "========================================================"; \
		cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) CHROME_VER=$$chrome_ver envsubst > Dockerfile-$(DEBIAN_VER)-$$chrome_ver; \
		docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER)-$$chrome_ver -t "$(IMAGE)-$$chrome_ver" .;  \
		chrome_curr_ver=$$(docker run --entrypoint=/usr/bin/google-chrome -ti $(IMAGE)-$$chrome_ver --version | awk '{print $$3}'); \
		printf " $$chrome_curr_ver" >> ../chrome-vers.mk; \
	done; \
	printf "" >> ../chrome-vers.mk

publish:
	@for chrome_ver in $(CHROME_VERS); \
	do \
		echo "Pushing $(IMAGE)-$$chrome_ver"; \
		docker push $(IMAGE)-$$chrome_ver; \
		chrome_curr_ver=$$(docker run --entrypoint=/usr/bin/google-chrome -ti $(IMAGE)-$$chrome_ver --version | awk '{print $$3}'); \
		docker tag $(IMAGE)-$$chrome_ver $(IMAGE)-$$chrome_curr_ver; \
		echo "Pushing $(IMAGE)-$$chrome_curr_ver"; \
		docker push $(IMAGE)-$$chrome_curr_ver; \
	done

clean:
	for chrome_ver in $(CHROME_VERS); \
	do \
		docker rmi -f $(IMAGE)-$$chrome_ver; \
	done

.PHONY: build publish clean
