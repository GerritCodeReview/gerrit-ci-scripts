NO_CACHE=true
IMAGE=gerritforge/gerrit-release-bazel:debian-buster
CONTAINER=release

######################################################
# Customize the parameters below for running a release
######################################################

# Gerrit repository URL
REPOSITORY_URL=https://gerrit.googlesource.com/gerrit

# Branch from where the release will be cut
BRANCH=stable-3.3

# Release number
RELEASE=3.3.0

# Next SNAPSHOT after the release
SNAPSHOT=3.3.1-SNAPSHOT

# Release manager's GNUPG keyring
GNUPG=${HOME}/.gnupg

# Release manager's local git config and cookies for authentication
GIT_CONFIG=${HOME}/.gitconfig
GIT_COOKIES=${HOME}/.gitcookies

######################################################
# Targets for building the image and making a release
######################################################

run:
	docker run --rm -it --name ${CONTAINER} ${IMAGE} ${BRANCH} ${RELEASE} ${SNAPSHOT} \
		-e REPOSITORY_URL=${REPOSITORY_URL} \
		-v `pwd`/.gerritcodereview:/home/jenkins/.gerritcodereview \
                -v ~/.m2:/home/jenkins/.m2 \
		-v ${GNUPG}:/home/jenkins/.gnupg  \
		-v ${GIT_CONFIG}:/home/jenkins/.gitconfig \
		-v ${GIT_COOKIES}:/home/jenkins/.gitcookies

pull:
	docker pull gerritforge/gerrit-ci-slave-bazel:debian-buster-nocache-80.0.3987.149

build: pull
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish: build
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}


.PHONY: run pull build publish clean
