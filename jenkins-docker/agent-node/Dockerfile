FROM gerritforge/gerrit-ci-agent-chrome:bookworm-$CHROME_VER

# Node JS for PolyGerrit build

RUN apt-get update --allow-releaseinfo-change && apt-get install -y nodejs npm gcc g++ make && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update --allow-releaseinfo-change && apt-get install yarn

