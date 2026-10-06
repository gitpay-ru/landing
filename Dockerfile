# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3
FROM ruby:${RUBY_VERSION}-slim

ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_NAME=jekyll

ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle \
    JEKYLL_ENV=development \
    HOME=/home/${USER_NAME}

# Native extensions (ffi, sass-embedded, eventmachine, ...) need a toolchain.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends --yes \
        build-essential \
        git \
        libffi-dev \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Run as an unprivileged user so that files written to the bind mount
# (`_site`, `.jekyll-cache`) stay owned by the host user.
RUN groupadd --gid ${USER_GID} ${USER_NAME} 2>/dev/null || true && \
    useradd --uid ${USER_UID} --gid ${USER_GID} --create-home --shell /bin/bash ${USER_NAME}

WORKDIR /site

# Install gems in their own layer: only re-resolved when the Gemfile changes.
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
    bundle clean --force && \
    mkdir -p /site/.jekyll-cache && \
    chown -R ${USER_UID}:${USER_GID} /site

COPY --chown=${USER_UID}:${USER_GID} . .

USER ${USER_NAME}

EXPOSE 4000
EXPOSE 35729

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD ruby -e "require 'net/http'; exit(Net::HTTP.get_response(URI('http://127.0.0.1:4000/')).is_a?(Net::HTTPSuccess) ? 0 : 1)"

# Default command serves the site with auto-reload.
# `--force_polling` is required for bind mounts (Docker Desktop, NFS, network FS).
CMD ["bundle", "exec", "jekyll", "serve", \
     "--host", "0.0.0.0", \
     "--port", "4000", \
     "--force_polling", \
     "--livereload", \
     "--livereload-min-delay", "100"]