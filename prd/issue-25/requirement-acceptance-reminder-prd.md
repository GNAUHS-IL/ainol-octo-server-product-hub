# PRD：需求单验收提醒与一键反馈能力

## 1. 背景与问题

Issue #25 反馈：需求单开发完成并进入待验收后，创建人、关注人或相关业务方不一定能及时看到，容易导致需求长期卡在待验收。用户希望 Octo Server 支持待验收自动提醒、超时再次提醒，并支持在提醒中一键确认通过或补充问题。本需求为 P2 普通增强，聚焦验收节点专项闭环。

现有源码显示，Octo 已具备系统通知 Bot、内部通知入口、卡片/文本通知、通知免打扰、互动卡片动作、目标成员过滤、Space / 群 / Thread 权限边界、限流与审计基础；本 PRD 仅定义“待验收提醒与一键反馈”的用户可见行为、状态口径、权限边界与验收标准，不定义内部实现方案。

- 通知模块使用共享 `notification` User Bot 承载总结卡片、文档卡片、动作结果和文本通知，说明系统存在统一系统通知会话与能力隔离边界。来源: modules/notify/api.go#L51-L59
- 通知请求包含 Space、服务、事件、目标用户、操作者与通知内容，并返回已送达和被过滤目标。来源: modules/notify/model.go#L14-L23；来源: modules/notify/model.go#L112-L122
- 内部通知入口在未配置认证能力时拒绝请求，并按 token 能力区分可用通知能力。来源: modules/notify/api.go#L216-L228；来源: modules/notify/api.go#L229-L240
- 通知投递前会对目标去重、排除操作者，并校验目标是否为当前 Space 成员；无可投递成员时返回空送达与过滤原因。来源: modules/notify/card.go#L107-L117；来源: modules/notify/card.go#L119-L127
- 卡片通知支持卡片不可用时降级为文本提示，同时对卡片构建和发送失败保留失败原因。来源: modules/notify/card.go#L141-L147；来源: modules/notify/card.go#L155-L156；来源: modules/notify/card.go#L198-L207；来源: modules/notify/card.go#L210-L224；来源: modules/notify/card.go#L226-L231
- 通知模块已有账号级通知暂停能力，支持手动暂停与定时暂停，并暴露当前暂停状态。来源: modules/notification/api.go#L21-L25；来源: modules/notification/api.go#L31-L38；来源: modules/notification/api.go#L93-L103；来源: modules/notification/api.go#L105-L112；来源: modules/notification/model.go#L11-L16；来源: modules/notification/model.go#L26-L32
- 离线推送会在通知暂停查询成功时排除暂停用户；查询失败时不会把通知批次静默丢弃。来源: modules/webhook/notification_pause.go#L3-L10；来源: modules/webhook/notification_pause.go#L13-L24
- 标准互动卡片要求目标 1-200 个用户、去重、排除操作者，且只能投递给当前 Space 成员。来源: docs/card-action-callback-dispatch.md#L151-L156
- 互动卡片请求返回真实投递结果；成功响应不等于所有目标均已收到，调用方必须检查送达与过滤结果。来源: docs/card-action-callback-dispatch.md#L158-L165
- 标准互动卡片动作由服务端生成，用户动作会产生唯一决策，消费者需校验当前授权、幂等和业务状态。来源: docs/card-action-callback-dispatch.md#L167-L181；来源: docs/card-action-callback-dispatch.md#L186-L190；来源: docs/card-action-callback-dispatch.md#L192-L201
- 互动卡片回调中的操作者身份是 Octo Server 的认证断言，但消费者仍需校验该用户是否能决定对应请求。来源: docs/card-action-callback-consumer.md#L173-L180
- Space 隔离规则要求访问用户数据必须执行隔离和 ownership 校验，跨 Space 读写属于 P0 数据泄漏风险。来源: .octospec/rules/space-isolation.md#L19-L31；来源: .octospec/rules/space-isolation.md#L34-L37
- 卡片派发会校验目标 Space、会话类型、卡片内容和派发授权；目标 Space、DM 接收人、群或 Thread 均需满足对应授权约束。来源: internal/carddispatch/dispatch.go#L39-L50；来源: internal/carddispatch/dispatch.go#L89-L93；来源: internal/carddispatch/dispatch.go#L222-L233；来源: internal/carddispatch/dispatch.go#L234-L240；来源: internal/carddispatch/authorizer_db.go#L23-L36；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: internal/carddispatch/authorizer_db.go#L50-L60；来源: internal/carddispatch/authorizer_db.go#L115-L129；来源: internal/carddispatch/authorizer_db.go#L149-L163；来源: internal/carddispatch/authorizer_db.go#L165-L179
- 外部内容进入消息渲染前需要在正确边界转义、限制结构和大小，避免 markdown / richtext 注入或异常载荷。来源: .octospec/rules/trust-boundary.md#L19-L32；来源: .octospec/rules/trust-boundary.md#L33-L47
- 限流规则要求认证入口使用共享限流、未认证入口使用严格 IP 限流，不应为通用请求频控手写计数。来源: .octospec/rules/rate-limit.md#L19-L29
- 凭据类 token 只保留不可逆摘要，不进入日志或指标；审计日志对敏感查询内容使用哈希摘要而不是明文。来源: modules/bot_api/ratelimit.go#L39-L48；来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L41-L46；来源: modules/messages_search/audit.go#L62-L70

