FROM gerritforge/gerrit-ci-slave-buck:debian-jessie

# Bazel 0.14.0
RUN apt-get update && \
    wget -O /tmp/bazel_0.14.0-linux-x86_64.deb https://github.com/bazelbuild/bazel/releases/download/0.14.0/bazel_0.14.0-linux-x86_64.deb && \
    (dpkg -i /tmp/bazel_0.14.0-linux-x86_64.deb; apt-get install -f -y) && \
    rm /tmp/bazel_0.14.0-linux-x86_64.deb

# Install buildifier utility (0.12.0)
RUN cd /tmp && \
    bash -c '. /usr/bin/set-java.sh 8 && \
    git clone https://github.com/bazelbuild/buildtools.git && \
    cd buildtools && \
    git checkout 0.12.0 && \
    bazel build --workspace_status_command=`pwd`/status.sh //buildifier && \
    cp bazel-bin/buildifier/linux_amd64_stripped/buildifier /usr/bin && \
    rm -rf /tmp/buildtools && \
    buildifier --version'

# Bazel cache warm-up with Gerrit master build
# Set-up google-java-format utility to ~/format/google-java-format
# TODO(davido): Switch to upstream, when this PR (or similar) is merged upstream:
# https://github.com/google/google-java-format/pull/154
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp &&  git clone -b stable-2.14 --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    ./tools/setup_gjf.sh 1.5 && \
    ./tools/setup_gjf.sh 1.6 && \
    ( bazel build release || true ) && \
    git checkout -f stable-2.15 && git submodule update --init && ( bazel build release || true ) && \
    git checkout -f master && git submodule update --init && ( bazel build release || true ) && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
