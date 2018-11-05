FROM gerritforge/gerrit-ci-slave-node-wct:10-6.8.0

# Bazel 0.19.0
RUN apt-get update && \
    wget -O /tmp/bazel_0.19.0-linux-x86_64.deb https://github.com/bazelbuild/bazel/releases/download/0.19.0/bazel_0.19.0-linux-x86_64.deb && \
    (dpkg -i /tmp/bazel_0.19.0-linux-x86_64.deb; apt-get install -f -y) && \
    rm /tmp/bazel_0.19.0-linux-x86_64.deb && \
    bash -c 'bazel version'

# Install buildifier utility (0.17.2)
RUN cd /tmp && \
    bash -c '\
    git clone https://github.com/bazelbuild/buildtools.git && \
    cd buildtools && \
    git checkout 0.17.2 && \
    bazel build --workspace_status_command=`pwd`/status.sh //buildifier && \
    cp bazel-bin/buildifier/linux_amd64_stripped/buildifier /usr/bin && \
    rm -rf /tmp/buildtools && \
    buildifier --version'

# Bazel cache warm-up with Gerrit master and stable branches build
# Set-up google-java-format utility to ~/format/google-java-format
USER jenkins
RUN bash -c '\
    cd /tmp &&  git clone --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    ./tools/setup_gjf.sh 1.6 && \
    ( bazel build release || true ) && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
