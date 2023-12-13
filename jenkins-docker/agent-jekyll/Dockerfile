FROM gerritforge/gerrit-ci-agent-python3:bullseye

RUN apt-get update --allow-releaseinfo-change && \
    apt-get install -y ruby-full && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists

# The Gemfile.lock in this directory requires bundler version 2.2.5,
# while 'homepage' (below) requires 1.17.1. Install both - otherwise
# 'bundle install' fails.
RUN gem install bundler:2.2.5 bundler:1.17.1

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
