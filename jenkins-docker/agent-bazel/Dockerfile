FROM gerritforge/gerrit-ci-agent-bazel:debian-buster-nocache-$CHROME_VER

# Bazel cache warm-up with Gerrit master and latest stable branch.
# Set-up google-java-format utility to ~/format/google-java-format.
USER jenkins
RUN mkdir -p ~jenkins/reference && cd ~jenkins/reference && git clone --bare https://gerrit.googlesource.com/gerrit
RUN bash -c 'cd /tmp && git clone -b stable-3.5 --recursive --reference-if-able ~jenkins/reference/gerrit.git https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    ./tools/setup_gjf.sh 1.7 && \
    ( bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api || true ) && \
    git checkout -f master && \
    git submodule update --init && \
    ( bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api || true ) && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
