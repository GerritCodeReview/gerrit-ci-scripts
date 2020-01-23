FROM gerritforge/gerrit-ci-slave-bazel:debian-stretch-nocache

# Bazel cache warm-up with Gerrit master and stable branches build
# Set-up google-java-format utility to ~/format/google-java-format
USER jenkins

ENV REPOS_TO_CACHE \
      gerrit \
      plugins/codemirror-editor \
      plugins/commit-message-length-validator \
      plugins/delete-project \
      plugins/download-commands \
      plugins/gitiles \
      plugins/hooks \
      plugins/plugin-manager \
      plugins/replication \
      plugins/reviewnotes \
      plugins/singleusergroup \
      plugins/webhooks

RUN bash -cxe 'git init --bare ~/repo_cache && \
    cd ~/repo_cache && \
    for REPO in $REPOS_TO_CACHE; do \
      git remote add $REPO https://gerrit.googlesource.com/$REPO; \
    done && \
    git fetch --all'

RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp && \
    git clone -b stable-2.16 --reference ~/repo_cache --dissociate --recursive https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    ./tools/setup_gjf.sh 1.7 && \
    ( bazelisk build plugins:core release api || true ) && \
    git checkout -f stable-3.0 && git submodule update --init && ( bazelisk build plugins:core release api || true ) && \
    git checkout -f stable-3.1 && git submodule update --init && ( bazelisk build plugins:core release api || true ) && \
    git checkout -f master && git submodule update --init && ( bazelisk build plugins:core release api || true ) && \
    cd /tmp/gerrit && mv tools/format ~ && \
    rm -Rf /tmp/gerrit'

USER root
