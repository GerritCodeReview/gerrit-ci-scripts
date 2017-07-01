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
    go get github.com/bazelbuild/buildtools/buildifier

# Bazel cache warm-up with Gerrit master build
# Set-up google-java-format utility to ~/format/google-java-format
# TODO(davido): Switch to upstream, when this PR (or similar) is merged upstream:
# https://github.com/google/google-java-format/pull/154
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp &&  git clone --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && ( bazel build release || true ) && \
    cd /tmp/gerrit && ( ./tools/download_all.py || true ) && \
    cd /tmp/gerrit && ./tools/setup_gjf.sh && \
    cd /tmp/gerrit && mv tools/format ~ && \
    cd /tmp/gerrit && ./tools/download_file.py -o ~/format/google-java-format-1.3-all-deps.jar -u https://github.com/davido/google-java-format/releases/download/1.3-1-gec5ce10/google-java-format-1.3-1-gec5ce10-all-deps.jar -v "65f060dc238bdd81ef029354d8e6dad6dd742ef4" && \

USER root
