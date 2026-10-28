FROM node:22-bookworm-slim AS node

FROM gerritforge/gerrit-ci-agent-python3:bookworm AS browser-dependencies

# Keep the existing Python/Java agent base and add a supported Node runtime.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Match homepage/package-lock.json when updating Playwright. Only system
# packages are installed as root; jobs download browsers as the jenkins user.
ARG PLAYWRIGHT_VERSION=1.58.2
RUN npx --yes playwright@${PLAYWRIGHT_VERSION} install-deps chromium && \
    npm cache clean --force && \
    rm -rf /var/lib/apt/lists/*

FROM browser-dependencies AS agent

RUN apt-get update --allow-releaseinfo-change && \
    apt-get install -y ruby-full && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists

# The Gemfile.lock in this directory requires bundler version 2.2.5,
# while 'homepage' (below) requires 2.6.3. Install both - otherwise
# 'bundle install' fails.
RUN gem install bundler:2.2.5 bundler:2.6.3

RUN mkdir /app-gem-tmp
COPY Gemfile /app-gem-tmp/Gemfile
COPY Gemfile.lock /app-gem-tmp/Gemfile.lock
RUN bundle install --gemfile=/app-gem-tmp/Gemfile && rm -rf /app-gem-tmp

RUN git clone https://gerrit.googlesource.com/homepage /tmp/homepage
RUN cd /tmp/homepage && \
    bundle install && \
    rm -rf /tmp/homepage

RUN curl -L https://firebase.tools/bin/linux/latest -o /usr/local/bin/firebase && \
    chmod +x /usr/local/bin/firebase
