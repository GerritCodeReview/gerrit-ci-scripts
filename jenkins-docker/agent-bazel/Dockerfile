ARG CHROME_VER

FROM gerritforge/gerrit-ci-agent-bazel:debian-bullseye-nocache-$CHROME_VER

# Bazel cache warm-up with Gerrit master and latest stable branch.
# Set-up google-java-format utility to ~/format/google-java-format.
USER jenkins

ENV REF_REPO=/home/jenkins/gerrit-reference.git

RUN export GIT_DIR=$REF_REPO && mkdir $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/gerrit +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/modules/jgit && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/jgit +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/modules/java-prettify && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/java-prettify +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/codemirror-editor && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/codemirror-editor +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/commit-message-length-validator && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/commit-message-length-validator +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/delete-project && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/delete-project +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/download-commands && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/download-commands +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/gitiles && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/gitiles +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/hooks && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/hooks +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/plugin-manager && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/plugin-manager +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/replication && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/replication +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/reviewnotes && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/reviewnotes +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/singleusergroup && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/singleusergroup +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/plugins/webhooks && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/plugins/webhooks +refs/heads/*:refs/heads/*

RUN export GIT_DIR=$REF_REPO/modules/polymer-bridges && mkdir -p $GIT_DIR && git init --bare && \
    git fetch https://gerrit.googlesource.com/polymer-bridges +refs/heads/*:refs/heads/*

RUN mkdir -p /home/jenkins/workspace/Gerrit-verifier-chrome-latest && \
    cd /home/jenkins/workspace/Gerrit-verifier-chrome-latest && \
    git clone -b stable-3.9 --recursive --reference-if-able $REF_REPO https://gerrit.googlesource.com/gerrit && \
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
