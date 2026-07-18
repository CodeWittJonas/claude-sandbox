# Sandbox image for running Claude Code with --dangerously-skip-permissions,
# with the blast radius contained to a single bind-mounted /workspace.
# See USAGE.md (next to this file) for the flow.
# Base pinned by digest for reproducible builds. To update: re-pull node:24-bookworm
# and replace the digest below.
FROM node:24-bookworm@sha256:5711a0d445a1af54af9589066c646df387d1831a608226f4cd694fc59e745059

# --- Build args: match the host user so bind-mounted files aren't root-owned ---
# Relevant on macOS/Linux (default macOS user is UID 501 / GID 20). On Windows +
# Docker Desktop these are ignored by the bind-mount translation layer, which is
# fine -- run.sh passes host values on macOS/Linux and harmless defaults elsewhere.
ARG HOST_UID=501
ARG HOST_GID=20
ARG USERNAME=claude

# --- System deps for Playwright / headless Chromium ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    dumb-init \
 && rm -rf /var/lib/apt/lists/*

# --- Global CLIs: Claude Code + Playwright (pinned for reproducibility) ---
# The Playwright CLI and library versions must match, or the browser download
# won't line up with the installed library. Bump both together.
RUN npm install -g @anthropic-ai/claude-code@2.1.214 playwright@1.61.1

# Install Chromium's OS-level libraries as root (needs apt).
RUN npx --yes playwright@1.61.1 install-deps chromium

# --- Non-root user (required: skip-permissions refuses to run as root) ---
# The group for HOST_GID may already exist in the base image (e.g. GID 20), so
# only create it when missing, then create the user against that group.
RUN if ! getent group "${HOST_GID}" >/dev/null; then \
        groupadd -g "${HOST_GID}" "${USERNAME}"; \
    fi \
 && useradd -m -u "${HOST_UID}" -g "${HOST_GID}" -s /bin/bash "${USERNAME}" \
 && mkdir -p /workspace \
 && chown "${HOST_UID}:${HOST_GID}" /workspace

# Put Playwright's browser binaries in a shared location owned by the user,
# then download Chromium itself *as that user* so paths and perms line up.
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers
RUN mkdir -p /opt/pw-browsers && chown "${HOST_UID}:${HOST_GID}" /opt/pw-browsers

USER ${USERNAME}
WORKDIR /workspace

RUN npx --yes playwright@1.61.1 install chromium

# dumb-init reaps zombie Chromium processes cleanly.
ENTRYPOINT ["dumb-init", "--"]
CMD ["/bin/bash"]
