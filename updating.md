# Updating Beatnik Icecast Bridge

Use these steps to update an existing deployment while preserving its configuration.

## 1. Prepare

Open a terminal in the project directory and check for local changes:

```bash
git status
```

Commit or otherwise preserve any changes you want to keep before updating. Keep
your existing `.env` file; it contains the deployment-specific settings and
should not be replaced with repository defaults.

## 2. Get the latest version

```bash
git pull --ff-only
```

If Git cannot fast-forward because of local changes or branch divergence, stop
and resolve that before continuing rather than forcing the update.

## 3. Rebuild and restart

```bash
docker compose up -d --build
```

This rebuilds the bridge image and starts or recreates the services using the
updated configuration. Docker Compose keeps the existing `.env` values.

## 4. Verify the deployment

Check that the services are running:

```bash
docker compose ps
```

Review the service logs for startup errors and confirm the bridge connects to
Snapserver and streams to Icecast:

```bash
docker compose logs --tail=100
```

Then test the stream at `http://<your-pi-ip>:8010/stream` or, if configured,
through your Cloudflare public hostname.

## Troubleshooting

- If a service is unhealthy or exits, inspect its logs with
  `docker compose logs <service>`.
- Confirm `.env` still has the correct Snapserver, Icecast, and optional tunnel
  settings. Do not share or commit this file.
- To restart the services without rebuilding, run `docker compose up -d`.
- To stop the stack, run `docker compose down`. This does not remove the project
  files or `.env`.
