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
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp &&  git clone --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && ( bazel build release || true ) && \
    cd /tmp/gerrit && ./tools/setup_gjf.sh && \
    cd /tmp/gerrit && mv tools/format ~ && \
    cd /tmp/gerrit && ./tools/download_file.py -o ~/format/google-java-format-1.5-all-deps.jar -u https://github.com/google/google-java-format/releases/download/google-java-format-1.5/google-java-format-1.5-all-deps.jar -v "b1f79e4d39a3c501f07c0ce7e8b03ac6964ed1f1" && \
    rm -Rf /tmp/gerrit'

USER root
