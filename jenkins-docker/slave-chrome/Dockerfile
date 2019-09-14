FROM gerritforge/gerrit-ci-slave-debian:$DEBIAN_VER

RUN sed -i -e 's/archive/old-releases/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget curl zip && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 78BD65473CB3BD13 && \
    wget -O /tmp/chrome.deb http://www.slimjetbrowser.com/chrome/files/$CHROME_VER/google-chrome-stable_current_amd64.deb && \
    (dpkg -i /tmp/chrome.deb; apt-get install -f -y) && \
    rm /tmp/chrome.deb

