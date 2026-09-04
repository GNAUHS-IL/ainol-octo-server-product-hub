#!/usr/bin/env bash
set -euo pipefail

# Push the product-hub repo with the workspace-local GitHub auth config,
# then verify local HEAD == origin/<branch>.
# This avoids relying on an interactive GitHub credential prompt or ambient shell PATH.

repo_dir="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
branch="${2:-main}"
workspace_dir="$(cd "$repo_dir/.." && pwd)"
export GH_CONFIG_DIR="${GH_CONFIG_DIR:-$workspace_dir/.gh-config}"

if [ ! -d "$repo_dir/.git" ]; then
  echo "ERROR: repo_dir is not a git repo: $repo_dir" >&2
  exit 2
fi
if [ ! -d "$GH_CONFIG_DIR" ]; then
  echo "ERROR: GH_CONFIG_DIR not found: $GH_CONFIG_DIR" >&2
  exit 2
fi

cd "$repo_dir"

if ! command -v gh >/dev/null 2>&1; then
  export PATH="$workspace_dir/tools/bin:$PATH"
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI not found; expected $workspace_dir/tools/bin/gh" >&2
  exit 2
fi

before_remote="$(git rev-parse --short "origin/$branch" 2>/dev/null || true)"
local_head="$(git rev-parse --short HEAD)"

echo "repo: $repo_dir"
echo "branch: $branch"
echo "GH_CONFIG_DIR: configured (path redacted)"
echo "local HEAD before push: $local_head"
echo "remote origin/$branch before push: ${before_remote:-unknown}"

git push origin "$branch"
git fetch origin "$branch" --quiet

after_local="$(git rev-parse --short HEAD)"
after_remote="$(git rev-parse --short "origin/$branch")"
ahead_behind="$(git rev-list --left-right --count "origin/$branch...HEAD")"
status="$(git status --short)"

echo "local HEAD after push: $after_local"
echo "remote origin/$branch after push: $after_remote"
echo "ahead/behind: $ahead_behind"

if [ "$after_local" != "$after_remote" ]; then
  echo "ERROR: remote HEAD does not match local HEAD" >&2
  exit 1
fi
if [ "$ahead_behind" != $'0\t0' ]; then
  echo "ERROR: local/remote are not synchronized" >&2
  exit 1
fi
if [ -n "$status" ]; then
  echo "WARNING: working tree has local changes after push:" >&2
  printf '%s\n' "$status" >&2
fi

echo "push verified: local and origin/$branch are synchronized at $after_local"
