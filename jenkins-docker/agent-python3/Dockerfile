FROM gerritforge/gerrit-ci-agent-debian:$DEBIAN_VER

COPY requirements.txt /tmp/requirements.txt

RUN apt-get update --allow-releaseinfo-change && apt-get install -y \
    python3-pip && \
    pip3 install --break-system-packages --require-hashes -r /tmp/requirements.txt && \
    rm -Rf /var/lib/apt/lists
