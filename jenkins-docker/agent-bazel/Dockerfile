FROM gerritforge/gerrit-ci-agent-bazel:debian-bullseye-nocache-$CHROME_VER

# Bazel cache warm-up with Gerrit master and latest stable branch.
# Set-up google-java-format utility to ~/format/google-java-format.
USER jenkins
RUN mkdir -p /home/jenkins/workspace/Gerrit-verifier-chrome-latest && \
    cd /home/jenkins/workspace/Gerrit-verifier-chrome-latest && \
    git clone -b stable-3.9 --recursive https://gerrit.googlesource.com/gerrit && \
    cd gerrit && \
    ./tools/setup_gjf.sh 1.7 && \
    . set-java.sh 17 && \
    bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api && \
    git checkout -f master && \
    git submodule update --init && \
    bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --remote_download_all --noremote_upload_local_results plugins:core release api && \
    mv tools/format ~ && \
    rm -Rf /home/jenkins/workspace

USER root
