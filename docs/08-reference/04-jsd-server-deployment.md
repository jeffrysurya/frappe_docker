---
title: jsd-server Deployment
---

# jsd-server Deployment

Internal reference for the two Frappe stacks running on host `jsd-server`
(Tailscale: `JSD-Server-frappe-via-Tailscale`, `100.65.223.66`, user `frappe`), out of a single
checkout at `~/frappe-docker-jsd` on branch `custom`.

| Stack         | Compose project | Site                        | Port | Apps                                                         |
| ------------- | --------------- | --------------------------- | ---- | ------------------------------------------------------------ |
| `jsd-vanilla` | `jsd-vanilla`   | `vanilla.whatthefrappe.id`  | 8091 | erpnext, hrms, payments, crm, lms (all upstream `frappe/*`)  |
| `jsd-custom`  | `jsd-custom`    | `espresso.whatthefrappe.id` | 8092 | erpnext, hrms, procurement + tcs_hrms (private `MGM-CLUB/*`) |

Both share the same `~/frappe-docker-jsd/compose.yaml` and
[`overrides/compose.proxy.yaml`](../02-setup/05-overrides.md), and connect out to a shared external
`mariadb-prod` and `redis-cache`/`redis-queue` via `deploy/jsd-server/compose.external-jsd.yaml`
(see [Overrides](../02-setup/05-overrides.md)). They differ only in `-p` project name,
`--env-file`, and `apps.json`, each under `deploy/jsd-server/<stack>/`.

## Pipeline

Edit locally → commit → push → pull on server → build on server → compose up on server.

```bash
# local
git add deploy/jsd-server/... images/custom/Containerfile
git commit -m "..."
git push origin custom

# on jsd-server
cd ~/frappe-docker-jsd && git pull --ff-only
```

The image is only ever built and used locally on the host (`PULL_POLICY=never` in every
`deploy/jsd-server/*/.env`), so the build step below always runs **on the server**, never locally.

## Build

```bash
cd ~/frappe-docker-jsd
docker build \
  --file images/custom/Containerfile \
  --build-arg FRAPPE_BRANCH=version-16 \
  --build-arg CACHE_BUST=$(date +%s) \
  --secret id=apps_json,src=deploy/jsd-server/<stack>/apps.json \
  --tag <image-name>:<tag> .
```

- `CACHE_BUST` is required on every rebuild — `apps.json` is mounted as a build secret, so editing
  it does **not** by itself invalidate the `bench init` Docker layer.
- `apps.json` pins **branches**, not tags/commits, so every rebuild pulls the tip of that branch.
  For the vanilla stack this means `frappe`/`erpnext`/`hrms` silently move forward on every
  rebuild — always `bench backup` before, and `bench migrate` after (see below).
- Private apps (`jsd-custom` only) are cloned over `git@github.com:...` and need the deploy key
  forwarded into the build, in addition to the secret:
  ```bash
  docker build \
    --file images/custom/Containerfile \
    --build-arg FRAPPE_BRANCH=version-16 \
    --build-arg CACHE_BUST=$(date +%s) \
    --ssh default=$HOME/.ssh/jsd-custom-apps-deploy-key \
    --secret id=apps_json,src=deploy/jsd-server/custom/apps.json \
    --tag jsd-custom-erpnext:16 .
  ```
  The deploy key must be added as a **read-only deploy key** on each private repo in `apps.json`
  (GitHub → repo → Settings → Deploy keys). `images/custom/Containerfile` already installs
  `openssh-client` and pre-seeds `known_hosts` for `github.com` to support this.

## Deploy

```bash
cd ~/frappe-docker-jsd
docker compose \
  --project-name <jsd-vanilla|jsd-custom> \
  --env-file deploy/jsd-server/<stack>/.env \
  -f compose.yaml \
  -f overrides/compose.proxy.yaml \
  -f deploy/jsd-server/compose.external-jsd.yaml \
  up -d
```

`deploy/jsd-server/<stack>/.env` is gitignored and lives only on the server — that's where
`CUSTOM_IMAGE`/`CUSTOM_TAG` select which built image the stack runs. Bump `CUSTOM_TAG` there
(not in the repo) to point a stack at a freshly built image.

`up -d` only recreates containers whose config actually changed (image tag, command args, env) —
safe to re-run after any of the changes above.

### First-time site creation (new stack only)

```bash
docker exec -it <project>-backend-1 bench new-site <site-name> \
  --db-host $DB_HOST --db-port $DB_PORT \
  --admin-password <pick-one> \
  --no-mariadb-socket
docker exec <project>-backend-1 bench --site <site-name> install-app erpnext
```

