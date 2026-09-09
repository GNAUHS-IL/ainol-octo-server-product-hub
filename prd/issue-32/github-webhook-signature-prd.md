# PRD 草稿：GitHub incoming webhook 强制校验 X-Hub-Signature-256

## 1. 背景与问题

Issue #32 反馈：安全审计要求 octo-server 在接收 GitHub webhook 时校验 GitHub `X-Hub-Signature-256`，避免只依赖 URL 中的 webhook token。当前 GitHub incoming webhook 文档明确说明接入 URL 包含 webhook_id 和 token，鉴权靠 URL 内 128-bit token，不强制 HMAC，`X-Hub-Signature-256` 校验留作后续可选项。来源: modules/incomingwebhook/README.md#L196-L202

现有 GitHub 适配器代码注释同样说明当前路径为 `/v1/incoming-webhooks/:webhook_id/:token/github`，鉴权沿用 URL token，未强制 HMAC。来源: modules/incomingwebhook/adapter_github.go#L5-L10

当前平台适配器共用一条鉴权、限流、群校验、投递和审计流水线，GitHub 适配器只负责把 GitHub 请求翻译成 native 推送请求。来源: modules/incomingwebhook/adapter.go#L3-L19

当前 GitHub adapter 注册项只包含 parse 与 bodyLimit，未体现 GitHub 签名校验能力。来源: modules/incomingwebhook/adapter.go#L63-L66

当前 push handler 先读取 URL 中的 webhook_id 与 token，并按 URL token 做常量时间比对；这说明现有可核验证据只覆盖 URL token 鉴权，不覆盖 GitHub HMAC 签名校验。来源: modules/incomingwebhook/api.go#L1312-L1349

## 2. 目标与非目标

### 目标

- GitHub incoming webhook 支持并在安全策略要求下强制校验 `X-Hub-Signature-256`。
- 为 GitHub webhook 提供独立的 GitHub webhook secret 配置口径，不复用 URL token 作为审计要求下的签名 secret。
- 对新建、编辑和存量 GitHub webhook 给出清晰迁移策略，避免上线后存量集成静默失效。
- 对缺失签名、签名不匹配、secret 未配置、迁移期豁免、签名校验通过等状态提供调用方和运营可理解的提示与排障口径。
- 在 deliveries / audit 中保留脱敏、安全、可追溯的签名校验结果，帮助管理员定位配置错误和安全风险。
- 更新 GitHub webhook 接入文档，让配置步骤覆盖 Payload URL、Content type、Secret、签名校验开关和迁移提示。
- 明确多租户、权限、外部输入、限流、防滥用、审计和凭证脱敏边界。

### 非目标

- 不改变 GitHub webhook 的事件渲染范围、消息样式、mention 规则或 GitHub 事件支持列表。
- 不要求本单覆盖 GitLab、企业微信、飞书、Multica、Octo 或 native webhook 的签名机制。
- 不在 PRD 中定义签名算法实现、内部字段、数据库表、缓存、队列、SQL、代码路径或部署方案。
- 不要求在群聊、issue、deliveries、日志或审计中展示明文 URL token、GitHub webhook secret、签名原文或完整敏感 payload。
- 不把迁移期内的兼容豁免解释为长期安全通过；迁移窗口结束后的产品口径应以强制校验为准。

## 3. 用户故事

### US-01：Space 管理员配置 GitHub webhook 签名校验
- 角色：作为 Space 管理员或有权管理 incoming webhook 的群管理员
- 场景：当我为 GitHub 仓库配置 Octo incoming webhook
- 诉求：希望在 Octo 侧获得独立 GitHub webhook secret，并在 GitHub Webhooks 配置中填入同一 secret
- 价值：以便 GitHub 推送进入 Octo 前能满足安全审计要求，不只依赖 URL token
- 来源: modules/incomingwebhook/README.md#L196-L202；来源: modules/incomingwebhook/adapter_github.go#L5-L10

### US-02：安全审计人员确认 GitHub webhook 不再只靠 URL token
- 角色：作为安全审计人员或产品运营负责人
- 场景：当审计 GitHub webhook 接入安全性
- 诉求：希望产品口径明确 GitHub webhook 必须具备签名校验能力，并能区分已启用、迁移期豁免和未启用状态
- 价值：以便判断当前集成是否满足组织安全基线
- 来源: modules/incomingwebhook/adapter.go#L3-L19；来源: modules/incomingwebhook/api.go#L1312-L1349

