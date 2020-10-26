NO_CACHE=true
IMAGE=gerritforge/gerrit-ci-slave-bazel:debian-buster-nocache-80.0.3987.149
CONTAINER=release

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

# Dockerfile shows from where to manually execute the release script once in.
# E.g.: /usr/local/bin/gerrit-release.sh stable-3.3 3.3.0-rc3 3.3.0-SNAPSHOT
run:
	docker run -it --name ${CONTAINER} ${IMAGE}

rerun: clean-container run

publish:
	docker push ${IMAGE}

clean-image:
	docker rmi -f ${IMAGE}

clean-container:
	docker rm -f ${CONTAINER}

.PHONY: clean-image clean-container publish
