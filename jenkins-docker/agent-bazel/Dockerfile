ARG CHROME_VER

FROM gerritforge/gerrit-ci-agent-bazel:debian-bullseye-nocache-$CHROME_VER

# Bazel cache warm-up with Gerrit master and latest stable branch.
# Set-up google-java-format utility to ~/format/google-java-format.
USER jenkins

ENV REF_REPO=/home/jenkins/gerrit-reference.git

RUN export GIT_DIR=$REF_REPO && mkdir $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/gerrit +refs/heads/*:refs/heads/*

ARG PLUGINS="codemirror-editor \
             commit-message-length-validator \
             delete-project \
             download-commands \
             gitiles \
             hooks \
             plugin-manager \
             replication \
             reviewnotes \
             singleusergroup \
             webhooks"
RUN for REPO in $PLUGINS; do \
        export GIT_DIR=$REF_REPO/modules/plugins/$REPO && \
        mkdir -p $GIT_DIR && \
        git init --bare && \
        git fetch https://gerrit.googlesource.com/plugins/$REPO +refs/heads/*:refs/heads/*; \
    done

ARG MODULES="jgit java-prettify"
RUN for REPO in $MODULES; do \
        export GIT_DIR=$REF_REPO/modules/modules/$REPO && \
        mkdir -p $GIT_DIR && \
        git init --bare && \
        git fetch https://gerrit.googlesource.com/$REPO +refs/heads/*:refs/heads/*; \
    done

RUN export GIT_DIR=$REF_REPO/modules/polymer-bridges && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/polymer-bridges +refs/heads/*:refs/heads/*

RUN bash -c "mkdir -p /home/jenkins/workspace/Gerrit-verifier-chrome-latest && \
    cd /home/jenkins/workspace/Gerrit-verifier-chrome-latest && \
    git clone -b stable-3.11 --recursive --reference $REF_REPO https://gerrit.googlesource.com/gerrit && \
    cd gerrit && \
    ./tools/setup_gjf.sh 1.7 && \
    . set-java.sh --branch stable-3.11 && \
    bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --noremote_upload_local_results plugins:core release api && \
    git checkout -f master && \
    git submodule update --reference $REF_REPO --init && \
    . set-java.sh --branch master && \
    bazelisk build --remote_cache=https://gerrit-ci.gerritforge.com/cache --remote_download_all --noremote_upload_local_results plugins:core release api && \
    mv tools/format ~ && \
    rm -Rf /home/jenkins/workspace"

USER root
