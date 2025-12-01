FROM gerritforge/gerrit-ci-agent-bazel:debian-bookworm-$CHROME_VER

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/debian \
      bookworm \
      stable" && \
    apt-get update --allow-releaseinfo-change && \
    apt-get install -y docker-ce=5:24.0.9-1~debian.12~bookworm git-

# Restore the Git executables after the removal caused by docker-ce
RUN ln -sf /usr/libexec/git-core/* /usr/bin/

RUN curl -L \
    "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