### US-03：GitHub webhook 调用方收到可理解的失败结果
- 角色：作为 GitHub webhook 配置者或仓库管理员
- 场景：当 GitHub delivery 缺少签名、签名不匹配或 Octo 侧 secret 未配置
- 诉求：希望 GitHub delivery 和 Octo 管理端都能看到可理解、可修复、但不泄露 secret 的失败原因
- 价值：以便我能快速修正 GitHub Secret 或 Octo 配置，而不是误判为普通网络失败
- 来源: modules/incomingwebhook/adapter.go#L29-L53；来源: modules/incomingwebhook/api.go#L1416-L1425；来源: modules/incomingwebhook/api.go#L1444-L1457

### US-04：存量 GitHub webhook 平滑迁移到强制签名
- 角色：作为存量 GitHub webhook 的创建者、群管理员或产品运营负责人
- 场景：当系统从“不强制 HMAC”升级到“要求签名校验”
- 诉求：希望已有 webhook 有明确迁移窗口、风险提示和到期后的行为说明
- 价值：以便业务不中断，同时安全审计可以看到落地计划和最终强制口径
- 来源: modules/incomingwebhook/README.md#L200-L202；来源: modules/incomingwebhook/adapter_github.go#L9-L10

### US-05：运营人员通过 deliveries / audit 排查签名问题
- 角色：作为产品运营负责人、Space 管理员或授权排障人员
- 场景：当 GitHub webhook delivery 未投递到群内
- 诉求：希望在授权范围内看到脱敏的签名校验状态、失败分类和下一步建议
- 价值：以便区分 URL token 错误、签名缺失、签名不匹配、迁移期豁免、事件不支持和内容解析失败
- 来源: modules/incomingwebhook/model.go#L88-L96；来源: modules/incomingwebhook/model.go#L215-L220；来源: modules/incomingwebhook/README.md#L395-L428

## 4. 功能需求

### F-01-1 GitHub 签名校验策略
- 所属故事：US-01、US-02、US-04
- 需求描述：GitHub incoming webhook 应支持 `X-Hub-Signature-256` 校验，并在安全策略要求下对 GitHub 适配器强制启用。
- 业务规则：推荐产品口径为“GitHub 适配器默认强制签名校验；存量 webhook 可在迁移窗口内临时保留豁免；迁移窗口结束后，GitHub webhook 不应继续只靠 URL token 接收事件”。
- 边界场景：当某个存量 webhook 处于迁移窗口内，管理端应明确显示其风险状态和截止时间；当迁移窗口结束或管理员新建 GitHub webhook 时，应按强制校验口径处理。
- 来源: modules/incomingwebhook/README.md#L200-L202；来源: modules/incomingwebhook/adapter_github.go#L9-L10

### F-01-2 Secret 配置口径
- 所属故事：US-01、US-02
- 需求描述：GitHub webhook 应提供独立 GitHub webhook secret 的配置口径，用于在 GitHub Webhooks 设置中填写，不应要求用户把 URL token 当作签名 secret 复用。
- 业务规则：URL token 继续作为 webhook URL 的访问凭证；GitHub webhook secret 用于 GitHub 签名校验。产品文案需明确两者用途不同，二者都不得明文展示、复制到群聊或写入 issue。
- 边界场景：secret 未配置、被重置、被清空、疑似泄露或与 GitHub 侧不一致时，系统应给出安全提示和重新配置路径；不回显旧 secret 明文。
- 来源: modules/incomingwebhook/README.md#L196-L202；来源: modules/incomingwebhook/api.go#L1312-L1349

### F-01-3 新建与编辑 GitHub webhook 的用户可见流程
- 所属故事：US-01、US-02
- 需求描述：当管理员新建或编辑 GitHub webhook 时，界面和文档应展示签名校验要求、secret 配置提示、迁移状态和测试建议。
- 业务规则：新建 GitHub webhook 应默认提示配置 Secret；编辑已有 GitHub webhook 时，应能看到当前签名校验状态、是否处于迁移豁免、以及下一步修复建议。
- 边界场景：管理员权限不足、webhook 被禁用、群已不可用、创建者已退群、secret 待配置或 GitHub ping 测试失败时，应提示用户可理解原因，不暴露无权对象详情。
- 来源: modules/incomingwebhook/README.md#L188-L202；来源: modules/incomingwebhook/api.go#L1336-L1341；来源: modules/incomingwebhook/api.go#L1383-L1414

