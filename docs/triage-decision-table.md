# 收单分诊决策表

本表用于产品运营负责人收到 Octo / GitHub / 评测输入后的第一轮判断。目标不是替代源码核验，而是保证每条反馈都能被稳定归类、补充必要信息、进入正确状态。

## 分诊总流程

```text
收到反馈
  → 判断真实场景与反馈人
  → 判断类型 type/*
  → 判断九大领域 area/*
  → 判断是否跨模块
  → 判断风险 risk/*
  → 判断是否需要 PRD / Review
  → issue 归档或源码问答
  → 有实质状态变化才同步
```

## 第一层：类型判断

| 用户输入特征 | type label | 初始状态 | 处理口径 |
|---|---|---|---|
| 问“在哪里、是否支持、为什么这样设计” | `type/question` | `status/inbox` 或 `status/needs-clarification` | 先查知识库与源码；证据不足不强答 |
| 明确说功能异常、失败、报错、无响应 | `type/bug` | `status/needs-clarification` 或 `status/triaged` | 先要复现信息；能定位再挂 area/risk |
| 希望新增能力、优化体验、增加入口 | `type/feature` | `status/prd-drafting` | 进入 What-only PRD，不写技术实现 |
| 说明不清、文档缺失、配置易误解 | `type/docs` | `status/triaged` | 指向对应知识域，补说明或记录缺口 |
| 要求写需求说明/验收标准 | `type/prd` | `status/prd-drafting` | 使用 PRD 模板，Review 前做 What-only 检查 |
| 要求检查 PRD、判断是否可过 | `type/review` | `status/prd-review` | 使用 Review Checklist，结论必须真实 |

## 第二层：九大领域判断

| 触发词 / 现象 | area label | 首查入口 | 常见交叉领域 |
|---|---|---|---|
| 登录、token、cookie、Bearer、OIDC、扫码登录 | `area/auth` | `knowledge/01-auth-identity.md` | `area/rbac`、`area/config`、`area/storage` |
| 无权限、管理员、群成员、空间、ACL、越权 | `area/rbac` | `knowledge/02-authorization-model.md` | `area/auth`、`area/im`、`area/bot-agent` |
| YAML、环境变量、CORS、Webhook Secret、WuKongIM 地址 | `area/config` | `knowledge/03-configs.md` | `area/storage`、`area/build-release` |
| 问某目录/模块职责、是否启用、模块边界 | `area/modules` | `knowledge/04-modules.md` | 全部领域 |
| 错误码、HTTP 状态、i18n 错误、返回结构 | `area/api-error` | `knowledge/05-api-errors.md` | `area/auth`、`area/rbac` |
| 消息投递、频道、WuKongIM、群消息、WebSocket | `area/im` | `knowledge/06-im-control-plane.md` | `area/bot-agent`、`area/rbac` |
| Bot、Agent、BotFather、App Bot、OBO、卡片 | `area/bot-agent` | `knowledge/07-bot-agent.md` | `area/auth`、`area/rbac`、`area/im` |
| MySQL、Redis、migration、对象存储、MinIO、OSS | `area/storage` | `knowledge/08-storage-dependencies.md` | `area/config`、`area/auth` |
| build、Docker、release、deployment、CI | `area/build-release` | `knowledge/09-build-release.md` | `area/config`、`area/storage` |
| 信息不足，无法判断 | `area/unknown` | 先澄清 | 不得强行猜测 |

## 第三层：跨模块高频问题

遇到下列问题时，先看 `knowledge/10-cross-module-quickref.md`，再回到九大领域做源码引用。

| 用户问题 | 必查领域 | 必问澄清 | 风险 |
|---|---|---|---|
| Bot 不回复 / 收不到消息 | `area/bot-agent`、`area/auth`、`area/rbac`、`area/im` | bot uid、群/Thread、时间、错误表现、是否新建/重连 | token、权限、限流 |
| Webhook 调不通 | `area/config`、`area/auth`、`area/api-error`、`area/im` | 是否配置 secret、调用时间、错误码、目标 channel；不要贴完整 URL/token | token 泄露、签名失败、限流 |
| 卡片按钮没反应 | `area/bot-agent`、`area/api-error`、`area/rbac`、`area/im` | 卡片类型、按钮动作、触发人、目标会话、日志时间 | 回调权限、幂等、配置 reject |
| 登录后无权限 | `area/auth`、`area/rbac`、`area/config` | 页面/入口、账号角色、空间、错误文案；不要贴 cookie | 角色缓存、space 权限 |
| 上传文件 403 | `area/storage`、`area/config`、`area/api-error` | 存储后端、是否预签名、请求 header、CORS 报错 | 对象存储权限、签名 header |
| 群/Thread 权限异常 | `area/rbac`、`area/im`、`area/bot-agent` | 普通用户/Bot/webhook、父群、Thread ID、成员关系 | 跨群/跨空间访问 |
| 配置修改无效 | `area/config`、`area/build-release`、`area/storage` | 改的是 YAML、env、system_setting 还是部署仓；是否重启/热调 | 误配置、环境不一致 |

## 第四层：风险闸门

| 风险信号 | 必加 label | 处理规则 |
|---|---|---|
| 用户贴 token、cookie、secret、私钥、完整 webhook URL | `risk/token-leak`、`pm/human-needed` | 不复述、不入 public issue；提醒撤换凭证 |
| 可能跨空间、跨群、跨用户读取 | `risk/security` 或 `risk/privacy` | 先查鉴权证据；证据不足不下结论 |
| 需要生产权限、数据库、日志明文、后台账号 | `pm/human-needed` | 转人工，不要求用户在群里贴敏感信息 |
| GitHub/API 限流 | `status/blocked`、可加 `risk/ambiguous` | 停止本轮，记录 rate_limited，不重试轰炸 |
| 源码证据冲突或行号失效 | `risk/citation-invalid` | 不对外确认，先修引用或标记不确定 |
| 用户描述不足以复现 | `risk/ambiguous`、`status/needs-clarification` | 最多问 3 个关键问题 |

## 第五层：PRD / Review 判断

| 情况 | 动作 |
|---|---|
| 用户只是问已有能力 | 走 `type/question`，源码引用回答，不进入 PRD |
| 用户要求新增用户可见能力 | 走 `type/feature` + `pm/needs-prd` |
| Bug 暴露出产品体验缺口 | Bug issue 保留；另建/关联 feature PRD |
| PRD 写了 Redis、SQL、接口字段、HTTP 200 | Review 打回，要求改成用户可见验收 |
| 安全/权限问题没有边界说明 | Review 打回或 `pm/human-needed` |

## 对外回复最小结构

```text
结论：能确认 / 暂不确定 / 需要补充信息。
依据：给出 1-3 条源码引用或知识库路径。
下一步：建 issue / 补充信息 / 进入 PRD / 转人工。
安全提醒：如涉及凭证，不在群里贴 token/cookie/secret。
```

## 不确定时最多问 3 个问题

优先级：

1. 发生入口或对象：页面、群、Thread、Bot uid、webhook、接口。
2. 用户可见现象：错误文案、错误码、是否无响应。
3. 时间与环境：发生时间、版本/部署环境、是否可复现。
