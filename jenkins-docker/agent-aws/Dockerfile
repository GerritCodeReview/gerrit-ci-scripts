FROM gerritforge/gerrit-ci-agent-debian:bullseye

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip && ./aws/install

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/debian \
      $(lsb_release -cs) \
      stable" && \
    apt-get update --allow-releaseinfo-change && \
    apt-get install -y docker-ce-cli jq

USER jenkins

RUN bash -c ". set-java.sh 17"

USER root

