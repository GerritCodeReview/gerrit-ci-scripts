FROM gerritforge/gerrit-ci-slave-buck:debian-jessie

# Install Bazel
ARG BAZEL_VER=0.21.0
RUN apt-get update && \
    wget -O /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel_${BAZEL_VER}-linux-x86_64.deb && \
    (dpkg -i /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb; apt-get install -f -y) && \
    rm /tmp/bazel_${BAZEL_VER}-linux-x86_64.deb && \
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

# Bazel cache warm-up with Gerrit master and stable branches build
# Set-up google-java-format utility to ~/format/google-java-format
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp &&  git clone -b stable-2.15 --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    ./tools/setup_gjf.sh 1.6 && \
    ( bazel build //... || true ) && \
    git checkout -f stable-2.16 && git submodule update --init && ( bazel build //... || true ) && \
    git checkout -f master && git submodule update --init && ( bazel build //... || true ) && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
