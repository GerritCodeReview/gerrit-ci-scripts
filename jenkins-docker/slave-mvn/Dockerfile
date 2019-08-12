FROM gerritforge/gerrit-ci-slave-bazel:debian-stretch-80.0.3987.149

USER jenkins

ENV GERRIT_URL https://gerrit-review.googlesource.com/plugins

# Set of projects for cache warm-up
ENV PROJECTS \
	egit \
	github \
	imagare \
	manifest-subscription

# Maven cache warm-up for Gerrit plugins
RUN export HOME=/home/jenkins && for prj in $PROJECTS; do cd /tmp && git clone $GERRIT_URL/$prj && cd $prj && ( mvn clean install || true ); rm -Rf /tmp/$prj; done

# Remove SNAPSHOT builds from Maven repo
RUN for DIR in $(find ~/.m2/repository -type d -name '*SNAPSHOT*'); do rm -Rf $DIR; done
