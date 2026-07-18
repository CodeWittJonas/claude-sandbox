# Using the sandbox

This `.sandbox/` folder is self-contained tooling you copied into your project.
It runs Claude Code inside a throwaway Docker container so the agent can work
with `--dangerously-skip-permissions` without being able to touch anything on
your machine outside this project folder.

## Run it

From your **project root** (the folder that contains `.sandbox/`):

```bash
./.sandbox/run.sh
```

1. First run builds the image (~2–3 min — downloads Chromium). Later runs are instant.
2. You land in a shell as user `claude` in `/workspace`, which is your project
   root, live-mounted. Files you/the agent create appear on your host immediately.
3. Start the agent:
   ```bash
   claude --dangerously-skip-permissions
   ```
4. Authenticate when prompted, then tell it what to build.
5. `exit` to tear the container down. The container is ephemeral, so you
   re-authenticate next run — this is convenience, not a security guarantee: while
   a session is live, the credential sits inside the container and is readable there.

## Telling the agent about the browser + port

Chromium + Playwright are preinstalled so the agent can screenshot the app to
check its own work. A prompt that sets it up well:

> Run the dev server on `0.0.0.0:3000` (not 127.0.0.1). Use Playwright + headless
> Chromium to open http://localhost:3000 and screenshot it to verify your work.

Then open **http://localhost:3000** in your host browser.

## Config

- **Port:** edit `PORT` at the top of `run.sh` (default `3000`). Set it to `""` to
  forward nothing. Change it if 3000 is taken or your dev server uses another port.
- The port only matters if you're running something (like a web dev server) you
  want to reach from your host browser. For non-web work you can ignore it.

## Gotchas

- **Bind to `0.0.0.0`, not `127.0.0.1`.** A server on `127.0.0.1` inside the
  container is unreachable from your host even with the port forwarded.
- **`address already in use`?** Something on your host already holds that port.
  Change `PORT` in `run.sh`, or free the port.
- **macOS `docker-credential-desktop not found`?** `run.sh` auto-fixes this. If it
  persists, ensure Docker Desktop is running.
