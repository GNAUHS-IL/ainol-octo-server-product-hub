#!/usr/bin/env bash
set -euo pipefail
# Minimal cron evidence scanner. No-change writes local log only; change output is for Agent A to review before any group notification.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCAL_LOG_DIR="$ROOT/logs"
LOCAL_STATE_DIR="$ROOT/state"
mkdir -p "$LOCAL_LOG_DIR" "$LOCAL_STATE_DIR"
REPO="${1:-}"
NOW="$(date -Is)"
if [ -z "$REPO" ]; then
  echo "{\"time\":\"$NOW\",\"event\":\"blocked\",\"reason\":\"missing_repo\",\"redacted\":true}" >> "$LOCAL_LOG_DIR/scan-log.jsonl"
  exit 2
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "{\"time\":\"$NOW\",\"event\":\"blocked\",\"reason\":\"gh_not_installed\",\"redacted\":true}" >> "$LOCAL_LOG_DIR/scan-log.jsonl"
  exit 2
fi
OUT="$(gh issue list --repo "$REPO" --state all --limit 50 --json number,title,state,updatedAt,labels 2>&1)" || {
  echo "{\"time\":\"$NOW\",\"event\":\"blocked\",\"reason\":\"gh_issue_list_failed\",\"detail\":\"redacted\",\"redacted\":true}" >> "$LOCAL_LOG_DIR/scan-log.jsonl"
  exit 1
}
HASH="$(printf '%s' "$OUT" | sha256sum | awk '{print $1}')"
STATE_FILE="$LOCAL_STATE_DIR/scan-state.json"
OLD=""
[ -f "$STATE_FILE" ] && OLD="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("hash", ""))' "$STATE_FILE" 2>/dev/null || true)"
if [ "$HASH" = "$OLD" ]; then
  echo "{\"time\":\"$NOW\",\"source\":\"cron\",\"event\":\"no_change\",\"repo\":\"$REPO\",\"redacted\":true}" >> "$LOCAL_LOG_DIR/scan-log.jsonl"
else
  printf '{"time":"%s","hash":"%s"}\n' "$NOW" "$HASH" > "$STATE_FILE"
  echo "{\"time\":\"$NOW\",\"source\":\"cron\",\"event\":\"change_detected\",\"repo\":\"$REPO\",\"redacted\":true}" >> "$LOCAL_LOG_DIR/scan-log.jsonl"
  printf '%s\n' "$OUT" > "$LOCAL_STATE_DIR/latest-issues.redacted.json"
fi
