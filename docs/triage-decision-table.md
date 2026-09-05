# 分诊决策表

## 入口原则

Label 只用于 GitHub issue。普通问题如果可以直接用源码回答，不创建 issue，也不打 label；信息不足时先澄清，不用 issue 当收集箱。

只有当事项需要追踪、修复、新增、补文档、进入 PRD / Review、风险接管或沉淀为公开需求池工作项时，才创建 issue 并打 label。

## 是否建 issue

| 输入场景 | 处理 |
|---|---|
| 用户问已有能力，能直接源码回答 | 直接回答，不建 issue |
| 问答暴露文档错误且已具备最小证据 | 建 issue：`type/bug + area/docs + status/accepted` |
| 问答暴露文档缺失/需要补说明且已具备最小背景 | 建 issue：`type/feature + area/docs + status/prd-drafting` |
| 现有功能异常且复现/证据达到最小建单标准 | 建 issue：`type/bug + status/accepted` |
| 需要新增/增强能力且目标清楚 | 建 issue：`type/feature + status/prd-drafting` |
| 涉及 token、cookie、私钥、生产权限 | 建 issue 或转人工：`priority/P0 + risk/token-leak + pm/human-needed`，不公开敏感内容 |

## 建 issue 后的主类型

| 工作项本质 | type |
|---|---|
| 修正错误、异常、不一致、过期说明 | `type/bug` |
| 新增能力、增强体验、补充说明、新增材料 | `type/feature` |

## 常用状态

| 状态 | 含义 |
|---|---|
| `status/prd-drafting` | 正在草拟 PRD |
| `status/prd-review` | PRD 等待 Review |
| `status/rework` | Review 打回，需要修改 |
| `status/accepted` | 已接受处理，但不能说已完成 |
| `status/blocked` | 权限、安全、证据、限流等阻塞 |
| `status/done` | 已完成或已给出可核验证据结论 |
| `status/wontfix` | 决定不做 |
| `status/duplicate` | 重复 issue |
| `status/invalid` | 无效反馈 |

## 证据与风险

| 场景 | label |
|---|---|
| 需要补源码证据 | `evidence/source-needed` |
| 已完成源码核验 | `evidence/source-verified` |
| 引用失效 | `evidence/citation-invalid` |
| 非源码型 issue | `evidence/not-applicable` |
| 描述有歧义 | `risk/ambiguous` |
| 安全/隐私风险 | `risk/security` / `risk/privacy` |
| 凭证泄露风险 | `risk/token-leak` + `priority/P0` + `pm/human-needed` |

## PRD / Review

PRD / Review 不作为 `type/*`。它们用 `status/* + pm/*` 表达：

| 阶段 | label 组合 |
|---|---|
| 需要 PRD | `status/prd-drafting + pm/needs-prd` |
| PRD 已可提交 Review | `pm/prd-ready` |
| 已请求 Review | `status/prd-review + pm/review-requested` |
| Review 通过 | `status/accepted + pm/review-approved` |
| Review 打回 | `status/rework + pm/review-rejected` |