## 2. 目标与非目标

### 目标

- 明确定义“待验收”状态的产品口径：处理结果已可供业务方确认，但尚未收到有权验收人的确认通过或补充问题，不等同于已完成或已验收通过。
- 当需求单进入待验收后，自动提醒有权验收的创建人、被指定验收人、关注人或相关业务方。
- 当超过产品定义时间仍未收到验收反馈时，再次提醒有权验收对象，并具备免打扰、合并提醒和频控边界。
- 提醒内容展示接收人有权查看的需求编号、标题摘要、当前状态、验收截止/超时提示、待处理动作和安全跳转入口。
- 支持接收人在提醒中快速选择“确认通过”或“补充问题/验收不通过”，并看到动作结果和当前状态口径。
- 对无权、退群、跨 Space / 群 / Thread、失效关注人、敏感内容、重复点击、并发反馈、发送失败和审计追溯建立统一口径。

### 非目标

- 不替产品运营负责人裁定需求是否最终 accepted、done、wontfix、duplicate、invalid 或优先级变化。
- 不把“已提醒”“已送达”“已读”“进入待验收”表达为“验收通过”或“已完成”。
- 不要求所有待验收提醒公开发群；通知渠道应按权限、提醒对象、来源场景和免打扰规则决定。
- 不向无权用户展示无权需求、无权评论、无权附件、跨 Space / 跨群 / 跨 Thread / 跨 Bot 的详情或存在性。
- 不在 PRD 中定义内部数据结构、调度方式、接口字段、队列、SQL、缓存、部署或代码实现。
- 不在通知、评论、日志或审计中明文复述 token、cookie、secret、私钥、生产凭证或完整私密正文。

## 3. 用户故事

### US-01：反馈人收到首次待验收提醒
- 角色：作为需求创建人或被指定验收的业务方
- 场景：当我提交或关注的需求已处理完成并进入待验收
- 诉求：希望收到明确提醒，知道当前需要我确认通过或补充问题
- 价值：以便我及时完成验收，不让需求长期卡在待验收
- 来源: modules/notify/model.go#L14-L23；来源: modules/notify/card.go#L107-L117；来源: modules/notify/card.go#L119-L127；来源: docs/card-action-callback-dispatch.md#L151-L156

