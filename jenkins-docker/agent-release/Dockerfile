FROM gerritforge/gerrit-ci-agent-bazel:debian-bullseye-nocache-latest

RUN apt-get update --allow-releaseinfo-change && \
    apt-get install -y gnupg2 jq && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update --allow-releaseinfo-change && apt-get install -y google-cloud-sdk && \
    apt-get clean

COPY gerrit-release.sh /usr/local/bin
COPY gerrit-upgrade-test.sh /usr/local/bin

ENTRYPOINT [ "/usr/local/bin/gerrit-release.sh" ]

CMD [ "--help" ]

USER jenkins

WORKDIR /home/jenkins
