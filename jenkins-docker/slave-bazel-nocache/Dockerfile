FROM gerritforge/gerrit-ci-slave-buck:debian-jessie

# Bazel 0.19.0
RUN apt-get update && \
    wget -O /tmp/bazel_0.19.0-linux-x86_64.deb https://github.com/bazelbuild/bazel/releases/download/0.19.0/bazel_0.19.0-linux-x86_64.deb && \
    (dpkg -i /tmp/bazel_0.19.0-linux-x86_64.deb; apt-get install -f -y) && \
    rm /tmp/bazel_0.19.0-linux-x86_64.deb && \
    bash -c '. set-java.sh 8 && bazel version'

# Install Buildifier
ARG BUILDIFIER_VER=0.20.0
RUN cd /tmp && \
    bash -c '. /usr/bin/set-java.sh 8 && \
    git clone https://github.com/bazelbuild/buildtools.git && \
    cd buildtools && \
    git checkout ${BUILDIFIER_VER} && \
    bazel build --workspace_status_command=`pwd`/status.sh //buildifier && \
    cp bazel-bin/buildifier/linux_amd64_stripped/buildifier /usr/bin && \
    rm -rf /tmp/buildtools && \
    buildifier --version'

USER root
