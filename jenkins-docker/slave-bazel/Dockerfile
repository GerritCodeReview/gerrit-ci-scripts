FROM gerritforge/gerrit-ci-slave-debian

# Bazel 0.10.0
RUN wget -O /tmp/bazel_0.10.0-linux-x86_64.deb https://github.com/bazelbuild/bazel/releases/download/0.10.0/bazel_0.10.0-linux-x86_64.deb && \
    gdebi --non-interactive /tmp/bazel_0.10.0-linux-x86_64.deb && \
    rm /tmp/bazel_0.10.0-linux-x86_64.deb

# Install buildifier utility
ADD https://storage.googleapis.com/golang/go1.9.3.linux-amd64.tar.gz /tmp/golang.tar.gz
RUN cd /usr/local && \
    tar xvfz /tmp/golang.tar.gz && \
    rm /tmp/golang.tar.gz && \
    cd /usr/local/bin && \
    ln -s /usr/local/go/bin/* . && \
    GOPATH=/usr go get github.com/bazelbuild/buildtools/buildifier && \
    chmod a+rx /usr/bin/buildifier

# Bazel cache warm-up with Gerrit master build
# Set-up google-java-format utility to ~/format/google-java-format
# TODO(davido): Switch to upstream, when this PR (or similar) is merged upstream:
# https://github.com/google/google-java-format/pull/154
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp &&  git clone --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && ( bazel build release || true ) && \
    cd /tmp/gerrit && ./tools/setup_gjf.sh 1.3 && \
    cd /tmp/gerrit && ./tools/setup_gjf.sh 1.5 && \
    cd /tmp/gerrit/tools/format && ln -s google-java-format-1.3 google-java-format && \
    cd /tmp/gerrit && mv tools/format ~ && \
    cd /tmp/gerrit && ./tools/download_file.py -o ~/format/google-java-format-1.3-all-deps.jar -u https://github.com/davido/google-java-format/releases/download/1.3-1-gec5ce10/google-java-format-1.3-1-gec5ce10-all-deps.jar -v "65f060dc238bdd81ef029354d8e6dad6dd742ef4" && \
    rm -Rf /tmp/gerrit'

USER root
