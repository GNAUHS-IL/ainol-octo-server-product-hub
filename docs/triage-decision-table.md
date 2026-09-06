# 分诊决策表

## 入口原则

Label 只用于 GitHub issue。普通问题如果可以直接用源码回答，不创建 issue，也不打 label；信息不足时先澄清，不用 issue 当收集箱。

只有当事项需要追踪、修复、新增、补文档、进入 PRD / Review、风险接管或沉淀为公开需求池工作项时，才创建 issue 并打 label。

## 是否建 issue

| 输入场景 | 处理 |
|---|---|
| 用户问已有能力，能直接源码回答 | 直接回答，不建 issue |
| 问答暴露文档错误且已具备最小证据 | 建 issue：`type/bug + 对应 area/* + status/accepted` |
| 问答暴露文档缺失/需要补说明且已具备最小背景 | 建 issue：`type/feature + 对应 area/* + status/prd-drafting` |
| 现有功能异常且复现/证据达到最小建单标准 | 建 issue：`type/bug + status/accepted + 对应 area/*` |
| 需要新增/增强能力且目标清楚 | 建 issue：`type/feature + status/prd-drafting + 对应 area/*` |
| 涉及 token、cookie、私钥、生产权限 | 拒绝展示敏感信息；如需归档，使用 `priority/P0 + status/blocked + 对应 area/*`，正文只写脱敏说明 |
| 暂不能判断所属领域 | 使用 `area/unknown`，后续分诊后替换或补充具体 `area/*` |

## 建 issue 后的主类型

| 工作项本质 | type |
|---|---|
| 修正错误、异常、不一致、过期说明 | `type/bug` |
| 新增能力、增强体验、补充说明、新增材料 | `type/feature` |

不使用 `type/question`、`type/docs`、`type/prd`、`type/review`。

## 优先级

| 优先级 | 含义 |
|---|---|
| `priority/P0` | 安全、凭证、登录不可用、Bot/Agent 断联、交付核心链路阻塞 |
| `priority/P1` | 核心功能异常或重要需求 |
| `priority/P2` | 常规缺陷或普通增强 |
| `priority/P3` | 低优先级建议、体验优化 |

## 处理状态

| 状态 | 含义 |
|---|---|
| `status/todo` | 已进入需求池，待处理 |
| `status/prd-drafting` | PRD 草拟中 |
| `status/reviewing` | Review 中 |
| `status/rework` | Review 打回或内容需返工 |
| `status/accepted` | 已接受处理，但不能说已完成 |
| `status/blocked` | 权限、安全、证据、限流或人工决策等阻塞 |
| `status/done` | 已完成闭环 |
| `status/wontfix` | 有效但决定不处理 |
| `status/duplicate` | 重复 issue |
| `status/invalid` | 无法成立为有效工作项 |

## 知识库领域

| 领域 | 使用场景 |
|---|---|
| `area/auth` | 认证与身份 |
| `area/rbac` | 鉴权模型 / RBAC / ACL |
| `area/config` | 配置 |
| `area/modules` | 业务模块清单 |
| `area/api-error` | API 与错误约定 |
| `area/im` | IM 控制面 |
| `area/bot-agent` | Bot 与 Agent |
| `area/storage` | 存储与外部依赖 |
| `area/build-release` | 构建与发布 |
| `area/unknown` | 暂不能判断 |

## 证据、来源、风险、PRD / Review 的承载位置

| 信息 | 不再作为 label | 新承载位置 |
|---|---|---|
| 来源 | `source/*` | issue 正文“来源与上下文” |
| 源码证据状态 | `evidence/*` | issue 正文、comment、引用校验记录 |
| 风险类型 | `risk/*` | `priority/P0`、`status/blocked`、正文脱敏风险说明 |
| PRD / Review 辅助状态 | `pm/*` | `status/prd-drafting`、`status/reviewing`、`status/rework`、`status/accepted` |

## PRD / Review 流程

| 阶段 | label 组合 | 责任边界 |
|---|---|---|
| 需要 PRD | `type/feature + status/prd-drafting + 对应 area/*` | 需求管理员草拟 PRD |
| 已请求 Review | `type/feature + status/reviewing + 对应 area/*` | 产品运营负责人 Review |
| Review 通过 | `type/feature + status/accepted + 对应 area/*` | 产品运营负责人仲裁 |
| Review 打回 | `type/feature + status/rework + 对应 area/*` | 需求管理员按意见修改 |


## 需求管理员介入边界

需求管理员只在需要产出或修改 PRD / 需求材料时介入，不常驻处理所有 issue。

| 状态/场景 | 是否介入 | 说明 |
|---|---|---|
| `status/prd-drafting` | 是 | 草拟 What-only PRD，整理用户场景、目标、范围和验收标准 |
| `status/rework` | 是 | 按产品运营负责人 Review 意见修改 PRD / 材料 |
| `status/reviewing` | 否 | 这是产品运营负责人的 Review 状态，不能让需求管理员自己写自己审 |
| `status/blocked` | 否 | blocked 代表权限、安全、证据冲突、限流或人工决策阻塞，通常由产品运营负责人或人工复核确认 |
| `status/accepted` / `status/done` | 通常否 | 由产品运营负责人跟踪和仲裁；需求管理员只在被要求补材料时协助 |
| `status/wontfix` / `status/duplicate` / `status/invalid` | 否 | 关闭原因由产品运营负责人最终仲裁 |

职责边界：需求管理员写 PRD；产品运营负责人 Review PRD 并决定通过、打回、接受或关闭。
