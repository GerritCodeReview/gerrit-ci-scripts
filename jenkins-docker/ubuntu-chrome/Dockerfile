FROM ubuntu:15.04

USER root

RUN sed -i -e 's/archive/old-releases/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget curl zip && \
    wget -O /tmp/chrome64_60.0.3112.90.deb https://www.slimjet.com/chrome/download-chrome.php?file=lnx%2Fchrome64_60.0.3112.90.deb && \
    apt-get install -y gdebi && \
    gdebi --non-interactive /tmp/chrome64_60.0.3112.90.deb
