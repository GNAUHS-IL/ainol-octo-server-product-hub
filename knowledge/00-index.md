# 知识库索引

本知识库围绕 `Mininglamp-OSS/octo-server` 的源码建立，用于 AINOL Agent 实操考核 B 卷中的源码可核验问答、反馈分诊、PRD 与 Review。

## 源码基线

- Target repo: `Mininglamp-OSS/octo-server`
- Branch: `main`
- Commit: `49dc9fd97b49c6c9bad9a0abaefb0b48241e9601`
- Last verified: `2026-09-04T20:10:58+08:00`

## 九大知识领域

| 文件 | area label | 覆盖主题 | 当前状态 |
|---|---|---|---|
| `01-auth-identity.md` | `area/auth` | token / cookie / WebSocket 身份、Bot token、session 生命周期 | V2 已补源码证据 |
| `02-authorization-model.md` | `area/rbac` | org/space RBAC、频道 ACL、bot/agent 身份门禁、管理员角色 | V2 已补源码证据 |
| `03-configs.md` | `area/config` | `configs/tsdd.yaml`、必填/校验、外部 URL、短信、文件、推送 | V2 已补源码证据 |
| `04-modules.md` | `area/modules` | `modules/` 清单、注册启用、未注册目录 | V2 已补源码证据 |
| `05-api-errors.md` | `area/api-error` | 统一错误码、HTTP 状态映射、i18n、安全 detail | V2 已补源码证据 |
| `06-im-control-plane.md` | `area/im` | WuKongIM 分工、server 控制面、消息/频道/群 datasource | V2 已补源码证据 |
| `07-bot-agent.md` | `area/bot-agent` | app_bot / botfather / bot_provision / botidentity / bot_api / bot_mention / agentmailgateway | V2 已补源码证据 |
| `08-storage-dependencies.md` | `area/storage` | MySQL、Redis、SQL migration、对象存储、SMS、Push、OIDC | V2 已补源码证据 |
| `09-build-release.md` | `area/build-release` | go build、Dockerfile、Dockerfile.ghcr、Makefile、octo-deployment | V2 已补源码证据 |

## 引用规则

所有回答必须引用真实源码行号：

```text
来源: <相对路径>#L<起>-L<止>
```

如果某个结论只从 README 或注释推断、或者还没找到实现证据，必须标记“不确定”，不能强答。
