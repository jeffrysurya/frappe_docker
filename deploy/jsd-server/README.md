# jsd-server deployments

Three stacks on this host, all built from `images/custom/Containerfile` with their own
`apps.json`, using external MariaDB (`mariadb-prod`) and Redis (`redis-cache` /
`redis-queue` containers on the shared `mariadb-prod_dbnet` / `redis_default` networks).

| Stack | Project | Image | Site | Apps |
|---|---|---|---|---|
| vanilla | `jsd-vanilla` | `jsd-vanilla-erpnext:16-crmlms` | `vanilla.whatthefrappe.id` (port 8091) | frappe, erpnext, hrms, payments, crm, lms, telephony, helpdesk, wiki, education, healthcare (marley), kamra, posawesome, insights, lending, raven |
| custom  | `jsd-custom`  | `jsd-custom-erpnext:16`         | (see `custom/`) | |
| shop | `jsd-shop` | `jsd-shop-erpnext:16` | `webshop.tataidekreatif.biz.id` (port 8093) | frappe, erpnext, payments, webshop, blog |

Stack/folder/project/image are still named "shop" (matches the existing custom/espresso
naming precedent, where the folder name doesn't have to equal the site's FQDN) but the
actual site is `webshop.tataidekreatif.biz.id`.

`shop` uses MariaDB/Redis DB index 5/6 (vanilla uses 3/4, custom uses 1/2, the native
non-Docker bench uses db 0). Its DB user is `%`-host scoped (not pinned to a container
IP) so it survives `--force-recreate`/rebuilds — see "Gotcha" note below.

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

Always `--no-cache`, on purpose, every time you rebuild — this is production, and
a hash-of-`apps.json` cache-bust (tried and reverted 2026-09-14, see Notes) cannot
tell "app code updated upstream on the same branch" apart from "nothing changed",
so it would silently skip re-cloning updated app code. `--no-cache` guarantees
what's running is exactly what's in each app's configured branch HEAD at build
time, at the cost of ~5-10 min per rebuild. Any repo/module update — including
active development on a custom app — means a full `--no-cache` rebuild, no
shortcut.

```bash
cd /home/frappe/frappe-docker-jsd

# 1. Backup db + files
docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id backup --with-files

# 2. Rollback tag of the current image
docker tag jsd-vanilla-erpnext:16-crmlms jsd-vanilla-erpnext:rollback-$(date +%Y%m%d)

# 3. Rebuild the same tag from latest branch HEADs (~5-10 min)
docker build --no-cache \
  --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
  --build-arg=FRAPPE_BRANCH=version-16 \
  --secret=id=apps_json,src=deploy/jsd-server/vanilla/apps.json \
  --tag=jsd-vanilla-erpnext:16-crmlms \
  --file=images/custom/Containerfile .

# 4. Recreate the stack
docker compose -p jsd-vanilla \
  --env-file deploy/jsd-server/vanilla/.env \
  -f compose.yaml -f overrides/compose.proxy.yaml \
  -f deploy/jsd-server/compose.external-jsd.yaml up -d

# 5. Migrate + install any newly added apps + verify
docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id migrate
# only needed when apps.json gained new entries since the last build:
# docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id install-app <app>
docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id list-apps
```

For the custom/shop stacks substitute `jsd-custom`/`jsd-shop` and `custom/`/`shop/`
paths accordingly.

⚠️ Always check the real build exit code, not a pipe's — `docker build ... | tail`
reports `tail`'s exit code (0) even when the build itself failed. Redirect to a
log file and check `$?` right after the `docker build` line, or run without a
pipe.

## Rollback

```bash
docker tag jsd-vanilla-erpnext:rollback-YYYYMMDD jsd-vanilla-erpnext:16-crmlms
# then re-run steps 4-5 above and restore the pre-migrate backup:
docker exec jsd-vanilla-backend-1 bench --site vanilla.whatthefrappe.id restore \
  /home/frappe/frappe-bench/sites/vanilla.whatthefrappe.id/private/backups/<backup>-database.sql.gz --with-files
```

## Notes

- `PULL_POLICY=never` — images are local-only builds, never pulled from a registry.
- The `sites` volume survives rebuilds; baked assets are re-symlinked on container
  start by `resources/core/main-entrypoint.sh`.
- To add an app: edit that stack's `apps.json`, then run the update procedure
  (remember `install-app` for new apps — the image build only bakes them into the bench).
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
  here — back to always `--no-cache` on every real rebuild.

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
