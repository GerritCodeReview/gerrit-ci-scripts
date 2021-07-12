FROM gerritforge/gerrit-ci-slave-node-wct:$NODE_VER-$WCT_VER-$CHROME_VER

ARG BAZEL_VER
ARG BUILDIFIER_VER
ARG BAZELISK_VER

# Install Bazel
RUN apt-get update && \
    wget -O /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel_${BAZEL_VER}-linux-x86_64.deb && \
    (dpkg -i /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb; apt-get install -f -y) && \
    rm /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb && \
    bash -c 'bazel version'

# Install Buildifier
RUN wget -O /tmp/buildifier-${BUILDIFIER_VER}-linux-amd64 https://github.com/bazelbuild/buildtools/releases/download/${BUILDIFIER_VER}/buildifier-linux-amd64 && \
    chmod a+x /tmp/buildifier-${BUILDIFIER_VER}-linux-amd64 && \
    cp /tmp/buildifier-${BUILDIFIER_VER}-linux-amd64 /usr/bin/buildifier && \
    rm -rf /tmp/buildifier-${BUILDIFIER_VER}-linux-amd64 && \
    buildifier --version

# Install Bazelisk
RUN wget -O /tmp/bazelisk-${BAZELISK_VER}-linux-amd64 https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VER}/bazelisk-linux-amd64 && \
    chmod a+x /tmp/bazelisk-${BAZELISK_VER}-linux-amd64 && \
    cp /tmp/bazelisk-${BAZELISK_VER}-linux-amd64 /usr/bin/bazelisk && \
    rm -rf /tmp/bazelisk-${BAZELISK_VER}-linux-amd64

USER root
