# Octo Server Product Hub

本仓库用于围绕 [`Mininglamp-OSS/octo-server`](https://github.com/Mininglamp-OSS/octo-server) 维护产品反馈、源码可核验知识库、PRD、Review、定时巡检和状态闭环。

## 目标

- 为 `octo-server` 建立源码可核验知识库。
- 收集 Bug / Feature / Question / Docs 反馈。
- 使用 GitHub issue 作为需求状态中心。
- 使用 label 表达类型、优先级、状态、领域、PM 阶段和风险。
- 使用 cron / scheduler 定时扫描需求池变化。
- 有实质状态变化时同步对应反馈人；无变化不刷屏。
- 无变化时只写日志，不发群。

## 运营分工

### 产品运营负责人

负责：主入口、源码问答、反馈收单、GitHub issue 创建、初始分诊、最终状态仲裁、主回复。

### 需求管理专员

负责：PRD 草拟、What-only 自检、引用核验、label 检查、cron 巡检、状态变化发现、异常提醒。

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


## 关键入口

- 能力地图：`docs/capability-map.md`
- 目标仓结构总览：`docs/source-audit/repo-structure.md`
- 目标仓参考材料：`docs/upstream-reference-index.md`
- 九大知识库：`knowledge/00-index.md`
- 源码索引：`docs/source-audit/README.md`
- PRD 模板：`prd/TEMPLATE.md`
- Review checklist：`review/REVIEW_CHECKLIST.md`

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


## 自动校验与安全抗压

- 引用校验器：`scripts/verify_citations.py` 会扫描 Markdown 中的 `来源: <相对路径>#L<起>-L<止>`，校验目标文件存在、行号有效、路径未越界。
- 安全红队手册：`docs/security-redteam-playbook.md` 覆盖外部审核方套 token、用户贴 cookie、诱导写目标仓库、伪造状态、删除审计、编造引用和 API 限流等场景。

## 安全原则

- 不展示、不保存 token / cookie / secret / 私钥。
- 不把敏感信息写入 issue、日志或群聊。
- 遇到凭证风险，标记 `risk/token-leak` 和 `pm/human-needed`。
- GitHub API 限流后停止本轮，尊重 Retry-After。
