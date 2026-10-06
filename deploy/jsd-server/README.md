# jsd-server deployments

Four stacks on this host, all built from `images/custom/Containerfile` with their own
`apps.json`, using external MariaDB (`mariadb-prod`) and Redis (`redis-cache` /
`redis-queue` containers on the shared `mariadb-prod_dbnet` / `redis_default` networks).

| Stack | Project | Image | Site | Apps |
|---|---|---|---|---|
| vanilla | `jsd-vanilla` | `jsd-vanilla-erpnext:16-crmlms` | `vanilla.whatthefrappe.id` (port 8091) | frappe, erpnext, hrms, payments, crm, lms, telephony, helpdesk, wiki, education, healthcare (marley), kamra, posawesome, insights, lending, raven |
| custom  | `jsd-custom`  | `jsd-custom-erpnext:16`         | (see `custom/`) | |
| shop | `jsd-shop` | `jsd-shop-erpnext:16` | `webshop.tataidekreatif.biz.id` (port 8093) | frappe, erpnext, payments, webshop, blog |
| commera | `jsd-commera` | `jsd-commera-erpnext:16` | `commera.tataidekreatif.biz.id` (port 8094) | frappe, erpnext, bwh_payments, bwh_shipping, commera, tata_payments |

`commera` ([bwhtech/commera](https://github.com/bwhtech/commera)) turns ERPNext into an
online shop; its bilingual Jinja/Alpine/Tailwind storefront and Vue 3 merchant dashboard both
ship inside the `commera` app itself (built by `bench build` during the image build) and are
served by the same `frontend` nginx service every stack already has — **no separate frontend
stack**, unlike the standalone `webshop-frontend` project used for `shop`. `commera`'s
`hooks.py` deliberately omits `frappe/payments` from `required_apps`: its companion
`bwh_payments` ships its own Payment Gateway Profile / base class instead. Install/apps.json
order matters here because of the `required_apps` chain: `erpnext` → `bwh_payments` (no
deps) → `bwh_shipping` (needs `erpnext`) → `commera` (needs all three). `erpnext` tracks
`version-16` and `commera` is pinned to its `v16.0.0-beta.2` release tag; `bwh_payments`/
`bwh_shipping` only have `develop`/`main` upstream, so they track `develop` (same situation
as `insights`/`telephony`/`wiki` in the `vanilla` stack); `commera`'s `pyproject.toml` pins
`frappe>=16,<17` so this is a v16 deployment.

Stack/folder/project/image are still named "shop" (matches the existing custom/espresso
naming precedent, where the folder name doesn't have to equal the site's FQDN) but the
actual site is `webshop.tataidekreatif.biz.id`.

`shop` uses MariaDB/Redis DB index 5/6, `commera` uses 7/8 (vanilla uses 3/4, custom uses
1/2, the native non-Docker bench uses db 0). Its DB user is `%`-host scoped (not pinned to a
container IP) so it survives `--force-recreate`/rebuilds — see "Gotcha" note below.

There is no separate blog site/stack: blogging lives on the `webshop.tataidekreatif.biz.id`
site itself via the `frappe/blog` app (**not** core Frappe's old Blog Post doctype —
that was removed from Frappe core in v16, only exists in v15 and earlier; see the
2026-09-14 note below).

App versions are **not pinned anywhere**: they resolve to the branch HEADs in each
stack's `apps.json` at image build time. `.env` files only point compose at the
image tag.

Each stack's `.env` is gitignored (real DB/Redis passwords live only on jsd-server).
On a fresh clone, copy `<stack>/.env.example` to `<stack>/.env` and fill in the
`<...>` secrets — non-secret values (ports, redis db index, gunicorn sizing) are
already correct in the example file.

Branches in `vanilla/apps.json`: erpnext/hrms/payments/education/marley/posawesome/lending =
`version-16`, helpdesk/crm/lms/kamra/raven = `main`, insights/telephony/wiki = `develop`
(insights `main` is the stale v2 line; active v3.x lives on `develop`).
Note: `helpdesk` requires `telephony` installed first, `marley` installs as the app
named `healthcare`, `kamra` requires `payments`, and `lending` requires `erpnext`.

## Redeploying — do you even need to rebuild the image?

Only a change to `apps.json` (added/removed/rebranched app) requires a new image.
Anything else does **not**:

- `.env` change (ports, `FRAPPE_SITE_NAME_HEADER`, gunicorn sizing, redis db index, …):
  just recreate the affected service(s), no build at all —
  `docker compose -p jsd-<stack> --env-file deploy/jsd-server/<stack>/.env -f compose.yaml -f overrides/compose.proxy.yaml -f deploy/jsd-server/compose.external-jsd.yaml up -d --force-recreate <service>`
- Restarting/recovering a stack: same command without `--force-recreate`, or `docker compose -p jsd-<stack> restart`.

## Update an app / all apps

Use `deploy/jsd-server/build.sh <stack>`, not a hand-written `docker build --no-cache`.
It resolves the **current upstream commit** of frappe + every app in `<stack>/apps.json`
with `git ls-remote`, writes them to `<stack>/build-lock.txt`, and passes their hash as
`CACHE_BUST`:

- any new upstream commit (even on an unchanged branch name in `apps.json`) → new hash →
  `bench init` re-clones and rebuilds everything, so the image is always exactly the
  branch HEADs at build time — same guarantee `--no-cache` used to give;
- the OS / apt / Node / wkhtmltopdf / chromium layers stay cached (they only change
  with the Containerfile or on `--full`);
- nothing changed upstream → no-op build in seconds.

`images/custom/Containerfile` also keeps uv/yarn/npm download caches in BuildKit cache
mounts (so a rebuilt `bench init` doesn't re-download every wheel/npm package) and
deletes every app's `node_modules` after `bench build` except `apps/frappe/node_modules`
(the `websocket` service runs `apps/frappe/socketio.js` on it). Assets are already
compiled, so the runtime never needs the rest — they were ~5 GB of the 12 GB vanilla image.

Monthly (or after a Debian/Python security advisory) run `build.sh <stack> --full`
(`--no-cache --pull`) so the base OS layers pick up apt security updates too.

```bash
cd /home/frappe/frappe-docker-jsd

# 1. Backup db + files
docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id backup --with-files

# 2. Build (tags the current image as :rollback-YYYYMMDD[-N] first — skipped for a
#    no-op build or TAG_OVERRIDE — then rebuilds the
#    stack's CUSTOM_IMAGE:CUSTOM_TAG from .env). Private git@ apps use
#    ~/.ssh/jsd-custom-apps-deploy-key (override with SSH_KEY=...).
deploy/jsd-server/build.sh vanilla          # add --full for the monthly base refresh
#    TAG_OVERRIDE=<tag> builds under a throwaway tag instead (lock file not updated)

# 3. Recreate the stack
docker compose -p jsd-vanilla \
  --env-file deploy/jsd-server/vanilla/.env \
  -f compose.yaml -f overrides/compose.proxy.yaml \
  -f deploy/jsd-server/compose.external-jsd.yaml up -d

# 4. Migrate + install any newly added apps + verify
docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id migrate
# only needed when apps.json gained new entries since the last build:
# docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id install-app <app>
docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id list-apps

# 5. Commit <stack>/build-lock.txt — the record of exactly which commits are deployed
```

For the other stacks substitute `jsd-custom`/`jsd-shop`/`jsd-commera` and the stack
name accordingly. The build happens while the old stack keeps serving; downtime is only
step 3 + `migrate`.

⚠️ Always check the real build exit code, not a pipe's — `build.sh ... | tail`
reports `tail`'s exit code (0) even when the build itself failed. Redirect to a
log file and check `$?`, or run without a pipe. (`build.sh` is `set -e`, and only
writes `build-lock.txt` after a successful build.)

## Rollback

```bash
docker tag jsd-vanilla-erpnext:rollback-YYYYMMDD jsd-vanilla-erpnext:16-crmlms
# then re-run steps 3-4 above and restore the pre-migrate backup:
docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id restore \
  /home/frappe/frappe-bench/sites/vanilla.whatthefrappe.id/private/backups/<backup>-database.sql.gz --with-files
```

## Notes

- `PULL_POLICY=never` — images are local-only builds, never pulled from a registry.
- The `sites` volume survives rebuilds; baked assets are re-symlinked on container
  start by `resources/core/main-entrypoint.sh`.
- To add an app: edit that stack's `apps.json`, then run the update procedure
  (remember `install-app` for new apps — the image build only bakes them into the bench).
- 2026-10-06: added private app `tata_payments` ([jeffrysurya/tata_payments](https://github.com/jeffrysurya/tata_payments), branch `master`, requires `bwh_payments`) to `commera`, cloned over SSH with the deploy key; built, migrated and `install-app`ed on `commera.tataidekreatif.biz.id` (pre-migrate backup `20261006_084454-*`).
- 2026-10-04: upgraded `commera` `v16-beta.1` → `v16.0.0-beta.2` (70 commits: guest
  checkout, email-code sign-in at checkout, settings tabs, dashboard apps switcher; one
  new patch `allow_guest_on_order_detail`, same `required_apps`). Upstream now also has a
  `version-16` branch (currently = `v16.0.0-beta.2`); kept the tag pin. frappe 16.36.1 /
  erpnext 16.37.0 / `bwh_payments` / `bwh_shipping` `develop` had no new commits since
  2026-10-03. Build 139s, `migrate` clean. Pre-update backup
  `20261004_101214-commera_tataidekreatif_biz_id-*`, rollback image
  `jsd-commera-erpnext:rollback-20261004`. Same day: wiped the site with `bench reinstall`
  (all 5 apps reinstalled, setup wizard not yet run; pre-wipe backup
  `20261004_101854-commera_tataidekreatif_biz_id-*`) — see the Gotcha below.
- 2026-10-03 (later): updated frappe 16.36.1 / erpnext 16.37.0 (version-16 HEAD) on
  `commera` (was already built), `shop` and `custom` via `build.sh` + `migrate` — all
  three healthy; `custom` jumped frappe 16.29→16.36.1, erpnext 16.30→16.37.0, hrms
  16.15→16.20.1. Build times: commera 178s, custom 163s, shop 11s (same commits as the
  earlier test build, so fully cached), vanilla 498s. Images: commera 5.49→3.86 GB.
  Exact commits in each `<stack>/build-lock.txt`. Rollback images:
  `jsd-{shop,custom}-erpnext:rollback-20261003`, `jsd-commera-erpnext:rollback-20261003-2`.
- 2026-10-03: **vanilla update blocked by `insights`.** `insights` `develop` now
  imports `@framework/ui/vite/island` via `"@framework/ui": "link:../../frappe/ui"`,
  which only exists in frappe `develop` (v17), not `version-16` → `bench build` fails.
  Switching `insights` to its release branch `version-3` (v3.14.2) builds fine, but this
  site was installed from `develop`, so `migrate` then runs ~39 legacy v2 patches that
  were never in its Patch Log and fails at `insights.patches.convert_duration_to_float`
  (`TableMissingError: Insights Query`). Lesson: an app's install lineage (branch) can't
  be switched freely — `develop` → release branch is effectively a downgrade. Pre-update
  backup: `20261003_144343-vanilla_whatthefrappe_id-*`, previous image
  `jsd-vanilla-erpnext:rollback-20261003`.
- 2026-10-03: replaced the always-`--no-cache` rebuild with `build.sh` (upstream
  commit SHAs via `git ls-remote` as `CACHE_BUST` + `build-lock.txt`), BuildKit cache
  mounts for uv/yarn/npm, and `node_modules` cleanup in `images/custom/Containerfile`.
  This fixes what the 2026-09-14 `sha256sum apps.json` attempt got wrong: the hash is
  over resolved commits, not over branch names, so new upstream commits still force a
  rebuild. Measured on `shop` (test tag, stack untouched): ~4 min `--no-cache` before →
  148s first build (cold download cache) → 123s with a real `bench init` re-run and warm
  cache → 0s build when nothing changed upstream; image 4.13 GB → 3.76 GB (vanilla, with
  far more frontend apps, should drop by ~5 GB). Socketio + gunicorn smoke-tested on the
  new image. Not yet deployed to any stack — the next real update on each stack is the
  first one through `build.sh`. Next step if builds still need to be faster/off-host:
  build in GitHub Actions and push to GHCR, server only pulls.
- 2026-10-03: pinned `commera` from `develop` to tag `v16-beta.1` in `commera/apps.json`
  (no `v16.0.0-beta.1` ref exists upstream; `v16-beta.1` is the only v16 release tag).
  `bwh_payments`/`bwh_shipping` still track `develop`. Needs an image rebuild + `migrate`.
- 2026-09-17: added `commera` stack (port 8094, redis db 7/8) —
  [bwhtech/commera](https://github.com/bwhtech/commera) + its required companion apps
  `bwh_payments`/`bwh_shipping`, on top of `erpnext` (version-16). Site created with
  `--mariadb-user-host-login-scope='%'` from the start (see Gotcha below) and
  `--db-root-username root --db-root-password <mariadb-prod root password>` (bench prompts
  for the root password interactively otherwise — non-interactive `docker exec` has no tty
  for that prompt). `commera`'s `after_install` hook throws (non-fatal, install still
  completes) trying to create default email templates before any Company/Fiscal Year
  exists — expected on a fresh site with no ERPNext setup wizard run yet; SETUP_GUIDE.md's
  "Rebuilding a demo site from nothing" section runs the setup wizard before anything else
  for this reason. No separate frontend stack: commera's storefront + dashboard build into
  the app itself and are served by the stock `frontend` nginx service.
- 2026-08-26: added `insights` (develop/v3), `lending` (version-16), `raven` (main);
  rollback image `jsd-vanilla-erpnext:rollback-20260826`.
- 2026-09-14: added `shop` (erpnext + payments + webshop, port 8093), site
  originally named `shop.tataidekreatif.biz.id`. `frappe/webshop` has no
  version-16 branch, only `develop` — same situation as telephony/wiki/insights.
  `webshop` requires `payments` (`required_apps` in its hooks.py) — not obvious
  from its own docs, had to add it to `apps.json` after the first
  `install-app webshop` failed with `ModuleNotFoundError: No module named
  'payments'`.
- 2026-09-14: also added, then same-day removed, a separate `blog` stack
  (frappe only, port 8094, `blog.tataidekreatif.biz.id`) on the wrong
  assumption that Blog Post ships with core Frappe — decided blogging should
  live on the `shop` site instead of its own stack. Removed via
  `docker compose -p jsd-blog down -v`, dropped its MariaDB database + user
  (`_64eda6224778c28a`), removed the `jsd-blog-frappe:16` image and
  `deploy/jsd-server/blog/`.
- 2026-09-14: turns out Blog Post/Blog Category were **removed from core
  Frappe in v16** (still present in v15 — checked both versions' source on
  GitHub: `frappe/frappe/frappe/website/doctype/` has `blog_post` etc. on
  `version-15`, gone on `version-16`). Added `frappe/blog` (branch `develop`,
  app_name `blog`, no extra `required_apps`) to `shop/apps.json` instead — this
  is Frappe's own standalone blog app for v16+. Also renamed the site itself
  from `shop.tataidekreatif.biz.id` to `webshop.tataidekreatif.biz.id`
  (`FRAPPE_SITE_NAME_HEADER` + a fresh `bench new-site` with all 4 apps, since
  this bench version has no `rename-site` command); the old
  `shop.tataidekreatif.biz.id` site + its database were dropped via
  `bench drop-site --no-backup --force`.
- 2026-09-14: briefly switched the rebuild procedure to a
  `CACHE_BUST=$(sha256sum apps.json)` scheme instead of `--no-cache`, to skip
  the ~70s OS/node/chromium setup layers on a no-op rebuild (confirmed: ~4min
  → ~2s). Reverted same day — in production, a hash of `apps.json` can't tell
  "upstream repo/module got new commits on an unchanged branch" apart from
  "nothing changed", so it would silently keep serving stale app code on any
  update that isn't a literal `apps.json` edit (e.g. active custom-app
  development, or just picking up upstream fixes). Not an acceptable tradeoff
  here — back to always `--no-cache` on every real rebuild. (Superseded 2026-10-03
  by `build.sh`, which hashes resolved upstream commits instead.)

## Gotcha: DB user host must be `%`, not a container IP

`bench new-site` grants the site's MariaDB user access scoped to whatever IP the
`backend` container had *at site-creation time* on `mariadb-prod_dbnet`, instead of
`%`. That's fine until the container is recreated (`--force-recreate`, an image
update, a host reboot) and gets a new IP — then every DB connection fails with
`Access denied for user '<db_user>'@'<new_ip>'`. All the pre-existing site users
(vanilla, custom) were already on `%`; only got caught on the `shop`/`blog` sites
because they were freshly created here. Fix (run once per affected site, as root
on `mariadb-prod`):

```bash
docker exec mariadb-prod mariadb -uroot -p'<root-password>' -e \
  "RENAME USER '<db_user>'@'<old_ip>' TO '<db_user>'@'%'; FLUSH PRIVILEGES;"
```

Worth checking (`SELECT user,host FROM mysql.user;`) after creating *any* new site
here, before the backend container ever gets recreated.

**`bench reinstall` does it too** (it has no `--mariadb-user-host-login-scope` option).
It leaves the old `'<db_user>'@'%'` account in place (same password from
`site_config.json`, grants survive the dropped database) and *adds* a
`'<db_user>'@'<container_ip>'` one, which MariaDB prefers because it's more specific —
so `RENAME USER` fails with `ERROR 1396` (target exists). Just drop the IP-scoped one:

```bash
docker exec mariadb-prod mariadb -uroot -p'<root-password>' -e \
  "DROP USER '<db_user>'@'<container_ip>'; FLUSH PRIVILEGES;"
```

Check which account the site actually logs in as with
`bench --site <site> execute frappe.db.sql --args '["select current_user()"]'` — it
should end in `@%`. (Hit on `commera` after its 2026-10-04 reinstall.)
