FROM gerritforge/gerrit-ci-agent-bazel:debian-bookworm-nocache-latest

ARG JRELEASER_VERSION=1.20.0
RUN apt-get update --allow-releaseinfo-change && \
    apt-get install -y gnupg2 jq && \
    export CLOUD_SDK_REPO="cloud-sdk-bookworm" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update --allow-releaseinfo-change && apt-get install -y google-cloud-sdk && \
    apt-get clean
RUN curl -fsSL -o /tmp/jr.zip \
      "https://github.com/jreleaser/jreleaser/releases/download/v${JRELEASER_VERSION}/jreleaser-standalone-${JRELEASER_VERSION}-linux-x86_64.zip" && \
    unzip /tmp/jr.zip -d /opt && \
    ln -sf "/opt/jreleaser-standalone-${JRELEASER_VERSION}-linux-x86_64/bin/jreleaser" /usr/local/bin/jreleaser && \
    rm -f /tmp/jr.zip

COPY gerrit-release.sh /usr/local/bin
COPY gerrit-upgrade-test.sh /usr/local/bin
COPY --chmod=555 gpg-loopback /usr/local/bin/gpg-loopback
COPY m2.settings.xml.template /tmp/m2.settings.xml.template

USER jenkins

WORKDIR /home/jenkins
