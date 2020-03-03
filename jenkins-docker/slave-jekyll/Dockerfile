FROM gerritforge/gerrit-ci-slave-python3:buster

RUN apt-get update && \
    apt-get install -y ruby-full && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists && \
    gem install jekyll bundler:1.17.1

RUN git clone https://gerrit.googlesource.com/homepage /tmp/homepage && \
    cd /tmp/homepage && \
    bundle install && \
    rm -rf /tmp/homepage

RUN curl -L https://firebase.tools/bin/linux/latest -o /usr/local/bin/firebase && \
    chmod +x /usr/local/bin/firebase
