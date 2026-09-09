#!/usr/bin/env bash
set -euo pipefail

# Hourly local upstream knowledge drift watcher.
# - Read-only against Mininglamp-OSS/octo-server.
# - Does not edit knowledge files.
# - Does not create GitHub issues.
# - On new drift, writes state/exam/upstream-drift-current.json only.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="$(cd "$ROOT/.." && pwd)"
TARGET_REPO="${TARGET_REPO:-$WORKSPACE_DIR/octo-server}"
STATE_DIR="$ROOT/state/exam"
DRIFT_FILE="$STATE_DIR/upstream-drift-current.json"
WATCH_RESULT="$STATE_DIR/upstream-watch-result.json"
LOG_FILE="$STATE_DIR/upstream-knowledge-watch.log"
LOCK_NOTE="OCTO_PRODUCT_OPS_UPSTREAM_KNOWLEDGE_WATCH"
mkdir -p "$STATE_DIR"

now() { date -Is; }
log() { printf '[%s] %s\n' "$(now)" "$*" >> "$LOG_FILE"; }

read_json_field() {
  local file="$1" field="$2"
  [ -f "$file" ] || return 0
  python3 - "$file" "$field" <<'PY' 2>/dev/null || true
import json, sys
try:
    data=json.load(open(sys.argv[1]))
    val=data.get(sys.argv[2], "")
    print(val if val is not None else "")
except Exception:
    pass
PY
}

write_clean() {
  local head="$1"
  python3 - "$WATCH_RESULT" "$head" <<'PY'
import json, sys, datetime
path, head = sys.argv[1:3]
json.dump({
  "status": "clean",
  "head": head,
  "checked_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
}, open(path, "w"), ensure_ascii=False, indent=2)
print()
PY
  rm -f "$DRIFT_FILE"
}

write_drift() {
  local audit_json="$STATE_DIR/upstream-delta-audit.json"
  python3 - "$audit_json" "$DRIFT_FILE" <<'PY'
import json, sys, datetime
src, dst = sys.argv[1:3]
a=json.load(open(src))
out={
  "status": "drift_detected",
  "base": a.get("base"),
  "head": a.get("head"),
  "changed_count": a.get("changed_count"),
  "impacted_areas": a.get("impacted_areas", []),
  "review_files": a.get("review_files", []),
  "audit_json": "state/exam/upstream-delta-audit.json",
  "audit_md": "state/exam/upstream-delta-audit.md",
  "detected_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
  "notified_head": None,
  "notification_status": "pending"
}
# Preserve notification if this exact head was already notified.
try:
    old=json.load(open(dst))
    if old.get("head") == out["head"] and old.get("notified_head") == out["head"]:
        out["notified_head"] = old.get("notified_head")
        out["notification_status"] = old.get("notification_status", "sent")
        out["notified_at"] = old.get("notified_at")
except Exception:
    pass
json.dump(out, open(dst, "w"), ensure_ascii=False, indent=2)
print()
PY
}

main() {
  log "watch start $LOCK_NOTE target=$TARGET_REPO"
  set +e
  TARGET_REPO="$TARGET_REPO" "$ROOT/scripts/run_upstream_knowledge_watch.sh" >> "$LOG_FILE" 2>&1
  code=$?
  set -e
  case "$code" in
    0)
      head="$(git -C "$TARGET_REPO" rev-parse HEAD 2>/dev/null || true)"
      write_clean "$head"
      log "watch clean head=${head:0:12}"
      ;;
    10)
      write_drift
      log "watch drift detected head=$(read_json_field "$DRIFT_FILE" head | cut -c1-12)"
      ;;
    *)
      python3 - "$WATCH_RESULT" "$code" <<'PY'
import json, sys, datetime
path, code = sys.argv[1:3]
json.dump({
  "status": "error",
  "exit_code": int(code),
  "checked_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
}, open(path, "w"), ensure_ascii=False, indent=2)
print()
PY
      log "watch error exit_code=$code"
      exit "$code"
      ;;
  esac
}

main "$@"
