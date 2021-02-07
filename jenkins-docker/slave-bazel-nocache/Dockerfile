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
RUN cd /tmp && \
    bash -c 'git clone https://github.com/bazelbuild/buildtools.git && \
    cd buildtools && \
    git checkout ${BUILDIFIER_VER} && \
    bazel build --config=release //buildifier && \
    cp bazel-bin/buildifier/linux_amd64_stripped/buildifier /usr/bin && \
    rm -rf /tmp/buildtools && \
    buildifier --version'

# Install Bazelisk
# TODO:(davido) Remove --incompatible_restrict_string_escapes=false, when this is fixed:
# https://github.com/bazelbuild/bazelisk/issues/213
RUN cd /tmp && \
    git clone https://github.com/bazelbuild/bazelisk.git && \
    cd bazelisk && \
    git checkout v${BAZELISK_VER} && \
    rm -f .bazelversion && \
    bazel build --config=release --incompatible_restrict_string_escapes=false //:bazelisk && \
    cp bazel-bin/*/bazelisk /usr/bin && \
    rm -rf /tmp/bazelisk

USER root
