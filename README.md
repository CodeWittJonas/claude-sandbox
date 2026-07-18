# claude-sandbox

Run [Claude Code](https://claude.com/claude-code) with `--dangerously-skip-permissions`
**without** letting it touch anything on your machine outside one project folder.

Skip-permissions lets the agent run every tool call without asking you to approve
each one — fast and hands-off, but it means an agent that goes sideways (a bad
`rm -rf`, an overwrite) hits your real filesystem. `claude-sandbox` moves that risk
into a throwaway Docker container: only your project folder is mounted in, so the
rest of your host filesystem isn't visible to the agent and can't be touched.

The container is deliberately conservative: **no Docker socket, no `--privileged`,
no host networking, non-root user.** It's a single bind mount and one optional
forwarded port — nothing that would hand the agent a path back to the host.

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

Tip: commit `.sandbox/` to your repo rather than gitignoring it — for a tool that
runs with skip-permissions, keeping the exact container config in version control
means you (and anyone reviewing) can audit what actually ran.

## What this does and doesn't protect — read this

**It does:** stop the agent from reaching *outside* your project folder. Other
projects, your home directory, dotfiles, SSH keys, and system files are never
mounted, so a rogue command can't see or touch them.

**Know what's *inside* the blast radius.** "Your project folder" means the whole
repo root, live-mounted read-write — which includes your **uncommitted work**, your
**`.git` history** (the agent can `git reset --hard` or `push --force`), and any
**secrets you keep in the repo** (`.env`, `.npmrc`, in-project cloud credentials).
The container protects everything *around* your project, not the project itself.
So: **commit or stash before a big run, and keep secrets out of the repo directory.**

**It does not protect your Claude credentials.** You authenticate *inside* the
container, so a compromised or prompt-injected agent could read that token. And
prompt injection is a realistic *accident*, not just a "deliberately hostile"
scenario — this image ships a web browser (Chromium) precisely so the agent can
fetch and render pages, which is exactly where injection comes from. Treat the
in-container credential as burnable, don't run prompts or install dependencies you
wouldn't trust with your account, and prefer a rotatable API key over your primary
login where you can.

**Why not just use Claude's built-in permission allowlist?** If you're happy
approving tool calls, you may not need this at all. This tool is for when you want
fully hands-off runs and have accepted `--dangerously-skip-permissions` — it makes
that choice less costly, it doesn't argue you should make it. Use the flag at your
own discretion.

## Platform support

- **macOS** — fully supported and tested.
- **Linux** — should work as-is (same UID/GID model). Untested.
- **Windows** — run it under **WSL2** or **Git Bash**; `run.sh` is a bash script and
  there's no native Windows launcher yet. The host-user (UID/GID) matching is a
  macOS/Linux concept and is ignored on Windows, which is fine.

## License

MIT — see [LICENSE](LICENSE).
