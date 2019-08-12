FROM gerritforge/gerrit-ci-slave-bazel:debian-stretch-nocache-$CHROME_VER

# Bazel cache warm-up with Gerrit master and latest stable branch.
# Set-up google-java-format utility to ~/format/google-java-format.
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp && git clone -b stable-3.2 --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    ./tools/setup_gjf.sh 1.7 && \
    ( bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api || true ) && \
    git checkout -f master && \
    git submodule update --init && \
    ( bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api || true ) && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
