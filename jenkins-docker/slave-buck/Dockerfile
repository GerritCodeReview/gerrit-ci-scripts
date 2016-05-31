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
    && rm -rf /var/lib/apt/lists/*

# Node JS for PolyGerrit build

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs

# PolyGerrit tests

RUN npm install -g web-component-tester
RUN apt-get install -y chromium-browser
RUN ln -s /usr/bin/chromium /usr/bin/chrome

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

