#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PATCH_FILE="$SCRIPT_DIR/patches/open-authority-web-only.patch"
TARGET_DIR="${1:-}"
BUILD="${BUILD:-1}"

if [[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR/.git" ]]; then
  echo "Usage: $0 /path/to/official/deepseek-harness" >&2
  exit 2
fi

cd "$TARGET_DIR"
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "The target checkout has uncommitted changes; refusing to mix them with the product patch." >&2
  exit 3
fi

if git apply --reverse --check "$PATCH_FILE" >/dev/null 2>&1; then
  echo "The remote/web-only patch is already applied."
elif git apply --check "$PATCH_FILE" >/dev/null 2>&1; then
  echo "Applying the remote/web-only patch..."
  git apply --3way "$PATCH_FILE"
else
  echo "The patch does not apply cleanly to this checkout." >&2
  echo "Use the official Harness commit documented in UPSTREAM-COMMIT.txt or review the patch manually." >&2
  exit 4
fi

echo "Installing dependencies..."
pnpm install --frozen-lockfile

if [[ "$BUILD" == "1" ]]; then
  echo "Building client libraries, host libraries, and web assets..."
  pnpm run build:lib:client
  pnpm run build:lib:host
  pnpm run build:web
fi

echo
echo "Modification complete: $TARGET_DIR"
echo "Run locally:"
echo "  pnpm dsh web --host 0.0.0.0 --open-authority --no-open"
echo ""
echo "Security note: open-authority grants every reachable caller host authority."
