#!/usr/bin/env bash
set -euo pipefail

# Read-only upstream impact scanner for Mininglamp-OSS/octo-server.
# It records commit changes and maps changed paths to the product-hub knowledge areas.
# No-change writes local log only. It never writes to the target repo and never sends messages.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_REPO="${1:-$ROOT/../octo-server}"
LOG_DIR="$ROOT/logs"
STATE_DIR="$ROOT/state"
STATE_FILE="$STATE_DIR/upstream-scan-state.json"
LATEST_FILE="$STATE_DIR/latest-upstream-impact.json"
NOW="$(date -Is)"
mkdir -p "$LOG_DIR" "$STATE_DIR"

log_json() {
  printf '%s\n' "$1" >> "$LOG_DIR/upstream-change-log.jsonl"
}

write_state() {
  local initialized="$1"
  local reason="${2:-}"
  python3 - "$STATE_FILE" "$NOW" "$CURRENT" "$initialized" "$reason" <<'PY'
import json, sys
state_file, now, current, initialized, reason = sys.argv[1:6]
data = {"last_scan_at": now, "commit": current, "initialized": initialized == "true"}
if reason:
    data["reason"] = reason
json.dump(data, open(state_file, "w"), ensure_ascii=False, indent=2)
print()
PY
}

if [ ! -d "$TARGET_REPO/.git" ]; then
  log_json "{\"time\":\"$NOW\",\"source\":\"upstream-scan\",\"event\":\"blocked\",\"reason\":\"target_repo_missing\",\"redacted\":true}"
  exit 2
fi

CURRENT="$(git -C "$TARGET_REPO" rev-parse HEAD)"
PREVIOUS=""
if [ -f "$STATE_FILE" ]; then
  PREVIOUS="$(python3 - "$STATE_FILE" <<'PY' || true
import json, sys
try:
    print(json.load(open(sys.argv[1])).get("commit", ""))
except Exception:
    print("")
PY
)"
fi

if [ -z "$PREVIOUS" ]; then
  write_state true
  log_json "{\"time\":\"$NOW\",\"source\":\"upstream-scan\",\"event\":\"initialized\",\"commit\":\"${CURRENT:0:12}\",\"redacted\":true}"
  exit 0
fi

if ! git -C "$TARGET_REPO" cat-file -e "$PREVIOUS^{commit}" 2>/dev/null; then
  write_state true "previous_commit_unavailable"
  log_json "{\"time\":\"$NOW\",\"source\":\"upstream-scan\",\"event\":\"reinitialized\",\"reason\":\"previous_commit_unavailable\",\"commit\":\"${CURRENT:0:12}\",\"redacted\":true}"
  exit 0
fi

if [ "$CURRENT" = "$PREVIOUS" ]; then
  write_state false
  log_json "{\"time\":\"$NOW\",\"source\":\"upstream-scan\",\"event\":\"no_change\",\"commit\":\"${CURRENT:0:12}\",\"redacted\":true}"
  exit 0
fi

CHANGED_FILE="$STATE_DIR/upstream-changed-paths.tmp"
git -C "$TARGET_REPO" diff --name-only "$PREVIOUS" "$CURRENT" > "$CHANGED_FILE" || true
IMPACT_JSON="$(python3 - "$PREVIOUS" "$CURRENT" "$CHANGED_FILE" <<'PY'
import json, sys
previous, current, changed_file = sys.argv[1:4]
with open(changed_file, encoding="utf-8", errors="replace") as f:
    paths = [line.strip() for line in f if line.strip()]
area_rules = [
    ("area/auth", ["pkg/auth/", "modules/oidc/", "modules/user/"]),
    ("area/rbac", ["pkg/auth/", "modules/group/", "modules/thread/", "modules/space/", "modules/oidc/", "modules/bot_api/"]),
    ("area/config", ["configs/", "main.go", "modules/incomingwebhook/", "modules/file/", "pkg/redis/"]),
    ("area/modules", ["internal/modules.go", "modules/"]),
    ("area/api-error", ["pkg/errcode/", "pkg/httperr/", "api_i18n", "modules/message/", "modules/incomingwebhook/"]),
    ("area/im", ["modules/message/", "modules/channel/", "modules/group/", "modules/thread/", "modules/incomingwebhook/", "modules/webhook/"]),
    ("area/bot-agent", ["modules/bot_api/", "modules/app_bot/", "modules/botfather/", "modules/bot_provision/", "modules/bot_mention/", "modules/agentmailgateway/"]),
    ("area/storage", ["pkg/db/", "pkg/redis/", "modules/file/", "sql", "migrations", "migration"]),
    ("area/build-release", ["Dockerfile", "Dockerfile.ghcr", "Makefile", ".github/workflows/", "BUILDING.md", "RELEASING.md"]),
]
areas=[]
for area, needles in area_rules:
    if any(any(n in path or path.startswith(n) for n in needles) for path in paths):
        areas.append(area)
knowledge = {
    "area/auth": "knowledge/01-auth-identity.md",
    "area/rbac": "knowledge/02-authorization-model.md",
    "area/config": "knowledge/03-configs.md",
    "area/modules": "knowledge/04-modules.md",
    "area/api-error": "knowledge/05-api-errors.md",
    "area/im": "knowledge/06-im-control-plane.md",
    "area/bot-agent": "knowledge/07-bot-agent.md",
    "area/storage": "knowledge/08-storage-dependencies.md",
    "area/build-release": "knowledge/09-build-release.md",
}
high_risk = sorted(set(areas) & {"area/auth", "area/rbac", "area/bot-agent", "area/config", "area/storage"})
review_files = [knowledge[a] for a in areas if a in knowledge]
if len(areas) >= 2:
    review_files.append("knowledge/10-cross-module-quickref.md")
print(json.dumps({
    "previous": previous,
    "current": current,
    "changed_count": len(paths),
    "changed_paths": paths[:200],
    "areas": areas,
    "review_files": review_files,
    "high_risk_areas": high_risk,
    "requires_human_review": bool(high_risk),
}, ensure_ascii=False))
PY
)"
rm -f "$CHANGED_FILE"

printf '%s\n' "$IMPACT_JSON" > "$LATEST_FILE"
write_state false
AREAS="$(python3 -c 'import json,sys; print(",".join(json.load(sys.stdin).get("areas", [])))' <<< "$IMPACT_JSON")"
log_json "{\"time\":\"$NOW\",\"source\":\"upstream-scan\",\"event\":\"change_detected\",\"previous\":\"${PREVIOUS:0:12}\",\"current\":\"${CURRENT:0:12}\",\"areas\":\"$AREAS\",\"redacted\":true}"
printf '%s\n' "$IMPACT_JSON"
