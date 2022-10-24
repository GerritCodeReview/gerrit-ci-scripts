FROM gerritforge/gerrit-ci-agent-python3:bullseye

RUN apt-get update --allow-releaseinfo-change && \
    apt-get install -y ruby-full && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists && \

RUN git clone https://gerrit.googlesource.com/homepage /tmp/homepage && \
    cd /tmp/homepage && \
    bundle install && \
    rm -rf /tmp/homepage

RUN curl -L https://firebase.tools/bin/linux/latest -o /usr/local/bin/firebase && \
    chmod +x /usr/local/bin/firebase
