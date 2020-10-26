NO_CACHE=true
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian-buster-nocache-80.0.3987.149
CONTAINER=release

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

# Dockerfile shows from where to manually execute the release script once in.
# E.g.: /usr/local/bin/gerrit-release.sh stable-3.3 3.3.0-rc3 3.3.0-SNAPSHOT
rerun: container
	docker run -it --name ${CONTAINER} ${IMAGE}

publish:
	docker push ${IMAGE}

clean: container
	docker rmi -f ${IMAGE}

container:
	docker rm -f ${CONTAINER}

.PHONY: clean container publish
