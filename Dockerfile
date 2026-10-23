FROM graph-localization-base:latest

# Install Bazelisk, which selects the Bazel version
# specified by the repository's .bazelversion file.
ARG BAZELISK_VERSION=1.27.0
RUN curl -fsSL \
        "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64" \
        -o /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

# Pre-download the project's Bazel version as root.
ENV BAZELISK_HOME=/opt/bazelisk
COPY .bazelversion /tmp/bazel-version/.bazelversion
RUN mkdir -p "${BAZELISK_HOME}" && \
    cd /tmp/bazel-version && \
    bazel version

# Move the pre-downloaded Bazelisk cache into ubuntu's home.
RUN mkdir -p /home/ubuntu/.cache && \
    mv /opt/bazelisk /home/ubuntu/.cache/bazelisk && \
    chown -R ubuntu:ubuntu /home/ubuntu/.cache
ENV BAZELISK_HOME=/home/ubuntu/.cache/bazelisk

# Install Buildifier for Bazel/Starlark formatting and linting.
ARG BUILDIFIER_VERSION=8.2.1
RUN curl -fsSL \
    "https://github.com/bazelbuild/buildtools/releases/download/v${BUILDIFIER_VERSION}/buildifier-linux-amd64" \
    -o /usr/local/bin/buildifier && \
    chmod +x /usr/local/bin/buildifier

# Keep interactive shell history in a dedicated persistent volume.
COPY .devcontainer/bash-history.sh /etc/graph-localization-bash-history.sh
RUN mkdir -p /commandhistory && \
    touch /commandhistory/.bash_history && \
    chown -R ubuntu:ubuntu /commandhistory && \
    printf '\nsource /etc/graph-localization-bash-history.sh\n' >> /home/ubuntu/.bashrc

# Persist Codex login, settings, and sessions in a dedicated volume.
RUN install -d -m 700 -o ubuntu -g ubuntu /home/ubuntu/.codex && \
    printf 'cli_auth_credentials_store = "file"\n' > /home/ubuntu/.codex/config.toml && \
    chown ubuntu:ubuntu /home/ubuntu/.codex/config.toml && \
    chmod 600 /home/ubuntu/.codex/config.toml

WORKDIR /workspace
CMD ["/bin/bash"]