### US-02：业务方收到超时再次提醒但不被刷屏
- 角色：作为需求创建人、关注人或被指定验收人
- 场景：当我在产品定义时间内未处理待验收事项
- 诉求：希望系统再次提醒我，但不要短时间重复刷屏，也要尊重免打扰
- 价值：以便我不会错过关键验收，同时保持消息体验可控
- 来源: modules/notification/api.go#L21-L25；来源: modules/notification/api.go#L31-L38；来源: modules/notification/api.go#L93-L103；来源: modules/notification/api.go#L105-L112；来源: modules/webhook/notification_pause.go#L3-L10；来源: .octospec/rules/rate-limit.md#L19-L29

### US-03：验收人在提醒中一键反馈
- 角色：作为有权验收的接收人
- 场景：当我看到待验收提醒并准备处理
- 诉求：希望能直接选择“确认通过”或“补充问题/验收不通过”，并看到反馈是否生效
- 价值：以便我用最少步骤完成验收反馈，减少来回沟通
- 来源: docs/card-action-callback-dispatch.md#L167-L181；来源: docs/card-action-callback-dispatch.md#L186-L190；来源: docs/card-action-callback-consumer.md#L173-L180；来源: internal/cardactiondispatch/contract.go#L13-L23；来源: internal/cardactiondispatch/contract.go#L25-L32

### US-04：产品运营负责人看到验收节点真实状态
- 角色：作为 Octo 产品运营负责人
- 场景：当多个需求进入待验收、超时未验收或收到补充问题
- 诉求：希望状态、提醒结果和用户反馈能区分待验收、已通过、需补充问题、已超时等口径
- 价值：以便我准确推进需求池，不把提醒成功误判为验收完成
- 来源: docs/card-action-callback-dispatch.md#L158-L165；来源: modules/notify/card.go#L235-L243；来源: modules/notify/card.go#L245-L256；来源: modules/notify/model.go#L112-L122

### US-05：无权、跨范围和敏感内容得到安全处理
- 角色：作为普通成员、验收人、关注人或系统运营人员
- 场景：当提醒对象失去权限、跨 Space / 群 / Thread，或需求内容含敏感信息
- 诉求：希望系统安全过滤或脱敏，并给出不泄露详情的提示
- 价值：以便验收提醒提升协作效率，同时不破坏多租户、权限、安全、限流和审计边界
- 来源: .octospec/rules/space-isolation.md#L19-L31；来源: .octospec/rules/space-isolation.md#L34-L37；来源: internal/carddispatch/authorizer_db.go#L23-L36；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: internal/carddispatch/authorizer_db.go#L50-L60；来源: .octospec/rules/trust-boundary.md#L19-L32；来源: .octospec/rules/trust-boundary.md#L33-L47；来源: modules/bot_api/ratelimit.go#L39-L48

## 4. 功能需求

### F-01-1 待验收状态定义
- 所属故事：US-01、US-04
- 需求描述：系统应明确“待验收”表示需求处理结果已可供业务方确认，但尚未收到有权验收人的“确认通过”或“补充问题/验收不通过”。
- 业务规则：待验收不得被展示为已完成、已通过、已关闭或已读；若需求当前状态已变化，提醒和入口必须以当前真实状态为准。
- 边界场景：需求被关闭、重开、撤回验收、转为 blocked / duplicate / wontfix / invalid、或状态口径冲突时，应提示当前状态和必要的人工确认入口。
- 来源: docs/card-action-callback-dispatch.md#L186-L190；来源: docs/card-action-callback-dispatch.md#L158-L165

### F-01-2 首次待验收提醒
- 所属故事：US-01、US-04
- 需求描述：当需求单首次进入待验收后，系统应向有权验收对象发送提醒。
- 业务规则：提醒对象至少覆盖需求创建人、被明确指定验收人；可覆盖有权关注人或相关业务方。若操作者本人也是接收对象，可按产品规则排除或展示为“你刚刚发起/处理过”。
- 边界场景：创建人退群、验收人失效、关注人失去权限、无可通知对象、通知 Bot 不可用或目标会话不可达时，应保留安全失败摘要，不误报为已提醒完成。
- 来源: modules/notify/card.go#L107-L117；来源: modules/notify/card.go#L119-L127；来源: docs/card-action-callback-dispatch.md#L151-L156；来源: modules/notify/api.go#L298-L312；来源: modules/notify/api.go#L315-L321

