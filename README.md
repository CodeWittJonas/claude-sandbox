# claude-sandbox

Run [Claude Code](https://claude.com/claude-code) with `--dangerously-skip-permissions`
**without** letting it touch anything on your machine outside one project folder.

Skip-permissions lets the agent run every tool call without asking you to approve
each one — fast and hands-off, but it means an agent that goes sideways (a bad
`rm -rf`, an overwrite) hits your real filesystem. `claude-sandbox` moves that risk
into a throwaway Docker container: the agent runs **on top of** your machine, not
**in** it. Only the project folder is mounted in, so that's the entire blast radius.

Chromium + Playwright come preinstalled, so the agent can screenshot the app it's
building and check its own work.

## Quick start (macOS)

Requires [Docker Desktop](https://www.docker.com/products/docker-desktop/) running.

```bash
# From inside the project you want the agent to work on:
git clone https://github.com/codewittjonas/claude-sandbox /tmp/claude-sandbox
cp -r /tmp/claude-sandbox/.sandbox .

./.sandbox/run.sh
```

Then, inside the container:

```bash
claude --dangerously-skip-permissions
```

Authenticate when prompted, tell it what to build, and open **http://localhost:3000**
in your browser to watch the app come up. `exit` tears the container down — nothing
persists.

Full details are in [`.sandbox/USAGE.md`](.sandbox/USAGE.md).

Tip: add `.sandbox/` to your project's `.gitignore` if you don't want the tooling
committed alongside your code. Your call.

## What this does and doesn't protect

**It does:** contain accidental filesystem damage. A rogue command inside the
container can only affect the mounted project folder — the rest of your home
directory, other projects, and system files are invisible to the agent.

**It does not** protect your Claude credentials. You authenticate *inside* the
container, so a compromised or prompt-injected agent could read that token. This
tool is about containing *accidents*, not defending against a deliberately hostile
agent. Don't run prompts or install dependencies you wouldn't trust with your
account. **Use `--dangerously-skip-permissions` at your own discretion** — it exists
precisely so the agent doesn't stop to ask, which is powerful and worth respecting.

## Platform support

- **macOS** — fully supported and tested.
- **Linux** — should work as-is (same UID/GID model). Untested.
- **Windows** — run it under **WSL2** or **Git Bash**; `run.sh` is a bash script and
  there's no native Windows launcher yet. The host-user (UID/GID) matching is a
  macOS/Linux concept and is ignored on Windows, which is fine.

## License

MIT — see [LICENSE](LICENSE).
