FROM gerrit-ci-slave

RUN apt-get update && apt-get install -y \
    python-dev \
    python-pip \
    python-yaml \
    python-jenkins \
    ant \
    autoconf \
    automake \
    xsltproc \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Node JS for PolyGerrit build

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs

# PolyGerrit tests

RUN npm install -g web-component-tester
RUN curl -sL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable

COPY wct.conf.json /home/jenkins/
RUN chown jenkins:jenkins /home/jenkins/wct.conf.json

RUN apt-get install -y unzip wget
RUN mkdir /tmp/chromedriver/
ADD http://chromedriver.storage.googleapis.com/LATEST_RELEASE /tmp/chromedriver/LATEST_RELEASE
RUN wget -O /tmp/chromedriver/chromedriver.zip 'http://chromedriver.storage.googleapis.com/'$(cat /tmp/chromedriver/LATEST_RELEASE)'/chromedriver_linux64.zip'
RUN unzip /tmp/chromedriver/chromedriver.zip chromedriver -d /usr/local/bin/
RUN chmod a+x /usr/local/bin/chromedriver

# Allow Android SDK tools to run on a 64-bit system, see
# http://stackoverflow.com/a/23201209/1127485
RUN apt-get install -y lib32stdc++6 lib32z1

# Buck build

RUN git clone https://github.com/facebook/buck /opt/buck && \
    cd /opt/buck && ant && \
    mkdir -p /opt/buck/bin && \
    ln -s `pwd`/bin/buck /usr/bin/ && \
    ln -s `pwd`/bin/buckd /usr/bin/ && \
    chown -R jenkins:jenkins /opt/buck

## NOTE ##
# Watchman can be enabled (to enable buckd) by uncommenting the following
# lines.  Note that because this caches some build results, it can lead to
# unpredictable behavior in a continuous integration setting.
# ENABLE AT YOUR OWN RISK!
#
#RUN git clone https://github.com/facebook/watchman.git /opt/watchman && \
#    cd /opt/watchman && \
#    ./autogen.sh && \
#    ./configure && \
#    make && \
#    make install
#
## END WATCHMAN SECTION ##

# Buck cache warm-up with Gerrit master build

USER jenkins
RUN cd /tmp &&  git clone --recursive https://gerrit.googlesource.com/gerrit
RUN cd /tmp/gerrit && ( buck build gerrit api plugins:core || true )
RUN cd /tmp/gerrit && ( buck test --dry-run --no-results-cache --exclude flaky || true )
RUN rm -Rf /tmp/gerrit

USER root
