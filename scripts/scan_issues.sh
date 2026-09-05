#!/usr/bin/env bash
set -euo pipefail

# Minimal cron evidence scanner.
# - No-change writes local log only; change output is for Agent A to review before any group notification.
# - Prefers gh CLI when available.
# - Falls back to GitHub REST API via curl when gh is missing, using GH_TOKEN/GITHUB_TOKEN if provided.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_DIR="$(cd "$ROOT/.." && pwd)"
if [ -z "${GH_CONFIG_DIR:-}" ] && [ -d "$WORKSPACE_DIR/.gh-config" ]; then
  export GH_CONFIG_DIR="$WORKSPACE_DIR/.gh-config"
fi
LOCAL_LOG_DIR="$ROOT/logs"
LOCAL_STATE_DIR="$ROOT/state"
mkdir -p "$LOCAL_LOG_DIR" "$LOCAL_STATE_DIR"

REPO="${1:-}"
NOW="$(date -Is)"

log_json() {
  local event="$1" reason="${2:-}"
  if [ -n "$reason" ]; then
    printf '{"time":"%s","source":"cron","event":"%s","reason":"%s","redacted":true}\n' "$NOW" "$event" "$reason" >> "$LOCAL_LOG_DIR/scan-log.jsonl"
  else
    printf '{"time":"%s","source":"cron","event":"%s","repo":"%s","redacted":true}\n' "$NOW" "$event" "$REPO" >> "$LOCAL_LOG_DIR/scan-log.jsonl"
  fi
}

if [ -z "$REPO" ]; then
  log_json "blocked" "missing_repo"
  exit 2
fi

# Prefer workspace-local gh when the ambient PATH does not include gh.
if ! command -v gh >/dev/null 2>&1 && [ -x "$WORKSPACE_DIR/tools/bin/gh" ]; then
  export PATH="$WORKSPACE_DIR/tools/bin:$PATH"
fi

OUT=""
if command -v gh >/dev/null 2>&1; then
  if OUT="$(gh issue list --repo "$REPO" --state all --limit 50 --json number,title,state,updatedAt,labels 2>/dev/null)"; then
    :
  else
    OUT=""
  fi
fi

if [ -z "$OUT" ]; then
  if ! command -v curl >/dev/null 2>&1; then
    log_json "blocked" "curl_not_installed"
    exit 2
  fi
  AUTH_HEADER=()
  TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
  if [ -n "$TOKEN" ]; then
    AUTH_HEADER=(-H "Authorization: Bearer $TOKEN")
  fi
  OUT="$(curl -fsSL \
    -H 'Accept: application/vnd.github+json' \
    -H 'X-GitHub-Api-Version: 2022-11-28' \
    "${AUTH_HEADER[@]}" \
    "https://api.github.com/repos/$REPO/issues?state=all&per_page=50")" || {
      log_json "blocked" "github_api_issue_list_failed"
      exit 1
    }
fi

HASH="$(printf '%s' "$OUT" | sha256sum | awk '{print $1}')"
STATE_FILE="$LOCAL_STATE_DIR/scan-state.json"
OLD=""
[ -f "$STATE_FILE" ] && OLD="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("hash", ""))' "$STATE_FILE" 2>/dev/null || true)"

if [ "$HASH" = "$OLD" ]; then
  log_json "no_change"
else
  printf '{"time":"%s","hash":"%s"}\n' "$NOW" "$HASH" > "$STATE_FILE"
  log_json "change_detected"
  printf '%s\n' "$OUT" > "$LOCAL_STATE_DIR/latest-issues.redacted.json"
fi
