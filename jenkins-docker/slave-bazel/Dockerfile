FROM gerritforge/gerrit-ci-slave-bazel:debian-buster-nocache

# Bazel cache warm-up with Gerrit master and stable branches build
# Set-up google-java-format utility to ~/format/google-java-format
USER jenkins
RUN bash -c 'cd /tmp && git clone -b stable-3.0 --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    ./tools/setup_gjf.sh 1.7 && \
    ( bazelisk build //:release || true ) && \
    git checkout -f master && git submodule update --init && ( bazelisk build //:release || true ) && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
