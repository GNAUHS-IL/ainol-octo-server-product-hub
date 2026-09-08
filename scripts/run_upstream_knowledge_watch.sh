#!/usr/bin/env bash
set -euo pipefail

# Local/cron-friendly upstream knowledge watch.
# It is read-only against Mininglamp-OSS/octo-server and never sends chat messages.
# On drift, it writes state/exam/upstream-delta-audit.{json,md} and exits 10.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="$(cd "$ROOT/.." && pwd)"
BASELINE_FILE="$ROOT/knowledge/upstream-baseline.json"
TARGET_REPO="${TARGET_REPO:-$WORKSPACE_DIR/octo-server}"
STATE_DIR="$ROOT/state/exam"
mkdir -p "$STATE_DIR"

if [ ! -f "$BASELINE_FILE" ]; then
  echo "ERROR: baseline file missing: $BASELINE_FILE" >&2
  exit 2
fi

read_baseline() {
  python3 - "$BASELINE_FILE" <<'PY'
import json, sys
d=json.load(open(sys.argv[1]))
print(d['target_url'])
print(d.get('branch','main'))
print(d['baseline_commit'])
PY
}
mapfile -t baseline < <(read_baseline)
TARGET_URL="${baseline[0]}"
BRANCH="${baseline[1]}"
BASE="${baseline[2]}"

if [ ! -d "$TARGET_REPO/.git" ]; then
  git clone --depth 300 --branch "$BRANCH" "$TARGET_URL" "$TARGET_REPO"
else
  git -C "$TARGET_REPO" fetch origin "$BRANCH" --tags --prune
  git -C "$TARGET_REPO" checkout "$BRANCH" >/dev/null 2>&1 || true
  git -C "$TARGET_REPO" reset --hard "origin/$BRANCH" >/dev/null
fi

HEAD_COMMIT="$(git -C "$TARGET_REPO" rev-parse HEAD)"
HEAD_SHORT="$(git -C "$TARGET_REPO" rev-parse --short HEAD)"
BASE_SHORT="$(git -C "$TARGET_REPO" rev-parse --short "$BASE" 2>/dev/null || printf '%s' "${BASE:0:7}")"

python3 "$ROOT/scripts/verify_citations.py" \
  --docs-root "$ROOT" \
  --source-root "$TARGET_REPO" \
  --json > "$STATE_DIR/citation-verify.json"

python3 - "$STATE_DIR/citation-verify.json" <<'PY'
import json, sys
d=json.load(open(sys.argv[1]))
print('citation_verify', d['summary'])
if d['summary']['failed']:
    raise SystemExit(1)
PY

if [ "$HEAD_COMMIT" = "$BASE" ]; then
  printf '{"status":"no_change","commit":"%s"}\n' "$HEAD_COMMIT" > "$STATE_DIR/upstream-watch-result.json"
  echo "no upstream change: $HEAD_SHORT"
  exit 0
fi

python3 "$ROOT/scripts/knowledge_delta_audit.py" \
  --source-root "$TARGET_REPO" \
  --docs-root "$ROOT" \
  --base "$BASE" \
  --head "$HEAD_COMMIT" \
  --json-out "$STATE_DIR/upstream-delta-audit.json" \
  --md-out "$STATE_DIR/upstream-delta-audit.md"

python3 - "$STATE_DIR/upstream-delta-audit.json" <<'PY'
import json, sys
d=json.load(open(sys.argv[1]))
print('upstream_changed', {'base': d['base'][:12], 'head': d['head'][:12], 'changed_count': d['changed_count'], 'status': d['status'], 'review_files': d['review_files']})
PY

echo "upstream drift detected: $BASE_SHORT..$HEAD_SHORT"
exit 10
