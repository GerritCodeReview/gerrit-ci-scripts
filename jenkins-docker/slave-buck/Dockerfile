FROM gerritforge/gerrit-ci-slave:ubuntu15.04-chrome60

# Buck build

RUN git clone https://github.com/facebook/buck /opt/buck-java8 && \
    cd /opt/buck-java8 && ant && \
    chown -R jenkins:jenkins /opt/buck-java8

RUN git clone https://github.com/facebook/buck /opt/buck-java7 && \
    cd /opt/buck-java7 && git checkout 6a42de3b4b7989d9c042c5524d765bf4a462dcb8 && \
    bash -c '. /usr/bin/set-java.sh 7 && ant' && \
    chown -R jenkins:jenkins /opt/buck-java7

COPY set-buck.sh /usr/bin/

COPY default-buck.sh /etc/profile.d/

RUN echo ". /usr/bin/set-buck.sh $1" >> /usr/bin/set-java.sh

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

# Buck JVM options setup
COPY buckjavaargs /home/jenkins/.buckjavaargs

# Buck cache warm-up with Gerrit master build
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && \
    cd /tmp &&  git clone --recursive https://gerrit.googlesource.com/gerrit && cd /tmp/gerrit && \
    buck build gerrit api plugins:core || true  && \
    buck test --dry-run --no-results-cache --exclude flaky || true  && \
    rm -Rf /tmp/gerrit /home/jenkins/.gerritcodereview/buck-cache/{cache,locally-built-artifacts}'

# Enable Buck rebuild
ENV BUCK_CLEAN_REPO_IF_DIRTY y

USER root
