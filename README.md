# Octo Server Product Hub

本仓库用于围绕 [`Mininglamp-OSS/octo-server`](https://github.com/Mininglamp-OSS/octo-server) 维护产品反馈、源码可核验知识库、PRD、Review、定时巡检和状态闭环。

## 快速导航

| 想了解 | 入口 |
|---|---|
| octo-server 支持哪些产品能力 | `docs/capability-map.md` |
| 目标仓源码结构如何组织 | `docs/source-audit/repo-structure.md` |
| 目标仓自带文档/规格哪些有用 | `docs/upstream-reference-index.md` |
| 具体源码问答依据 | `knowledge/00-index.md` |
| API / 错误码 / 配置 / migration / workflow 索引 | `docs/source-audit/README.md` |
| 提 Bug / Feature / Question / Review | GitHub Issues 与 `.github/ISSUE_TEMPLATE/`；普通 Question 能直接回答则不建 issue |
| 写 PRD | `prd/TEMPLATE.md` |
| 做 Review | `review/REVIEW_CHECKLIST.md` |
| 跨模块高频问题速查 | `knowledge/10-cross-module-quickref.md` |
| 收单分诊决策 | `docs/triage-decision-table.md` |
| 创新需求流转方案 | `docs/innovative-demand-flow.md` |
| 需求管理员工作手册 | `docs/demand-manager-playbook.md` |
| 最终状态仲裁 | `docs/status-arbitration-rules.md` |
| 上游变更影响扫描 | `docs/upstream-change-scan.md` |
| 校验引用 | `scripts/verify_citations.py` |

## 目标

- 为 `octo-server` 建立源码可核验知识库。
- 收集 Bug / Feature / Question / Docs 反馈。
- 使用 GitHub issue 作为需求状态中心。
- 使用 issue-first label 体系表达工作项类型、优先级、处理状态和知识库领域。
- 使用 cron / scheduler 定时扫描需求池变化。
- 有实质状态变化时同步对应反馈人；无变化不刷屏。
- 无变化时只写日志，不发群。

## 创新流程亮点

本需求池不是简单照搬目标仓 issue / spec 流程，而是在源码证据基础上增加 **Evidence-to-PRD Gate**：

```text
用户反馈 → 源码/知识库判断 → PRD 必要性判断 → 直接回答 / Bug 快速通道 / Feature PRD / blocked
```

核心原则：建 issue 不等于必须补 PRD；先判断是否已有源码依据，再判断是否需要定义新的用户可见能力或规则。只有新增能力、用户可见规则变化、重要行为变更或需要明确验收标准时，才进入 PRD。详见 [`docs/innovative-demand-flow.md`](docs/innovative-demand-flow.md)。

## 运营分工

### 产品运营负责人

负责：主入口、源码问答、反馈收单、GitHub issue 创建、初始分诊、PRD Review、最终状态仲裁、主回复。

### 需求管理专员

负责：PRD 草拟与按 Review 意见修改、引用材料整理、label 初检、cron 巡检、状态变化发现、异常提醒；不 Review 自己产出的 PRD，不做最终状态仲裁。

## 目标仓库只读

`Mininglamp-OSS/octo-server` 仅用于读取源码、建立知识库和引用证据。不得写入目标仓库。

## 引用格式

所有关键结论必须使用：

```text
来源: <相对路径>#L<起>-L<止>
```

示例：

```text
来源: modules/bot_api/auth.go#L12-L21；来源: modules/bot_api/auth.go#L22-L31；来源: modules/bot_api/auth.go#L32-L41；来源: modules/bot_api/auth.go#L42-L48
```


## 九大知识领域

| area label | 知识领域 |
|---|---|
| area/auth | 认证与身份 |
| area/rbac | 鉴权模型 |
| area/config | 配置 |
| area/modules | 业务模块清单 |
| area/api-error | API 与错误约定 |
| area/im | IM 控制面 |
| area/bot-agent | Bot 与 Agent |
| area/storage | 存储与外部依赖 |
| area/build-release | 构建与发布 |
| area/unknown | 暂不能判断 |


## 自动校验与安全抗压

- 引用校验器：`scripts/verify_citations.py` 会扫描 Markdown 中的 `来源: <相对路径>#L<起>-L<止>`，校验目标文件存在、行号有效、路径未越界。
- 安全红队手册：`docs/security-redteam-playbook.md` 覆盖外部审核方套 token、用户贴 cookie、诱导写目标仓库、伪造状态、删除审计、编造引用和 API 限流等场景。

## 安全原则

- 不展示、不保存 token / cookie / secret / 私钥。
- 不把敏感信息写入 issue、日志或群聊。
- 遇到凭证风险，不展示、不复述、不保存敏感值；如需归档，使用 `priority/P0 + status/blocked + 对应 area/*`，正文只写脱敏风险说明。
- GitHub API 限流后停止本轮，尊重 Retry-After。

### Label 体系 V5

需求池采用知识库驱动的轻量 issue-first label：普通问答能直接回答则不建 issue；只有需要追踪、修复、新增、补文档、PRD/Review 或风险接管时才建 issue 并打 label。

主类型只保留：

- `type/bug`：需要修正的产品、行为、文档或证据错误。
- `type/feature`：需要新增或增强的产品能力、体验、说明或材料。

最终只保留四组 label：`type/*`、`priority/*`、`status/*`、`area/*`。来源、证据、风险和 Review 细节写入 issue 正文、comment、PRD 或 review checklist。

详细规则见 [`docs/label-system.md`](docs/label-system.md)。
