# 九大知识库自动更新机制

## 原则

知识库必须做到“自动发现、自动校验、人工裁定后更新”。目标仓源码结论不能由脚本无审核自动改写，因为这会引入假引用、错行号或错误产品口径；可自动化的是发现变化、定位影响面、生成待办、校验引用和留痕。

## 自动闭环

1. 定时任务建议启用 GitHub Actions 模板 `docs/workflow-templates/upstream-knowledge-watch.yml`，或由本地 cron/外部 scheduler 调用同一套脚本。当前仓库凭证若缺少 GitHub `workflow` scope，则不能直接创建 `.github/workflows/*`，先以模板方式落库。
2. 调度任务读取 `knowledge/upstream-baseline.json` 中已覆盖的目标仓 commit。
3. 只读 clone `Mininglamp-OSS/octo-server` 最新 `main`。
4. 若目标仓 HEAD 未变化：静默结束，不刷 issue、不发通知。
5. 若目标仓 HEAD 有变化：
   - 运行 `scripts/knowledge_delta_audit.py` 生成增量审计；
   - 将变更路径映射到九大知识领域；
   - 跑 `scripts/verify_citations.py` 校验现有引用；
   - 上传 audit artifact；
   - 创建或更新 `[Knowledge Drift]` issue，列出需复核知识库。

> 启用说明：将 `docs/workflow-templates/upstream-knowledge-watch.yml` 复制到 `.github/workflows/upstream-knowledge-watch.yml` 后提交。该操作需要 GitHub token 具备 `workflow` scope；没有该 scope 时，GitHub 会拒绝推送 workflow 文件。
6. 产品运营负责人根据 issue 补知识库、重新校验、提交推送，并更新 `knowledge/upstream-baseline.json`。

## 九大领域映射

| 领域 | 文件 | 自动触发线索 |
|---|---|---|
| 01 认证与身份 | `knowledge/01-auth-identity.md` | `pkg/auth/`、`modules/oidc/`、`modules/user/`、token/session/OIDC |
| 02 鉴权模型 | `knowledge/02-authorization-model.md` | `pkg/authtree/`、Space/Group/Project membership、role/permission |
| 03 配置 | `knowledge/03-configs.md` | `configs/`、`system_setting`、`OCTO_*`、`DM_*` |
| 04 模块清单 | `knowledge/04-modules.md` | `internal/modules.go`、`modules/*/1module.go` |
| 05 API 与错误 | `knowledge/05-api-errors.md` | `pkg/errcode/`、`pkg/httperr/`、i18n、错误响应 |
| 06 IM 控制面 | `knowledge/06-im-control-plane.md` | message/channel/group/thread/webhook/space directory |
| 07 Bot 与 Agent | `knowledge/07-bot-agent.md` | bot_api/app_bot/botfather/bot_task/ai_team/robot |
| 08 存储与依赖 | `knowledge/08-storage-dependencies.md` | SQL migration、MySQL/Redis、projectprovision、octosign |
| 09 构建与发布 | `knowledge/09-build-release.md` | Dockerfile、Makefile、CI、go.mod、release docs |

## 本地手工复跑

```bash
python3 scripts/knowledge_delta_audit.py \
  --source-root ../octo-server \
  --docs-root . \
  --base $(python3 -c 'import json; print(json.load(open("knowledge/upstream-baseline.json"))["baseline_commit"])') \
  --head HEAD \
  --json-out state/exam/upstream-delta-audit.json \
  --md-out state/exam/upstream-delta-audit.md

python3 scripts/verify_citations.py \
  --docs-root . \
  --source-root ../octo-server \
  --json > state/exam/citation-verify.json
```

## 完成标准

- 目标仓最新 commit 已记录到 `knowledge/upstream-baseline.json`。
- 九大知识库对应领域已补齐，不把 README 当唯一实现证据。
- 引用校验通过，引用跨度不超过 15 行。
- GitHub 远端已推送，local 与 origin/main 同步。
