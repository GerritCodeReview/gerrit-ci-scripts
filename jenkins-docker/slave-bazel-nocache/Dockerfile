FROM gerritforge/gerrit-ci-slave-buck:debian-stretch

ARG BAZEL_VER
ARG BUILDIFIER_VER
ARG GO_VER

ADD https://dl.google.com/go/go${GO_VER}.linux-amd64.tar.gz /usr/local/

RUN cd /usr/local && \
    tar -xvf go${GO_VER}.linux-amd64.tar.gz

ENV GOROOT=/usr/local/go

# Bazel cache warm-up with Gerrit master and stable branches build
# Set-up google-java-format utility to ~/format/google-java-format
USER jenkins

ENV GOPATH=/home/jenkins/go

RUN $GOROOT/bin/go get github.com/bazelbuild/bazelisk

ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Install Bazel
RUN apt-get update && \
    wget -O /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel_${BAZEL_VER}-linux-x86_64.deb && \
    (dpkg -i /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb; apt-get install -f -y) && \
    rm /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb && \
    bash -c '. set-java.sh 8 && bazel version'

# Install Buildifier
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
