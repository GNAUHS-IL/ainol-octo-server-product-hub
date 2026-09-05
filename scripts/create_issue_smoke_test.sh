#!/usr/bin/env bash
set -euo pipefail

# Creates a GitHub issue smoke test through REST API, adds labels, comments, and closes it.
# Requires GH_TOKEN or GITHUB_TOKEN with issue write permission. Does not print secrets.

REPO="${1:-GNAUHS-IL/ainol-octo-server-product-hub}"
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
if [ -z "$TOKEN" ]; then
  echo "ERROR: GH_TOKEN/GITHUB_TOKEN is required" >&2
  exit 2
fi
if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required" >&2
  exit 2
fi

TITLE="[Flow Test] bug/feature issue creation smoke test $(date +%Y%m%d-%H%M%S)"
BODY='## 测试目的
验证产品管家链路：用户反馈理解 → 分类 → GitHub issue 创建 → label 写入 → 评论/状态闭环。

## 模拟用户反馈
“希望 Bot/Agent 断联或创建失败时，页面给出明确提示，并指引用户重试或联系管理员。”

## 分类结果
- 类型：Feature
- 领域：Bot 与 Agent
- 优先级：P2
- 状态：inbox → triaged

## 安全说明
本 issue 为流程连通性测试，不包含 token、cookie、secret 或真实用户隐私。'

payload="$(python3 - <<'PY' "$TITLE" "$BODY"
import json, sys
print(json.dumps({
  'title': sys.argv[1],
  'body': sys.argv[2],
  'labels': ['type/feature','priority/P2','status/inbox','area/bot-agent','source/evaluation']
}, ensure_ascii=False))
PY
)"

api="https://api.github.com/repos/$REPO/issues"
resp="$(mktemp)"
code="$(curl -sS -o "$resp" -w '%{http_code}' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  -X POST "$api" \
  -d "$payload")"
number="$(python3 - <<'PY' "$resp" "$code"
import json, sys
j=json.load(open(sys.argv[1])); code=sys.argv[2]
if not code.startswith('2'):
    print('ERROR: create failed http=' + code + ' message=' + str(j.get('message')), file=sys.stderr)
    raise SystemExit(1)
print(j['number'])
PY
)"

curl -fsSL \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  -X PUT "$api/$number/labels" \
  -d '{"labels":["type/feature","priority/P2","status/triaged","area/bot-agent","source/evaluation","pm/needs-prd"]}' >/dev/null

comment_payload="$(python3 - <<'PY'
import json
print(json.dumps({'body':'流程测试完成：已验证“反馈理解 → issue 创建 → label 分诊 → 状态更新/评论”可执行。本 issue 为评测连通性 smoke test，不代表真实用户需求。'}, ensure_ascii=False))
PY
)"
curl -fsSL \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  -X POST "$api/$number/comments" \
  -d "$comment_payload" >/dev/null

closed="$(curl -fsSL \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  -X PATCH "$api/$number" \
  -d '{"state":"closed","state_reason":"completed"}')"
python3 - <<'PY' "$closed"
import json, sys
j=json.loads(sys.argv[1])
print(json.dumps({'ok': True, 'number': j['number'], 'state': j['state'], 'url': j['html_url'], 'labels':[x['name'] for x in j.get('labels',[])]}, ensure_ascii=False, indent=2))
PY
