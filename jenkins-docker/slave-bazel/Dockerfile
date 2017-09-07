FROM gerritforge/gerrit-ci-slave-buck

ADD https://storage.googleapis.com/bazel-apt/doc/apt-key.pub.gpg /tmp/bazel.pub.gpg
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
    apt-key add /tmp/bazel.pub.gpg

RUN apt-get update && apt-get install -y bazel \
    && rm -rf /var/lib/apt/lists/*

# Install buildifier utility
ADD https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz /tmp/golang.tar.gz
RUN cd /usr/local && \
    tar xvfz /tmp/golang.tar.gz && \
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
    cd /tmp/gerrit && ./tools/setup_gjf.sh && \
    cd /tmp/gerrit && mv tools/format ~ && \
    cd /tmp/gerrit && ./tools/download_file.py -o ~/format/google-java-format-1.4-all-deps.jar -u https://github.com/davido/google-java-format/releases/download/1.4-1-ge22b66d/google-java-format-1.4-1-ge22b66d-all-deps.jar -v "ecc173841ee5794cd09a0a15db82a8c89357561c" && \
    rm -Rf /tmp/gerrit'

USER root
