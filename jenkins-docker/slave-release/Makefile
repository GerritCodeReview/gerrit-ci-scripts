NO_CACHE=true
PREFIX=gerritforge
IMAGE=${PREFIX}/gerrit-release-bazel:debian-buster
CONTAINER=release

######################################################
# Customize the parameters below for running a release
######################################################

# Branch from where the release will be cut
BRANCH=stable-3.3

# Release number
RELEASE=3.3.0

# Next SNAPSHOT after the release
SNAPSHOT=3.3.1-SNAPSHOT

# Release manager's GNUPG keyring
GNUPG=${HOME}/.gnupg

# Release manager's local git config for authentication
GIT_CONFIG=${HOME}/.gitconfig

# Release manager's local git cookies file
GIT_COOKIES=${HOME}/.gitcookies

######################################################
# Targets for building the image and making a release
######################################################

run:
	docker run --rm -it --name ${CONTAINER} ${IMAGE} ${BRANCH} ${RELEASE} ${SNAPSHOT} \
		-u jenkins \
		-v `pwd`/.gerritcodereview:/home/jenkins/.gerritcodereview \
		-v ${HOME}/.m2:/home/jenkins/.m2 \
		-v ${GNUPG}:/home/jenkins/.gnupg \
		-v ${GIT_CONFIG}:/home/jenkins/.gitconfig.template \
		-v ${GIT_COOKIES}:/home/jenkins/.gitcookies

pull:
	docker pull gerritforge/gerrit-ci-slave-bazel:debian-buster-nocache-90.0.4430

build: pull
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish: build
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

.PHONY: run pull build publish clean
