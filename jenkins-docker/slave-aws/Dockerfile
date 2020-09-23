FROM gerritforge/gerrit-ci-slave-bazel:$DEBIAN_VER

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip

USER root

RUN ./aws/install

USER jenkins