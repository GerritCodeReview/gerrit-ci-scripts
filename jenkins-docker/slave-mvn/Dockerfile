FROM gerrit-ci-slave

USER jenkins

ENV GERRIT_URL https://gerrit-review.googlesource.com/plugins

# Set of projects for cache warm-up
ENV PROJECTS \
	admin-console \
	changemessage \
	egit \
	github \
	imagare \
	manifest-subscription \
	menuextender \
	project-download-commands \
	reviewassistant \
	serviceuser \
	slack-integration

# Maven cache warm-up for Gerrit plugins
RUN for prj in $PROJECTS; do cd /tmp && git clone $GERRIT_URL/$prj && cd $prj && mvn dependency:go-offline; done
