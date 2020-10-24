FROM gerritforge/gerrit-ci-slave-chrome:buster-$CHROME_VER

# Node JS for PolyGerrit build

RUN apt-get update && apt-get install -y nodejs npm gcc g++ make && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn && \
    npm i npm@latest -g

COPY wct.conf.json /home/jenkins/
RUN chown jenkins:jenkins /home/jenkins/wct.conf.json

USER jenkins

WORKDIR /home/jenkins

RUN npm install \
      eslint@"=6.6.0" \
      eslint-config-google@"=0.13.0" \
      eslint-plugin-html@"=6.0.0" \
      eslint-plugin-jsdoc@"=19.2.0" \
      eslint-plugin-promise@"=4.0.1" \
      typescript \
      fried-twinkie@"^0.2.2" \
      polylint polymer-cli
RUN npm install 'web-component-tester@$WCT_VER'

USER root