### F-01-3 超时再次提醒
- 所属故事：US-02、US-04
- 需求描述：当需求进入待验收后超过产品定义时间仍未收到有效验收反馈，系统应再次提醒有权验收对象。
- 业务规则：再次提醒应展示“已等待多久/已超时”的用户可读提示、当前真实状态、待处理动作和入口；同一需求、同一对象、同一验收阶段应有合并提醒或间隔控制。
- 边界场景：提醒期间状态变化、已有其他验收人完成反馈、需求被关闭/阻塞、对象免打扰、提醒数量过多或短时间重复触发时，应停止、合并或降噪，并说明原因。
- 来源: modules/notification/api.go#L21-L25；来源: modules/notification/api.go#L31-L38；来源: modules/notification/api.go#L93-L103；来源: modules/notification/api.go#L105-L112；来源: modules/webhook/notification_pause.go#L3-L10；来源: .octospec/rules/rate-limit.md#L19-L29

### F-01-4 提醒渠道与内容
- 所属故事：US-01、US-02、US-05
- 需求描述：提醒应优先发送到 Octo 内接收人有权触达的私聊、群聊或 Thread 场景，并展示需求编号、标题摘要、当前状态、验收动作、超时提示和安全跳转入口。
- 业务规则：私聊适合个人验收动作；群聊或 Thread 提醒仅在接收人和内容均对当前会话可见时使用。提醒内容只展示接收人有权查看的信息，并对过长或敏感内容做截断/脱敏。
- 边界场景：标题过长、评论不可见、附件不可见、跳转目标失效、卡片不可用或卡片渲染失败时，应降级为安全文本或展示可恢复提示。
- 来源: modules/notify/api.go#L51-L59；来源: modules/notify/card.go#L141-L147；来源: modules/notify/card.go#L155-L156；来源: .octospec/rules/trust-boundary.md#L19-L32；来源: .octospec/rules/trust-boundary.md#L33-L47

### F-01-5 一键确认通过
- 所属故事：US-03、US-04
- 需求描述：有权验收人应能在提醒中选择“确认通过”，并看到反馈已提交、需求当前状态和下一步说明。
- 业务规则：只有当前有权验收人可以执行确认；确认通过后，不应继续对同一验收阶段发送超时提醒；如果多人验收，需明确是单人即可通过、指定人全部通过，还是由产品运营负责人最终确认。
- 边界场景：重复点击、并发点击、状态已变化、用户失去权限、入口过期或已有相反反馈时，应展示当前真实结果，不能覆盖已生效决策。
- 来源: docs/card-action-callback-dispatch.md#L192-L201；来源: docs/card-action-callback-consumer.md#L173-L180；来源: internal/cardactiondispatch/contract.go#L17-L23；来源: internal/cardactiondispatch/contract.go#L25-L32

### F-01-6 一键补充问题 / 验收不通过
- 所属故事：US-03、US-04
- 需求描述：有权验收人应能在提醒中选择“补充问题/验收不通过”，并能提交简短问题说明或跳转到有权评论入口补充材料。
- 业务规则：补充问题后，需求不得继续显示为“等待该用户确认通过”；应明确进入待处理、待补充或需产品运营负责人确认的口径。问题内容应按接收人权限和敏感信息规则展示。
- 边界场景：补充内容为空、包含疑似凭证、评论入口不可用、状态已变化或多个验收人反馈冲突时，应提示原因和下一步，不泄露无权内容。
- 来源: modules/notify/action_finalizer.go#L113-L118；来源: modules/notify/action_finalizer.go#L119-L128；来源: .octospec/rules/trust-boundary.md#L37-L47；来源: modules/bot_api/ratelimit.go#L39-L48

