# 上游变更影响扫描

本流程用于只读监控目标仓 `Mininglamp-OSS/octo-server` 的变化，判断是否需要更新九大知识库、跨模块速查表或需求池状态。它不写目标仓、不自动群发、无变化只写本地日志。

## 目标

- 发现目标仓 commit 变化。
- 将变更文件映射到九大知识领域。
- 标记需要复核的知识库文件。
- 为“知识库不是一次性产物”提供长周期证据。

## 脚本

```bash
scripts/scan_upstream_changes.sh ../octo-server
```

默认输出：

- 本地日志：`logs/upstream-change-log.jsonl`
- 本地状态：`state/upstream-scan-state.json`
- 最近一次变更摘要：`state/latest-upstream-impact.json`

这些文件默认不提交 public repo；公开仓只保留流程和脱敏字段说明。

## 影响领域映射

| 目标仓路径 | 影响领域 |
|---|---|
| `pkg/auth/`、`modules/oidc/`、`modules/user/` | `area/auth`、`area/rbac` |
| `modules/group/`、`modules/thread/`、`modules/space/` | `area/rbac`、`area/im` |
| `configs/`、`main.go` | `area/config`、`area/build-release` |
| `modules/bot_api/`、`modules/app_bot/`、`modules/botfather/`、`modules/bot_provision/`、`modules/bot_mention/` | `area/bot-agent`、`area/auth`、`area/rbac` |
| `modules/message/`、`modules/channel/`、`modules/incomingwebhook/`、`modules/webhook/` | `area/im`、`area/api-error`、`area/config` |
| `modules/file/`、`pkg/redis/`、`pkg/db/`、SQL migration | `area/storage`、`area/config` |
| `Dockerfile`、`Dockerfile.ghcr`、`Makefile`、`.github/workflows/` | `area/build-release` |
| `pkg/errcode/`、`pkg/httperr/`、`api_i18n` | `area/api-error` |

## 通知规则

- 无变化：只写日志，不发群。
- 有变化但不影响九大知识库：只写日志。
- 有变化且命中高风险领域：生成摘要，由产品运营负责人判断是否更新知识库或 issue。
- 涉及安全、凭证、权限、限流：优先人工复核，不自动发布结论。