### F-01-4 签名缺失或错误的失败口径
- 所属故事：US-03、US-05
- 需求描述：当 GitHub webhook 要求签名校验但请求缺少 `X-Hub-Signature-256`、签名格式不符合要求、签名不匹配或 secret 未配置时，系统应拒绝投递并给出可理解、可修复的失败口径。
- 业务规则：失败提示应面向 GitHub 配置者和 Octo 管理员说明“签名缺失/签名不匹配/secret 未配置/迁移期未完成”等原因类别；不得回显 secret、签名原文、URL token 或完整 payload。
- 边界场景：请求已通过 URL token 但签名失败时，应避免让调用方误以为事件已投递；请求没有有效 URL token 时，仍应维持反枚举口径，不向未知调用方暴露 webhook 是否存在。
- 来源: modules/incomingwebhook/api.go#L1312-L1349；来源: modules/incomingwebhook/api.go#L1416-L1425；来源: modules/incomingwebhook/README.md#L428-L428

### F-01-5 deliveries / audit 可观测性
- 所属故事：US-03、US-05
- 需求描述：对已能关联到合法 webhook 的签名校验失败、迁移期豁免、校验通过和后续解析/跳过/投递结果，管理端 deliveries / audit 应提供脱敏记录和排障建议。
- 业务规则：deliveries / audit 应能让授权管理员区分签名问题、URL token 问题、事件跳过、内容解析失败和投递失败；鉴权失败类信息必须遵循反枚举和最小披露原则。
- 边界场景：未知 webhook、URL token 错误、已删除 webhook、已解散群等场景不应通过 deliveries 向攻击者泄露存在性；授权管理员只能看到自己有权范围内的脱敏结果。
- 来源: modules/incomingwebhook/model.go#L88-L96；来源: modules/incomingwebhook/model.go#L215-L220；来源: modules/incomingwebhook/README.md#L395-L428

### F-01-6 存量迁移窗口
- 所属故事：US-04、US-05
- 需求描述：对已存在且未配置 GitHub webhook secret 的 GitHub webhook，系统应提供明确迁移窗口、风险标识、提醒文案和窗口结束后的处理口径。
- 业务规则：迁移窗口内，管理端应把未启用签名校验的 GitHub webhook 标记为安全待整改；窗口结束后，仍未完成配置的 GitHub webhook 应按签名校验失败处理，不继续静默接收。
- 边界场景：业务方无法在窗口内完成迁移、GitHub 仓库管理员与 Octo 管理员不是同一人、secret 疑似泄露或 webhook 长期无人维护时，应引导产品运营负责人或授权管理员确认延期、禁用或重建策略。
- 来源: modules/incomingwebhook/README.md#L200-L202；来源: modules/incomingwebhook/adapter_github.go#L9-L10

### F-01-7 文档与配置指引
- 所属故事：US-01、US-03、US-04
- 需求描述：GitHub incoming webhook 文档应更新为包含 Payload URL、Content type、Secret、签名校验状态、测试方法、常见失败原因和迁移说明的完整配置指南。
- 业务规则：文档应明确不再把“不强制 HMAC”作为最终口径；如仍存在迁移期兼容，应标明风险与截止口径。示例不得包含真实 token、secret、cookie 或生产 URL 中的敏感片段。
- 边界场景：GitHub ping、未支持事件、畸形 payload、内容过大、secret 不一致、迁移期豁免到期时，文档应给出用户可理解结果和排查路径。
- 来源: modules/incomingwebhook/README.md#L196-L215；来源: modules/incomingwebhook/adapter_github.go#L16-L20