### F-01-7 操作结果提示与终态卡片
- 所属故事：US-03、US-04
- 需求描述：用户完成一键反馈后，原提醒应展示不可重复误操作的结果态，至少说明已确认通过、已补充问题、已失效、无权、冲突或需人工确认。
- 业务规则：结果态应移除或禁用不再适用的动作，并展示操作者、处理时间和当前状态的安全摘要；对已提交决策的重复操作应展示已有结果。
- 边界场景：终态更新失败、卡片已删除、目标会话不可达、并发冲突或状态回滚时，应避免产生第二套相互矛盾的提醒。
- 来源: modules/notify/action_finalizer.go#L155-L164；来源: modules/notify/action_finalizer.go#L167-L175；来源: modules/notify/action_finalizer.go#L176-L190；来源: modules/notify/action_finalizer.go#L191-L205；来源: modules/notify/card_mutate_api.go#L57-L70

### F-01-8 权限与验收资格
- 所属故事：US-03、US-05
- 需求描述：提醒接收、跳转查看、一键确认和补充问题都必须按当前用户权限和验收资格判断。
- 业务规则：用户只能处理自己有权查看且有权验收的需求；权限变化后，后续提醒和一键动作应按最新权限过滤；无权用户不能通过错误提示、通知缺失或反馈入口推断无权需求详情。
- 边界场景：跨 Space、跨群、跨 Thread、退群、角色变化、Bot 不在目标会话、需求迁移或来源对象删除时，应展示安全失败或不可用提示。
- 来源: .octospec/rules/space-isolation.md#L19-L31；来源: .octospec/rules/space-isolation.md#L34-L37；来源: internal/carddispatch/dispatch.go#L89-L93；来源: internal/carddispatch/authorizer_db.go#L23-L36；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: internal/carddispatch/authorizer_db.go#L50-L60；来源: internal/carddispatch/authorizer_db.go#L115-L129；来源: internal/carddispatch/authorizer_db.go#L149-L163；来源: internal/carddispatch/authorizer_db.go#L165-L179

### F-01-9 免打扰、频控与合并提醒
- 所属故事：US-02、US-05
- 需求描述：系统应支持账号级免打扰/暂停通知，并对同一需求、同一验收阶段、同一接收人的重复提醒做合并或频控。
- 业务规则：非阻塞普通提醒应尊重用户免打扰；必须处理的责任提醒应给出清晰但克制的提示。频控生效时，应保留可追溯结果，不把未发送误报为已送达。
- 边界场景：大量需求同时进入待验收、同一需求反复进入待验收、机器人重复触发、用户手动暂停通知或通知查询失败时，应避免刷屏，同时不静默丢失关键待办。
- 来源: modules/notification/api.go#L21-L25；来源: modules/notification/api.go#L31-L38；来源: modules/notification/api.go#L93-L103；来源: modules/notification/api.go#L105-L112；来源: modules/webhook/notification_pause.go#L3-L10；来源: .octospec/rules/rate-limit.md#L19-L29

### F-01-10 通知结果与失败摘要
- 所属故事：US-04、US-05
- 需求描述：系统应区分已送达、因无权限被过滤、目标不可达、免打扰、内容不合规、频控、发送失败和卡片不可用等结果，并向运营人员展示安全摘要。
- 业务规则：部分成功时，应展示送达和未送达的安全摘要；通知失败不得被误提示为已通知；无权对象和敏感内容不得出现在失败详情中。
- 边界场景：Bot 不可用、目标退群、卡片渲染失败、目标被拒绝、并发忙碌或网络异常时，应提示可恢复操作或转人工确认。
- 来源: modules/notify/model.go#L112-L122；来源: modules/notify/card.go#L198-L207；来源: modules/notify/card.go#L210-L224；来源: modules/notify/card.go#L226-L231；来源: modules/notify/card.go#L235-L243；来源: modules/notify/card.go#L245-L256；来源: docs/card-action-callback-dispatch.md#L158-L165

