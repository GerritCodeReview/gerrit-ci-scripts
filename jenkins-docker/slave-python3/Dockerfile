FROM gerritforge/gerrit-ci-slave-debian:$DEBIAN_VER-$SCM_VER

RUN apt-get update && apt-get install -y \
    python3-pip && \
    pip3 install yamllint pipenv && \
    rm -Rf /var/lib/apt/lists
