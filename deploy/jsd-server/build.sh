#!/usr/bin/env bash
# Build a jsd-server stack image from images/custom/Containerfile.
#
#   deploy/jsd-server/build.sh <stack> [--full]
#
# Resolves the current upstream commit of frappe + every app in <stack>/apps.json with
# `git ls-remote`, writes them to <stack>/build-lock.txt and passes their hash as
# CACHE_BUST. Any new upstream commit changes the hash and re-runs `bench init`; the
# OS/Node/apt layers stay cached. If nothing changed upstream, the build is a no-op.
#
# --full: --no-cache --pull, rebuilds everything incl. the base OS layers (monthly, for
# Debian/apt security updates).
#
# Tags the current image as <image>:rollback-YYYYMMDD[-N] before building. Does not touch the
# running stack - recreate + migrate afterwards (see README.md).
set -euo pipefail

STACK=${1:?usage: $0 <stack> [--full]}
MODE=${2:-}
REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
STACK_DIR=$REPO_ROOT/deploy/jsd-server/$STACK
APPS_JSON=$STACK_DIR/apps.json
FRAPPE_PATH=${FRAPPE_PATH:-https://github.com/frappe/frappe}
FRAPPE_BRANCH=${FRAPPE_BRANCH:-version-16}
# Deploy key for private git@github.com:... apps (custom stack)
SSH_KEY=${SSH_KEY:-$HOME/.ssh/jsd-custom-apps-deploy-key}

[ -f "$APPS_JSON" ] || {
	echo "no $APPS_JSON" >&2
	exit 1
}
IMAGE=$(grep -E '^CUSTOM_IMAGE=' "$STACK_DIR/.env" | cut -d= -f2)
# TAG_OVERRIDE builds under a throwaway tag, leaving the stack's image untouched
TAG=${TAG_OVERRIDE:-$(grep -E '^CUSTOM_TAG=' "$STACK_DIR/.env" | cut -d= -f2)}
[ -n "$IMAGE" ] && [ -n "$TAG" ] || {
	echo "CUSTOM_IMAGE/CUSTOM_TAG missing in $STACK_DIR/.env" >&2
	exit 1
}

export GIT_SSH_COMMAND="ssh -F /dev/null -i $SSH_KEY -o IdentitiesOnly=yes"

resolve() { # <url> <branch-or-tag> -> commit sha
	local sha
	sha=$(git ls-remote "$1" "refs/heads/$2" "refs/tags/$2^{}" "refs/tags/$2" | head -1 | cut -f1)
	[ -n "$sha" ] || {
		echo "cannot resolve $2 on $1" >&2
		exit 1
	}
	echo "$sha"
}

LOCK=$STACK_DIR/build-lock.txt
{
	echo "$FRAPPE_PATH $FRAPPE_BRANCH $(resolve "$FRAPPE_PATH" "$FRAPPE_BRANCH")"
	jq -r '.[] | "\(.url) \(.branch)"' "$APPS_JSON" | while read -r url branch; do
		echo "$url $branch $(resolve "$url" "$branch")"
	done
} >"$LOCK.tmp"
CACHE_BUST=$(sha256sum "$LOCK.tmp" | cut -c1-16)
echo "== $STACK: $IMAGE:$TAG, CACHE_BUST=$CACHE_BUST"
cat "$LOCK.tmp"

if docker image inspect "$IMAGE:$TAG" >/dev/null 2>&1; then
	# Never overwrite an existing rollback tag (e.g. a second build on the same day)
	ROLLBACK=rollback-$(date +%Y%m%d)
	n=2
	while docker image inspect "$IMAGE:$ROLLBACK" >/dev/null 2>&1; do
		ROLLBACK=rollback-$(date +%Y%m%d)-$n
		n=$((n + 1))
	done
	docker tag "$IMAGE:$TAG" "$IMAGE:$ROLLBACK"
	echo "== tagged current image as $IMAGE:$ROLLBACK"
fi

EXTRA=()
[ "$MODE" = "--full" ] && EXTRA+=(--no-cache --pull)
grep -q 'git@' "$APPS_JSON" && EXTRA+=(--ssh "default=$SSH_KEY")

start=$(date +%s)
docker build "${EXTRA[@]}" \
	--build-arg=FRAPPE_PATH="$FRAPPE_PATH" \
	--build-arg=FRAPPE_BRANCH="$FRAPPE_BRANCH" \
	--build-arg=CACHE_BUST="$CACHE_BUST" \
	--secret=id=apps_json,src="$APPS_JSON" \
	--label=jsd.build-lock="$CACHE_BUST" \
	--tag="$IMAGE:$TAG" \
	--file="$REPO_ROOT/images/custom/Containerfile" "$REPO_ROOT"

# Only record the lock once the stack's image with exactly these commits exists
if [ -z "${TAG_OVERRIDE:-}" ]; then mv "$LOCK.tmp" "$LOCK"; else LOCK=$LOCK.tmp; fi
echo "== built $IMAGE:$TAG in $(($(date +%s) - start))s; commits in $LOCK"
