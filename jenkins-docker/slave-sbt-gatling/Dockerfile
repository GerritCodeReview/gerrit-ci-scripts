FROM gerritforge/gerrit-ci-slave-bazel-sbt:latest

COPY config /home/jenkins/.ssh/config
COPY .gitconfig /home/jenkins/.gitconfig
RUN  chown jenkins:jenkins /home/jenkins/.ssh/config
RUN  chown jenkins:jenkins /home/jenkins/.gitconfig