### F-01-11 敏感信息脱敏与输入安全
- 所属故事：US-05
- 需求描述：需求标题、评论摘要、补充问题、跳转说明或验收反馈中包含疑似敏感信息时，提醒和审计应展示脱敏摘要或人工确认提示。
- 业务规则：疑似 token、cookie、secret、私钥、生产凭证、客户隐私、内部敏感链接不得在群提醒、公开评论、通知正文或审计摘要中明文复述。
- 边界场景：用户在补充问题中粘贴凭证、标题本身含敏感内容、来源评论不可见或内容结构异常时，应优先安全降级。
- 来源: .octospec/rules/trust-boundary.md#L19-L32；来源: .octospec/rules/trust-boundary.md#L33-L47；来源: modules/bot_api/ratelimit.go#L39-L48；来源: modules/messages_search/audit.go#L12-L24

### F-01-12 审计与追溯
- 所属故事：US-04、US-05
- 需求描述：待验收进入、首次提醒、再次提醒、免打扰命中、一键确认、补充问题、目标过滤、发送失败和状态变化应有可追溯安全摘要。
- 业务规则：审计摘要应能说明操作者、需求范围、验收阶段、动作类型、目标数量、送达/过滤结果和处理时间；不得记录明文敏感内容、完整私密正文或无权对象详情。
- 边界场景：重复点击、并发反馈、状态回退、多人验收或跨会话通知时，应能追溯最终以哪个状态、哪个验收反馈和哪个通知结果为准。
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L41-L46；来源: modules/messages_search/audit.go#L62-L70；来源: modules/notify/card.go#L245-L256

## 5. 状态与提示

- 待验收：处理结果已可供业务方确认，但尚未收到有效验收反馈；不等于已完成或已通过。
- 首次提醒已发送：系统已向有权验收对象发送首次提醒；不代表已读或已验收。
- 等待验收反馈：当前仍缺少有权验收人的确认通过或补充问题。
- 已超时待验收：超过产品定义时间仍未收到有效验收反馈，需要再次提醒或人工跟进。
- 再次提醒已发送：系统已按规则发送超时提醒；不代表验收完成。
- 已确认通过：有权验收人完成确认通过；后续是否进入 done / accepted / 其他状态以产品运营负责人最终口径为准。
- 已补充问题：有权验收人提交问题或验收不通过说明，需要处理人或产品运营负责人继续跟进。
- 反馈入口已失效：需求状态已变化、入口过期或卡片不再代表当前状态，需要打开详情查看最新状态。
- 无权处理：当前用户无权查看或验收该需求，不展示需求详情。
- 已合并提醒：短时间内同一需求多次变化或多次超时提醒被合并展示。
- 免打扰生效：用户通知暂停或免打扰命中，普通提醒不打扰；必要责任提醒按产品规则处理。
- 部分送达：部分目标因无权、退群、免打扰、不可达、频控或发送失败未收到提醒，仅展示安全摘要。
- 疑似敏感内容：提醒内容已脱敏或需人工确认后再展示。

## 6. 验收标准

