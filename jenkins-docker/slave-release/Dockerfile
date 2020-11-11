FROM gerritforge/gerrit-ci-slave-bazel:debian-buster-nocache-80.0.3987.149

RUN apt-get update && \
    apt-get install -y gnupg2 && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y google-cloud-sdk && \
    apt-get clean

COPY gerrit-release.sh /usr/local/bin

ENTRYPOINT [ "/usr/local/bin/gerrit-release.sh" ]

CMD [ "--help" ]

USER jenkins

WORKDIR /home/jenkins