Then set `FRAPPE_SITE_NAME_HEADER=<site-name>` in that stack's `.env` and `up -d` again, so the
frontend serves the site regardless of `Host` header (useful when accessing via
`<tailscale-ip>:<port>` instead of the real domain).

## Post-rebuild: migrate + install new apps

```bash
docker exec <project>-backend-1 bench --site <site-name> migrate
docker exec <project>-backend-1 bench --site <site-name> install-app <app1> <app2> ...
```

`install-app` resolves each app's own `required_apps` from its `hooks.py` and installs them first
if they're already present in the bench — but `bench init --apps_path=apps.json` does **not**
resolve those dependencies at clone time. Anything a target app hard-depends on must be listed in
`apps.json` explicitly, or the image builds fine and `install-app` fails later. Known case:
`frappe/lms` requires `frappe/payments` — pin it to `version-16` (its `develop` branch targets
frappe v17). Neither `frappe/crm` nor `frappe/lms` ship a `version-16` branch; both only have
`main`, and both declare frappe-version compatibility covering v16.

## Backup / rollback

```bash
# backup before any rebuild/migrate
docker exec <project>-backend-1 bench --site <site-name> backup --with-files

# rollback: point .env back at the previous image tag, then
docker compose --project-name <project> --env-file deploy/jsd-server/<stack>/.env \
  -f compose.yaml -f overrides/compose.proxy.yaml -f deploy/jsd-server/compose.external-jsd.yaml \
  up -d

# restore a backup if the site itself needs rolling back too
docker exec <project>-backend-1 bench --site <site-name> restore \
  sites/<site-name>/private/backups/<timestamp>-<site-name>-database.sql.gz
```

The previous image tag is left on disk after a rebuild specifically so this rollback stays a
one-line `.env` edit + `up -d` — don't `docker rmi` an old tag until the new one has been running
cleanly for a while.

## Logs

`docker compose logs` only needs the project name — it filters containers by the
`com.docker.compose.project` label, so the `--env-file`/`-f` flags aren't required for this one:

```bash
docker compose -p <jsd-vanilla|jsd-custom> logs -f            # all services
docker compose -p <jsd-vanilla|jsd-custom> logs -f backend     # one service
docker compose -p <jsd-vanilla|jsd-custom> logs -f --tail 0    # skip history, live only
```

## Known issue: cross-stack gateway timeouts via shared Traefik

`overrides/compose.proxy.yaml` gives each stack its own `proxy` (Traefik) container, but Traefik's
Docker provider reads the whole host's `docker.sock`, not just its own compose project. Because
both stacks come from the same `compose.yaml`, their `frontend` containers carry **identical**
router/service labels (`frontend-http` / `frontend`) — each stack's Traefik discovered _both_
stacks' frontend containers under that name and load-balanced across them. A `proxy` container is
only network-attached to its own stack's bridge network, so any request round-robined to the
sibling stack's frontend had no route and hung until client timeout — a consistent, exactly ~50%
intermittent gateway timeout once a second stack was added to the host.

Fixed by constraining each stack's Traefik to only its own containers
(`overrides/compose.proxy.yaml`):

```
--providers.docker.constraints=Label(`com.docker.compose.project`, `${COMPOSE_PROJECT_NAME}`)
```

`COMPOSE_PROJECT_NAME` is set automatically by Compose from `-p`/`--project-name`, so no extra
`.env` entry is needed. Only the `proxy` container needs recreating (`up -d`) after this change —
zero downtime for the rest of the stack.

This is a workaround, not the textbook fix — [`compose.traefik.yaml`](../02-setup/05-overrides.md)
(a standalone shared Traefik on a `traefik-public` network) is the override meant for genuine
multi-stack hosts. Worth migrating to if a third stack joins this host.

### Diagnosing a "gateway timeout" on this host in general

Don't assume Tailscale/network first — isolate layer by layer, fastest discriminator first:

1. `docker stats --no-stream` + `uptime` — rule out CPU/memory pressure.
2. Repeat a `curl -o /dev/null -w '%{http_code} %{time_total}\n'` request 10-20x **from the
   server itself** against `localhost:<port>`. A clean pass/fail split (especially exactly
   alternating) points at routing, not intermittent network flakiness.
3. Hit the `frontend` container directly, bypassing Traefik entirely
   (`docker run --rm --network <project>_default curlimages/curl curl ... http://frontend:8080/`).
   If that's 100% clean, the bug is in the proxy layer, not the app.
4. Hit the `proxy` container's own IP directly
   (`docker run --rm --network container:<project>-proxy-1 curl ...`), bypassing the host's
   port-publish/NAT layer. If the failure reproduces here too, it's Traefik's routing/discovery,
   not Docker networking — see the constraint fix above.
