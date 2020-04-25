FROM gerritforge/gerrit-ci-slave-bazel:debian-stretch-nocache

# Bazel cache warm-up with Gerrit master and stable branches build
# Set-up google-java-format utility to ~/format/google-java-format
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp && git clone -b stable-2.16 --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    ./tools/setup_gjf.sh 1.7 && \
    ( bazelisk build plugins:core release api || true ) && \
    git checkout -f stable-3.0 && \
    git submodule update --init && \
    ( bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api || true ) && \
    git checkout -f stable-3.1 && \
    git submodule update --init && \
    ( bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api || true ) && \
    git checkout -f stable-3.2 && \
    git submodule update --init && \
    ( bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api || true ) && \
    git checkout -f master && \
    git submodule update --init && \
    ( bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api || true ) && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
