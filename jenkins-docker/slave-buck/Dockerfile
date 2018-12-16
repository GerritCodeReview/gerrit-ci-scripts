FROM gerritforge/gerrit-ci-slave-node-wct:$NODE_VER-$WCT_VER

# Buck build

RUN git clone https://github.com/facebook/buck /opt/buck-java && \
    cd /opt/buck-java && \
    git checkout e64a2e2ada022f81e42be750b774024469551398 && \
    ant && \
    chown -R jenkins:jenkins /opt/buck-java

COPY set-buck.sh /usr/bin/

COPY default-buck.sh /etc/profile.d/

RUN echo ". /usr/bin/set-buck.sh" >> /usr/bin/set-java.sh

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

# Buck cache warm-up with Gerrit 2.13 build
USER jenkins
RUN bash -c '. /usr/bin/set-java.sh 8 && cd /tmp &&  \
    git clone -b stable-2.13 --recursive https://gerrit.googlesource.com/gerrit && \
    cd gerrit && buck build gerrit api plugins:core || true  && \
    buck test --dry-run --no-results-cache --exclude flaky || true  && \
    rm -Rf /tmp/gerrit /home/jenkins/.gerritcodereview/buck-cache/{cache,locally-built-artifacts}'

# Enable Buck rebuild
ENV BUCK_CLEAN_REPO_IF_DIRTY y

USER root
