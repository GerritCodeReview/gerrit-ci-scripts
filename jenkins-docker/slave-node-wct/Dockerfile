FROM gerritforge/gerrit-ci-slave-chrome:stretch-69.0.3497.92

# Node JS for PolyGerrit build

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VER.x | bash -
RUN apt-get update && apt-get install -y nodejs gcc g++ make && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn

COPY wct.conf.json /home/jenkins/
RUN chown jenkins:jenkins /home/jenkins/wct.conf.json

USER jenkins

RUN bash -c 'cd /tmp && git clone https://gerrit.googlesource.com/gerrit && \
    cd /tmp/gerrit && \
    yarn install && \
    rm -Rf /tmp/gerrit'

USER root