### F-01-8 多租户、权限与防枚举
- 所属故事：US-02、US-05
- 需求描述：签名校验、管理端状态展示和 deliveries / audit 查询必须限制在操作者有权访问的 Space、群和 webhook 范围内。
- 业务规则：无权用户不得查看 webhook 是否存在、签名状态、secret 状态、delivery 详情或失败原因；错误口径不得帮助外部请求方枚举 webhook_id、URL token 或群存在性。
- 边界场景：跨 Space 查询、群已解散、webhook 被删除、创建者退群、管理员权限变化、外部请求批量尝试 token 或伪造签名时，应统一安全失败、限制或降噪。
- 来源: modules/incomingwebhook/api.go#L1320-L1349；来源: modules/incomingwebhook/api.go#L1352-L1365；来源: modules/incomingwebhook/api.go#L1383-L1414

### F-01-9 限流、防滥用与安全输入
- 所属故事：US-02、US-03、US-05
- 需求描述：GitHub 签名校验能力不得削弱现有 incoming webhook 的限流、防扫描和请求体保护；签名失败、重放尝试和异常高频请求应被安全处理。
- 业务规则：系统应保留对外部请求的失败预算、全局/按 IP/按 webhook 限流、请求体大小限制和安全失败口径；签名相关失败不得导致日志或审计写入明文 secret、签名原文或完整敏感 payload。
- 边界场景：高频签名失败、伪造 header、缺少 header、超大 payload、GitHub 重试风暴、Redis 限流依赖异常或共享出口 IP 时，应优先保护服务稳定性和隐私。
- 来源: modules/incomingwebhook/api.go#L230-L239；来源: modules/incomingwebhook/api.go#L1367-L1380；来源: modules/incomingwebhook/api.go#L1427-L1442

### F-01-10 审计与脱敏
- 所属故事：US-02、US-05
- 需求描述：系统应为 GitHub webhook 签名校验相关的配置变更、迁移状态、失败原因查看和异常请求保留脱敏审计摘要。
- 业务规则：审计摘要应能追溯谁在何时对哪个授权范围内的 GitHub webhook 查看或变更了签名校验状态，以及 delivery 的签名校验类别；不得记录明文 URL token、GitHub webhook secret、签名原文、cookie、私钥或完整敏感 payload。
- 边界场景：secret 重置、疑似泄露、迁移豁免延期、连续签名失败、跨范围查看失败或系统依赖异常时，应记录脱敏原因类别并提示人工复核。
- 来源: modules/incomingwebhook/model.go#L88-L96；来源: modules/incomingwebhook/model.go#L215-L220；来源: modules/incomingwebhook/README.md#L395-L428

## 5. 状态与提示

### GitHub webhook 签名状态

- 已启用签名校验：该 GitHub webhook 已配置签名校验要求，可按安全基线接收 GitHub delivery。
- 待配置 secret：该 GitHub webhook 尚未完成 GitHub webhook secret 配置，不能视为安全审计通过。
- 迁移期豁免：该存量 GitHub webhook 暂时未强制签名校验，但管理端明确显示风险、截止时间和整改建议。
- 迁移已到期：该 GitHub webhook 不再允许只靠 URL token 接收 GitHub delivery。
- 签名校验失败：GitHub delivery 缺少签名、签名格式不符合要求、签名不匹配或 secret 配置不一致。
- 状态不可确认：当前用户无权查看、配置不完整、依赖暂不可用或历史记录不足以确认。

### 推荐提示口径

- 新建 GitHub webhook：请在 GitHub Webhooks 中同时配置 Payload URL、Content type 和 Secret；Secret 与 Octo 侧 GitHub webhook secret 保持一致。
- 签名缺失：当前 GitHub delivery 未携带 required signature，请检查 GitHub Webhooks 的 Secret 配置。
- 签名不匹配：当前 GitHub delivery 的签名无法通过校验，请重新确认 GitHub Secret 与 Octo 侧配置是否一致。
- 迁移期风险：当前 GitHub webhook 仍处于未强制签名校验状态，请在迁移窗口结束前完成 secret 配置。
- 无权查看：当前账号无权查看该 webhook 的签名状态或 delivery 详情。

## 6. 验收标准

