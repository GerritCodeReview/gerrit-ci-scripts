FROM gerritforge/gerrit-ci-slave-buck:debian-jessie-nocache

USER jenkins

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
