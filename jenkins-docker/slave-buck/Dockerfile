FROM gerrit-ci-slave

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

# Buck JVM options setup
COPY buckjavaargs /home/jenkins/.buckjavaargs

# Buck cache warm-up with Gerrit master build
USER jenkins
RUN cd /tmp &&  git clone --recursive https://gerrit.googlesource.com/gerrit
RUN cd /tmp/gerrit && ( buck build gerrit api plugins:core || true )
RUN cd /tmp/gerrit && ( buck test --dry-run --no-results-cache --exclude flaky || true )
RUN rm -Rf /tmp/gerrit
RUN rm -Rf /home/jenkins/.gerritcodereview/buck-cache/{cache,locally-built-artifacts}

# Enable Buck rebuild
ENV BUCK_CLEAN_REPO_IF_DIRTY y

USER root