- AC-01：当管理员新建 GitHub incoming webhook 时，能看到 GitHub `X-Hub-Signature-256` 校验要求、secret 配置提示和安全说明。
- AC-02：当 GitHub delivery 携带正确签名且 URL token 仍有效时，事件能按原有 GitHub 适配器语义继续进入后续投递或跳过流程。
- AC-03：当 GitHub delivery 缺少签名、签名格式不符合要求、签名不匹配或 secret 未配置时，事件不会被投递到群内，调用方和授权管理员能看到脱敏且可修复的失败原因。
- AC-04：当 URL token 无效、webhook 不存在、webhook 已删除或群不可用时，系统继续使用安全失败口径，不通过签名错误差异泄露对象存在性。
- AC-05：当存量 GitHub webhook 尚未配置 secret 时，管理端能显示迁移期风险、截止时间和整改建议；迁移窗口结束后不再静默接收未签名的 GitHub delivery。
- AC-06：当授权管理员查看 deliveries / audit 时，能区分签名校验失败、迁移期豁免、事件跳过、内容解析失败和投递失败；结果不包含明文 URL token、secret、签名原文或完整敏感 payload。
- AC-07：当无权用户或外部请求方尝试查看签名状态、delivery 详情或通过错误差异探测 webhook 时，系统不给出可用于枚举的对象存在性信息。
- AC-08：当发生高频签名失败、伪造 header、超大 payload 或重试风暴时，系统能限制、降噪或安全失败，并保留脱敏追溯摘要。
- AC-09：GitHub incoming webhook 文档明确更新配置步骤、签名校验要求、迁移策略、常见失败原因和凭证脱敏规则。
- AC-10：任何界面、文档、日志、deliveries、审计和 issue 评论均不得展示真实 URL token、GitHub webhook secret、cookie、私钥或生产凭证。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P1`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/auth`、`area/bot-agent`
- V5 only：当前未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现 issue 正文或本 PRD 中包含明文 token/secret；但该需求属于外部 webhook 鉴权增强，涉及凭证、签名失败口径、迁移豁免和防枚举，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 迁移窗口时长与到期策略：是否按全局统一窗口执行，还是允许产品运营负责人对个别存量 webhook 做受控延期。
2. [待确认] 管理端签名状态的展示范围：仅 Space 管理员 / 群管理员可见，还是 webhook 创建者也可见受限状态。
3. [待确认] 迁移期豁免的安全审计口径：是否需要在产品文档中明确“不满足最终审计要求，仅用于过渡”。

## 9. 五类风险检查

- 多租户 / Space 隔离：签名状态、secret 状态、deliveries 和 audit 只能在操作者有权访问的 Space、群和 webhook 范围内展示；跨 Space 或跨群对象不得通过错误口径泄露。
- 权限 / ownership：只有有权管理或排障该 webhook 的角色可查看和调整签名校验状态；普通成员、外部请求方或无权调用方不得查看 secret 状态和 delivery 细节。
- 安全 / 外部输入 / 凭证：GitHub payload、signature header、URL token 和 GitHub webhook secret 都属于敏感或外部输入相关内容；界面、文档、日志、deliveries、审计和 issue 评论不得展示明文 secret、token、cookie、私钥、签名原文或完整敏感 payload。
- 限流 / 防滥用：签名校验失败、伪造 header、批量 token 尝试和 GitHub 重试风暴需要保持限流、防扫描、请求体大小限制和降噪，避免成为新攻击面。
- 审计 / 可追溯：签名校验状态变更、迁移豁免、失败原因查看和异常请求应可追溯到操作者、时间、Space / 群 / webhook 范围和脱敏结果类别；不得记录明文敏感信息。

## 10. What-only 自检摘要

- 技术 How：通过。PRD 只定义管理员 / 调用方 / 审计人员可见的签名校验能力、配置口径、迁移策略、失败提示、deliveries / audit 口径和安全边界；未定义内部字段、SQL、缓存、队列、代码或签名算法实现。
- 引用核验：通过。源码和文档引用已按当前只读目标仓核验，覆盖现有 GitHub webhook 文档、适配器注释、适配器注册、URL token 鉴权、限流、失败审计和 deliveries 相关边界。
- Label 完整性：通过。Issue #32 当前具备 `type/feature`、`priority/P1`、`status/prd-drafting`、`area/auth`、`area/bot-agent`；PRD 完成后建议唯一状态更新为 `status/reviewing`。
- 状态真实性：通过。当前为 PRD 草拟中；完成远端 PRD、issue 回填和群内交接后可进入 `status/reviewing`。
- 风险提醒 / 待人工确认：是。需产品运营负责人确认迁移窗口、可见角色和迁移期豁免的审计口径。
