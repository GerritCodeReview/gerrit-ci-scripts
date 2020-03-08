FROM gerritforge/gerrit-ci-slave-node-wct:$NODE_VER-$WCT_VER

ARG BAZEL_VER
ARG BUILDIFIER_VER
ARG BAZELISK_VER

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
    bazel build --config=release //buildifier && \
    cp bazel-bin/buildifier/linux_amd64_stripped/buildifier /usr/bin && \
    rm -rf /tmp/buildtools && \
    buildifier --version'

# Install Bazelisk
RUN cd /tmp && \
    git clone https://github.com/bazelbuild/bazelisk.git && \
    cd bazelisk && \
    git checkout v${BAZELISK_VER} && \
    bazel build --stamp --workspace_status_command=`pwd`/stamp.sh --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 //:bazelisk && \
    cp bazel-bin/linux_amd64_pure_stripped/bazelisk /usr/bin && \
    rm -rf /tmp/bazelisk

USER root
