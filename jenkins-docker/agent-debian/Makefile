NO_CACHE ?= false
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-ci-agent-debian
MAVEN_VER=3.9.4
GIT_VER=2.47.0
DEBIAN_VER=bullseye

build:
	@echo "Building Docker for Debian:$(DEBIAN_VER)"
	@echo "========================================"
	cat Dockerfile | DEBIAN_VER=$(DEBIAN_VER) MAVEN_VER=$(MAVEN_VER) GIT_VER=$(GIT_VER) envsubst > Dockerfile-$(DEBIAN_VER)
	docker build --no-cache=$(NO_CACHE) -f Dockerfile-$(DEBIAN_VER) -t ${IMAGE}:$(DEBIAN_VER) .

publish:
	docker push ${IMAGE}:$(DEBIAN_VER)

clean:
	docker rmi -f ${IMAGE}

.PHONY: clean publish
