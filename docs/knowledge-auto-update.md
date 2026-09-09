# 九大知识库定时巡检与更新机制

## 原则

知识库维护采用 OpenClaw / 本地 cron / 外部 scheduler 调用脚本的方式完成定时巡检。

自动化负责：发现目标仓变化、映射九大知识领域、生成差异报告、校验引用、留下可追踪状态。

人工负责：阅读源码证据、补充知识库、裁定产品口径、提交并推送。源码结论不能由脚本无审核自动改写，避免假引用、错行号或错误产品判断。

## 自动闭环

1. 定时任务执行：

```bash
scripts/run_upstream_knowledge_watch.sh
```

2. 脚本读取 `knowledge/upstream-baseline.json`，确认当前知识库已覆盖的目标仓 commit。
3. 脚本只读同步 `Mininglamp-OSS/octo-server` 最新 `main`。
4. 若目标仓 HEAD 未变化：静默退出，不刷消息、不创建无意义记录。
5. 若目标仓 HEAD 有变化：
   - 运行 `scripts/knowledge_delta_audit.py` 生成增量审计；
   - 将变更路径映射到九大知识领域；
   - 跑 `scripts/verify_citations.py` 校验现有引用；
   - 输出 `state/exam/upstream-delta-audit.json`；
   - 输出 `state/exam/upstream-delta-audit.md`；
   - 脚本以非 0 状态退出，方便 scheduler 标记需要人工复核。
6. 产品运营负责人根据审计报告补知识库、重新校验、提交推送，并更新 `knowledge/upstream-baseline.json`。

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



## 本地 cron / 外部 scheduler 巡检（2026-09-09 补充）

为避免目标仓更新后只能靠人工提问才发现，当前落地方案采用本地 cron 或外部 scheduler 调用：

```text
scripts/cron_upstream_knowledge_watch.sh
```

运行边界：

- 只读同步 `Mininglamp-OSS/octo-server`，不写目标仓；
- 对比 `knowledge/upstream-baseline.json` 与目标仓 `main`；
- 无 drift：只写 `state/exam/upstream-watch-result.json`，不提醒、不群发；
- 有 drift：生成 `state/exam/upstream-delta-audit.{json,md}` 和 `state/exam/upstream-drift-current.json`；
- cron 不调用答题流程、不群发、不建 issue、不进 PRD、不自动改写 `knowledge/*`；
- heartbeat 默认保持空文件，不启用定时模型调用；如后续开启，只能读取 drift 状态并做轻量提醒，不能直接启动全量知识库更新。

答题优先级：

- 用户正在问源码 / API / 鉴权 / Bot / IM / 配置等问题时，先快速核对目标仓 HEAD 与 baseline；
- 无 drift：直接基于知识库和源码回答；
- 有 drift 但问题与变更无关：继续回答，并说明依据当前可核验证据；
- 有 drift 且命中新变更：优先查目标仓最新源码回答，再安排知识库补充；
- 全量知识库更新只在空闲时执行，或在用户明确要求“抓紧更新”时执行。

人工闭环仍按完成标准执行：审核源码 / `.octospec` → 更新知识库 → `verify_citations.py` → 更新 baseline → commit → push_verify。

## 本地手工复跑

```bash
cd ainol-octo-server-product-hub

scripts/run_upstream_knowledge_watch.sh
```

如果要指定目标仓路径：

```bash
TARGET_REPO=/path/to/octo-server scripts/run_upstream_knowledge_watch.sh
```

如果只想生成某两个 commit 之间的增量审计：

```bash
python3 scripts/knowledge_delta_audit.py \
  --source-root ../octo-server \
  --docs-root . \
  --base <old-commit> \
  --head <new-commit> \
  --json-out state/exam/upstream-delta-audit.json \
  --md-out state/exam/upstream-delta-audit.md
```

引用校验：

```bash
python3 scripts/verify_citations.py \
  --docs-root . \
  --source-root ../octo-server \
  --json > state/exam/citation-verify.json
```

## 完成标准

- 目标仓最新 commit 已记录到 `knowledge/upstream-baseline.json`。
- 九大知识库对应领域已补齐，不把 README 当唯一实现证据。
- 引用校验通过，引用跨度不超过 15 行。
- 远端已推送，local 与 origin/main 同步。
- 无目标仓变化时保持静默，不发送“无更新”类消息。
