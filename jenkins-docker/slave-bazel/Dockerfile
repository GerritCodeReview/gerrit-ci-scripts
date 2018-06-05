FROM gerritforge/gerrit-ci-slave-debian

# Bazel 0.14.0
RUN wget -O /tmp/bazel_0.14.0-linux-x86_64.deb https://github.com/bazelbuild/bazel/releases/download/0.14.0/bazel_0.14.0-linux-x86_64.deb && \
    gdebi --non-interactive /tmp/bazel_0.14.0-linux-x86_64.deb && \
    rm /tmp/bazel_0.14.0-linux-x86_64.deb

# Install buildifier utility (0.11.1)
RUN cd /tmp && \
    git clone https://github.com/bazelbuild/buildtools.git && \
    cd buildtools && \
    git checkout 0.11.1 && \
    bazel build --workspace_status_command=`pwd`/status.sh //buildifier && \
    cp bazel-bin/buildifier/linux_amd64_stripped/buildifier /usr/bin && \
    rm -rf /tmp/buildtools && \
    buildifier --version

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
    git checkout -f stable-2.15 && git submodule update && ( bazel build release || true ) && \
    git checkout -f master && git submodule update && ( bazel build release || true ) && \
    cd /tmp/gerrit/tools/format && ln -s google-java-format-1.3 google-java-format && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
