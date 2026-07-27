# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Official container setup for Frappe/ERPNext. Not the Frappe framework itself — this repo builds Docker images and Compose orchestration around it. Contains no application code; changes are Dockerfiles (`Containerfile`), Compose YAML, shell scripts, and docs.

## Commands

**Lint** (pre-commit: black, isort, pyupgrade, prettier, codespell, shfmt, shellcheck). This is the only CI gate that runs on every push/PR to `main`:
```shell
pip install pre-commit
pre-commit install
pre-commit run --all-files       # run on everything
pre-commit run --files <path>    # run on specific files
```
shfmt is a `language: golang` local hook, so Go must be installed for a full run.

**Build images** (Docker Buildx Bake, targets defined in `docker-bake.hcl`):
```shell
FRAPPE_VERSION=... ERPNEXT_VERSION=... docker buildx bake <target>
# targets: bench, bench-test, erpnext, base, build
# groups:  default (= erpnext+base+build), base-images (= base+build)
```
Only `images/production/Containerfile` and `images/bench/Dockerfile` are wired into bake. `custom/` and `layered/` are built by hand or by CI workflows with `--build-arg`/`--secret`.

**Integration tests** (pytest, spins up a real Compose stack via Docker — slow, requires Docker):
```shell
python3 -m venv venv && source venv/bin/activate
pip install -r requirements-test.txt
FRAPPE_VERSION=v16.29.0 ERPNEXT_VERSION=v16.29.0 pytest
pytest tests/test_frappe_docker.py::test_endpoints    # single test
pytest -k Postgres                                    # subset by keyword
```
- `FRAPPE_VERSION` **must** be set — `test_assets_endpoint` reads `os.environ["FRAPPE_VERSION"]` at collection time and `KeyError`s otherwise ([test_frappe_docker.py:50](tests/test_frappe_docker.py#L50)).
- `setup.cfg` sets `addopts = -s --exitfirst`, so the run stops at the first failure.
- `conftest.py` copies `example.env` to a tmp `.env`, rewrites `SITES_RULE` for the three test hostnames, and maps version `develop` → tag `latest`. The `Compose` helper ([tests/utils.py](tests/utils.py)) always layers `compose.yaml` + `overrides/compose.proxy.yaml` + `compose.mariadb.yaml` + `compose.redis.yaml`; when the `CI` env var is set it also adds `tests/compose.ci.yaml`, which repoints every service at a `localhost:5000` local registry.
- Fixtures: `env_file`, `compose`, `frappe_setup` (session-autouse, brings the stack up), `frappe_site`, `erpnext_setup`/`erpnext_site` (class-scoped, restart the stack), `postgres_setup`, `python_path`, `s3_service` (runs a MinIO container for the restic backup test).

**Docs site** (VitePress, pnpm — run from `docs/`):
```shell
cd docs && corepack enable && pnpm i --frozen-lockfile
pnpm docs:dev      # local preview
pnpm docs:build    # what CI publishes
```

**Quick demo (non-production):**
```shell
docker compose -f pwd.yml up -d    # site on :8080, Administrator/admin
```

## Architecture

### Images (`images/`)
Four Dockerfiles with different bases and purposes:
- `bench/Dockerfile` — `FROM debian:bookworm-slim`. Bench CLI only, no runtime services. Stages `bench` → `bench-test`. Dev/debug use.
- `production/Containerfile` — `FROM python:${PYTHON_VERSION}-slim-${DEBIAN_BASE}`. Installs only Frappe + ERPNext; not customizable via apps.json. Stages: `base` → `build` → `builder` (runs `bench init` + `bench get-app erpnext`) → `erpnext` (final, copies the built bench from `builder`). Backed by bake targets `base`/`build`/`erpnext`.
- `custom/Containerfile` — same base as production, but installs apps from `apps.json` passed as a Docker build secret (`--mount=type=secret,id=apps_json`, mounted at `/opt/frappe/apps.json`). Stages: `base` → `builder` → `backend`. Preferred for real production/CI when you need control over included apps.
- `layered/Containerfile` — same end result as `custom` (same apps_json secret mechanism) but `FROM ${FRAPPE_IMAGE_PREFIX}/build` and `/base` — Frappe's prebuilt Docker Hub images — instead of building from scratch, so it builds much faster. `CACHE_BUST` build arg forces a rebuild of the `bench init` layer.

All runtime images share `resources/core/`:
- `main-entrypoint.sh` — the assets trick: images bake compiled assets to `/home/frappe/frappe-bench/assets`, then on container start delete `sites/assets` and symlink it to the baked path. This is why image-layer assets survive the shared `sites` volume, and why changing asset paths means touching both the Containerfile `cp`/`rm -rf` step and this script.
- `start.sh` — CMD; gunicorn with `GUNICORN_WORKERS`/`THREADS`/`TIMEOUT` on `:8000`.
- `nginx/` — `nginx-entrypoint.sh`, `nginx-template.conf`, `security_headers.conf`, used by the `frontend` service.

### Compose (`compose.yaml` + `overrides/`)
`compose.yaml` is the base — `configurator`, `backend`, `frontend`, `websocket`, `queue-short`, `queue-long`, `scheduler`. YAML anchors (`x-customizable-image`, `x-backend-defaults`, `x-depends-on-configurator`) share the `sites` named volume and the image `${CUSTOM_IMAGE:-frappe/erpnext}:${CUSTOM_TAG:-$ERPNEXT_VERSION}` — that pair is how a custom-built image gets swapped in. `configurator` runs once per `up` and writes DB/Redis/socketio config into `common_site_config.json`; every other service `depends_on` it with `condition: service_completed_successfully`.

It has **no database, no reverse proxy, no TLS** by design — those come from `overrides/compose.*.yaml`, layered in via `-f`:
- DB: `compose.mariadb.yaml` (own container), `compose.mariadb-shared.yaml`, `compose.mariadb-secrets.yaml`, `compose.postgres.yaml`
- Ingress: `compose.proxy.yaml` (default), `compose.traefik.yaml`/`-ssl`, `compose.nginxproxy.yaml`/`-ssl`, `compose.noproxy.yaml`
- Extras: `compose.https.yaml`, `compose.custom-domain.yaml`/`-ssl`, `compose.multi-bench.yaml`/`-ssl`, `compose.backup-cron.yaml`, `compose.redis.yaml`, `compose.migrator.yaml`

Real deployments combine several `-f` files plus `--env-file .env` (copied from `example.env`). See `docs/02-setup/05-overrides.md` and `docs/02-setup/06-setup-examples.md`.

`pwd.yml` is a self-contained single-file Compose setup (bundles DB/Redis/site-creation) for disposable demos only — not production, can't install custom apps.

### Development (`devcontainer-example/`, `development/`)
Real dev work happens inside a VS Code Dev Container, not by editing the image Dockerfiles. Copy `devcontainer-example/` → `.devcontainer/` and `development/vscode-example/` → `development/.vscode/` (both gitignored) to bootstrap. Inside the container run `bench init`/`get-app`/`new-site` against the mounted `development/` dir, connecting to the `mariadb`/`redis-cache`/`redis-queue` container hostnames. Walkthrough: `docs/05-development/01-development.md`.

### CI (`.github/workflows/`)
- `lint.yml` — pre-commit on all files, every push/PR to `main`.
- `core-build-develop.yml` / `core-build-stable.yml` / `core-build-bench.yml` — build and push the official images. `core-build-stable.yml` has one job per maintained major version; on an ERPNext major release, add the new version job, drop the unmaintained one, and re-point the `needs:` chain.
- `core-build-test-images.yml` + `core-publish-images.yml` — build test images into a local registry, run pytest against them, then publish.
- `app-build-image.yml` — reusable `workflow_call` for building a single Frappe app image (`app_name`, `app_repo`, `app_ref`, `frappe_ref` inputs).
- `docs-publish-site.yml` — pnpm/VitePress build of `docs/` to GitHub Pages.

## Docs

`docs/` is both browsed on GitHub and published as a VitePress site (`docs/index.md`, `docs/.vitepress/`, numbered subdirectories `01-getting-started/` … `09-concepts/`). New pages need frontmatter `title: <short-title>` (drives the sidebar); images go in `docs/images/` and are referenced with relative paths; keep markdown GitHub-compatible.

## Conventions
- Conventional Commits (`feat|fix|docs|style|refactor|test|chore|ci(scope): description`).
- Branch names: `feature/<description>`, `fix/<description>`, `docs/<description>`.
- Test builds locally before opening a PR.
- Debian/Python base bumps touch `images/production/Containerfile`, `images/custom/Containerfile`, `images/bench/Dockerfile`, and the `PYTHON_VERSION`/`NODE_VERSION` defaults in `docker-bake.hcl` (note: `CONTRIBUTING.md` still calls the first one `images/erpnext/Containerfile` — stale path).
- Fork/downstream maintenance: `docs/08-reference/03-fork-management.md`.
