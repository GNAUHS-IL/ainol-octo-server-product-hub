# 目标仓可用参考材料索引

本页记录 `Mininglamp-OSS/octo-server` 自带的、对产品问答/需求判断有帮助的文档入口。使用原则：产品或实现结论优先回到源码核验；上游文档用于理解背景、契约和运行手册。

## 核心产品与部署入口

| 目标仓文件 | 可用于回答的问题 | 证据 |
|---|---|---|
| `README.md` | 项目定位、依赖的前后端/IM 生态、本地启动入口 | 来源: README.md#L27-L37；来源: README.md#L47-L56 |
| `QUICKSTART.md` | 本地/部署快速开始流程，适合解释启动前置条件 | 需按问题进一步查原文行号 |
| `BUILDING.md` | 构建说明，适合排查 build/环境类问题 | 需按问题进一步查原文行号 |
| `RELEASING.md` | 发布流程说明，适合回答版本发布/制品问题 | 需按问题进一步查原文行号 |
| `SECURITY.md` | 安全报告与安全边界说明 | 需按问题进一步查原文行号 |

## Bot / Agent / 卡片能力文档

| 目标仓文件 | 可用于回答的问题 | 证据 |
|---|---|---|
| `docs/bot-events-longpoll.md` | Bot 事件长轮询、事件游标、等待参数、空结果语义 | 来源: docs/bot-events-longpoll.md#L1-L8；来源: docs/bot-events-longpoll.md#L16-L24 |
| `docs/card-protocol.md` | 交互卡片 ContentType 17、信封字段、plain 兜底、profile | 来源: docs/card-protocol.md#L1-L10；来源: docs/card-protocol.md#L24-L30 |
| `docs/card-action-callback-dispatch.md` | 卡片 action 回调分发、静态路由、签名回调、终态通知 | 来源: docs/card-action-callback-dispatch.md#L1-L9；来源: docs/card-action-callback-dispatch.md#L11-L18；来源: docs/card-action-callback-dispatch.md#L20-L27 |
| `docs/user-secret-alias-api.md` | 用户外部密钥别名、信任边界、禁止明文进入消息/LLM | 来源: docs/user-secret-alias-api.md#L1-L6；来源: docs/user-secret-alias-api.md#L9-L17 |

## 搜索与消息专题

| 目标仓文件 | 可用于回答的问题 | 证据 |
|---|---|---|
| `docs/messages-search/README.md` | 会话内搜索端点、搜索文档索引、OpenSearch mapping 关系 | 来源: docs/messages-search/README.md#L1-L4；来源: docs/messages-search/README.md#L7-L13；来源: docs/messages-search/README.md#L14-L20 |
| `docs/messages-search/api-spec-v2-server-to-frontend.html` | 搜索 API 前后端契约 | 需按问题进一步查原文行号 |
| `docs/messages-search/v1.8-opensearch-mapping.md` | 当前 OpenSearch mapping | 需按问题进一步查原文行号 |

## 运行与迁移 Runbook

| 目标仓文件 | 可用于回答的问题 | 证据 |
|---|---|---|
| `docs/token-session-rollout-runbook.md` | session rollout、MySQL 权威状态、Redis 职责、启动顺序 | 来源: docs/token-session-rollout-runbook.md#L1-L8；来源: docs/token-session-rollout-runbook.md#L15-L23；来源: docs/token-session-rollout-runbook.md#L25-L30 |
| `docs/botevent-cutover-runbook.md` | Bot event cutover 迁移运行手册 | 需按问题进一步查原文行号 |
| `docs/msgextra-cutover-runbook.md` | message extra cutover 迁移运行手册 | 需按问题进一步查原文行号 |
| `docs/cutover-framework.md` | 通用 cutover 框架和守护规则 | 需按问题进一步查原文行号 |

## `.octospec` 规则与历史规格

`.octospec` 是目标仓内的规则/规格知识来源，可用于理解设计约束、历史需求和评审边界，但不能替代源码证据。

| 目标仓文件 | 可用于回答的问题 | 证据 |
|---|---|---|
| `.octospec/index.md` | 规则总览：space 隔离、错误处理、限流、测试、提交规范 | 来源: .octospec/index.md#L1-L8；来源: .octospec/index.md#L9-L17 |
| `.octospec/journal/shared/*.md` | 已沉淀的能力演进记录，如 Bot、卡片、Webhook、OIDC、搜索、token 生命周期 | 需按具体主题查原文行号 |

## 使用优先级

1. **实现结论**：优先引用 Go 源码、配置、migration、workflow。
2. **协议/运行手册**：可引用目标仓 `docs/`，但需确认是否与源码一致。
3. **历史规格**：`.octospec` 可帮助定位需求背景，不能单独作为“已实现”的唯一证据。
4. **不确定场景**：若文档与代码不一致，以当前代码为准，并标记待人工确认。
