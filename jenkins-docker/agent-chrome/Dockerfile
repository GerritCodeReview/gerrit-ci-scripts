FROM gerritforge/gerrit-ci-agent-debian:$DEBIAN_VER

RUN sed -i -e 's/archive/old-releases/g' /etc/apt/sources.list && \
    apt-get update --allow-releaseinfo-change && \
    apt-get install -y wget curl zip && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 78BD65473CB3BD13

RUN if test "$CHROME_VER" = "latest"; then \
      wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
    else \
      wget -O /tmp/chrome.deb http://www.slimjetbrowser.com/chrome/files/$CHROME_VER/google-chrome-stable_current_amd64.deb; \
    fi

RUN (dpkg -i /tmp/chrome.deb; apt-get install -f -y) && \
    rm /tmp/chrome.deb

