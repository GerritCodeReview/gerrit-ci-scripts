FROM gerritforge/gerrit-ci-slave-debian:$DEBIAN_VER

RUN sed -i -e 's/archive/old-releases/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget curl zip fonts-liberation && \
    wget -O /tmp/chrome.deb https://www.slimjet.com/chrome/download-chrome.php?file=lnx%2Fchrome64_$CHROME_VER.deb && \
    (dpkg -i /tmp/chrome.deb; apt-get install -f -y) && \
    rm /tmp/chrome.deb

