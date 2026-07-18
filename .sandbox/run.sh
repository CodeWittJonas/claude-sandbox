#!/usr/bin/env bash
#
# Build (if needed) and drop into a sandbox container with Claude Code ready.
# Your PROJECT ROOT (the parent of this .sandbox/ folder) is bind-mounted to
# /workspace, one port is forwarded, and the container is removed on exit.
#
# Usage:  ./.sandbox/run.sh          (run from your project root)
#
set -euo pipefail

# --- Config -----------------------------------------------------------------
IMAGE="claude-sandbox"
# Port forwarded from the container to your host, so you can open the app in your
# browser. Change this if your dev server uses a different port, or if this one is
# already taken on your machine. Set to empty ("") to forward no port at all.
PORT="3000"
# ----------------------------------------------------------------------------

# The project root is the parent of the folder this script lives in.
SANDBOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SANDBOX_DIR}/.." && pwd)"

# macOS: Docker Desktop's credential helper often isn't on a non-login shell's
# PATH, which makes `docker build` fail with "docker-credential-desktop not
# found". Add it silently if it's missing. Harmless everywhere else.
if [ "$(uname -s)" = "Darwin" ] && ! command -v docker-credential-desktop >/dev/null 2>&1; then
  export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
fi

# UID/GID matching is meaningful on macOS/Linux; on Windows the Dockerfile
# defaults are used and ignored by the bind-mount layer.
HOST_UID="$(id -u 2>/dev/null || echo 501)"
HOST_GID="$(id -g 2>/dev/null || echo 20)"

echo "==> Building image '${IMAGE}' (first build downloads Chromium, ~2-3 min)..."
docker build \
  --build-arg HOST_UID="${HOST_UID}" \
  --build-arg HOST_GID="${HOST_GID}" \
  -t "${IMAGE}" \
  "${SANDBOX_DIR}"

# Assemble the port flag only if a PORT is set.
PORT_ARGS=()
if [ -n "${PORT}" ]; then
  PORT_ARGS=(-p "${PORT}:${PORT}")
fi

echo "==> Launching sandbox. You are 'claude' in /workspace (your project root)."
echo "    Inside, run:  claude --dangerously-skip-permissions"
echo "    Then authenticate when prompted."
if [ -n "${PORT}" ]; then
  echo "    Dev server must bind 0.0.0.0:${PORT} -> open http://localhost:${PORT} on your host."
fi
echo

exec docker run --rm -it \
  -v "${PROJECT_DIR}:/workspace" \
  "${PORT_ARGS[@]}" \
  -w /workspace \
  "${IMAGE}" \
  /bin/bash