- AC-01：当需求进入待验收时，有权验收对象能收到首次提醒，并看到需求编号、标题摘要、当前状态、待处理动作和安全入口。
- AC-02：待验收提醒清楚表达“等待验收反馈”，不会把进入待验收、提醒已发送或消息已读误报为验收通过或已完成。
- AC-03：当超过产品定义时间仍无有效验收反馈时，有权验收对象能收到再次提醒，并能看到超时提示和当前真实状态。
- AC-04：同一需求、同一验收阶段、同一接收人的重复提醒具备合并、间隔或频控边界，避免刷屏。
- AC-05：当用户开启免打扰或通知暂停时，普通待验收提醒按规则降噪；必要责任提醒的处理口径清晰可见。
- AC-06：有权验收人能在提醒中选择“确认通过”，并看到反馈已提交、当前状态和下一步说明。
- AC-07：有权验收人能在提醒中选择“补充问题/验收不通过”，并能提交或跳转补充说明；系统不会继续把该用户展示为未反馈。
- AC-08：当用户重复点击、并发点击、入口过期、状态已变化或已有相反反馈时，系统展示当前真实结果，不覆盖已生效决策。
- AC-09：无权用户、退群用户、失效关注人、跨 Space / 跨群 / 跨 Thread / 跨 Bot 场景不能看到无权需求详情，也不能通过错误提示推断无权对象存在性。
- AC-10：提醒内容和跳转入口只展示接收人有权查看的信息；标题、评论、附件和补充问题中的疑似敏感内容需脱敏或人工确认。
- AC-11：通知失败、部分送达、目标过滤、免打扰命中、频控命中和卡片不可用时，运营人员能看到安全失败摘要，不误报为全部送达。
- AC-12：首次提醒、再次提醒、一键确认、补充问题、权限过滤、发送失败和状态变化均有可追溯安全摘要，且审计不记录明文敏感信息。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/im`、`area/bot-agent`
- V5 only：未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及验收资格、跨 Space / 群 / Thread 可见性、一键反馈权限、免打扰、频控、敏感内容脱敏和审计，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 首版“有权验收对象”是否仅包含创建人和被指定验收人，还是同时包含所有关注人、被 @ 协作者或产品运营负责人指定的业务方。
2. [待确认] 首版超时阈值与再次提醒节奏采用统一默认值，还是允许按需求类型、优先级或 Space 配置。
3. [待确认] 多人验收时，“确认通过”的生效规则是任一有权验收人即可通过、指定验收人全部通过，还是必须由产品运营负责人最终确认。

## 9. 五类风险检查

- 多租户 / Space 隔离：待验收提醒、验收入口、状态摘要和跳转目标必须按当前接收人有权 Space / 群 / Thread / Bot 范围展示；无权对象不展示详情，也不泄露存在性。
- 权限 / ownership：只有当前有权验收人可以确认通过或补充问题；产品运营负责人保留最终状态和优先级裁定权，需求管理专员不越权仲裁。
- 安全 / 外部输入 / 凭证：需求标题、评论、附件摘要和补充问题可能含外部输入或敏感信息；疑似 token、cookie、secret、私钥、生产凭证必须脱敏或人工确认。
- 限流 / 防滥用：首次提醒、超时再次提醒、一键反馈、失败重试和批量待验收场景需要频率、数量、合并与重复点击边界，避免刷屏、枚举或通知风暴。
- 审计 / 可追溯：待验收进入、提醒发送、免打扰、目标过滤、一键反馈、失败结果和状态变化需记录安全摘要；审计不得记录明文敏感内容、完整私密正文或无权对象详情。

## 10. What-only 自检摘要

- 技术 How：通过；PRD 仅定义用户可见能力、状态、提示、权限、风险和验收，未包含内部落地细节、数据结构、部署方案或代码实现。
- 引用核验：通过；引用均来自只读目标仓 `Mininglamp-OSS/octo-server`，需通过引用核验脚本检查。
- Label 完整性：通过；Issue #25 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/im`、`area/bot-agent`。
- 状态真实性：通过；Issue #25 当前远端为 open 且 `status/prd-drafting`，本 PRD 完成后应流转为唯一 `status/reviewing`，由产品运营负责人 Review。
- 风险提醒 / 待人工确认：有；重点是验收对象范围、超时阈值、多人验收生效规则、状态真实性、跨范围权限、一键反馈防误操作、免打扰、频控、敏感信息脱敏和审计。
