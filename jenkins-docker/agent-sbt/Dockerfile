FROM gerritforge/gerrit-ci-agent-bazel:debian-bookworm-latest

# SBT Setup
RUN apt-get update --allow-releaseinfo-change && \
    apt-get -y install apt-transport-https && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add && \
    apt-get update --allow-releaseinfo-change && \
    apt-get -y install --no-install-recommends sbt && \
    rm -rf /etc/apt/sources.list.d/* && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u382-b05/OpenJDK8U-jdk_x64_linux_hotspot_8u382b05.tar.gz && \
    tar -xzf OpenJDK8U-jdk_x64_linux_hotspot_8u382b05.tar.gz && \
    mv jdk8u382-b05 /usr/lib/jvm/java-8-openjdk-amd64

USER root
