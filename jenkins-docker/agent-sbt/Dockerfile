FROM gerritforge/gerrit-ci-slave-bazel:debian-buster-latest

# SBT Setup
RUN apt-get update --allow-releaseinfo-change && \
    apt-get -y install apt-transport-https && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add && \
    apt-get update --allow-releaseinfo-change && \
    apt-get -y install --no-install-recommends sbt && \
    rm -rf /etc/apt/sources.list.d/* && \
    rm -rf /var/lib/apt/lists/*

# SBT warm-up
RUN cd /tmp && sbt new sbt/scala-seed.g8 --name=hello
RUN echo 'addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.6")' >> /tmp/hello/project/plugins.sbt
RUN chown -R jenkins: /tmp/hello

USER jenkins
RUN cd /tmp/hello && sbt compile test assembly

USER root
