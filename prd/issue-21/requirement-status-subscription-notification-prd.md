# PRD：需求单状态变更订阅通知能力

## 1. 背景与问题

Issue #21 反馈：群内反馈人希望 Octo Server 增加“需求单状态变更订阅通知”能力。需求单创建后，用户可以订阅自己创建或关注的需求单；当状态变更、负责人变更、需要补充信息或进入验收时，系统能在 Octo 中自动提醒相关用户，降低反馈人或关注人错过关键节点的风险。

现有源码显示，Octo 已具备通知 Bot、内部通知入口、结构化卡片/文本通知、Bot 消息发送、Bot 事件读取、目标成员过滤、Space / 群 / Thread 权限边界、限流和审计相关基础能力；本 PRD 仅定义“需求单状态变更订阅通知”的用户可见行为、状态提示、权限边界和验收标准，不定义内部实现方式。

- 通知模块已通过统一 notification User Bot 承载文本通知、总结卡片、文档卡片和动作结果等系统 DM 通知，说明系统存在集中通知身份与能力边界。来源: modules/notify/api.go#L51-L59
- 通知请求包含 Space、服务、事件、目标用户、操作者和通知内容，并返回已送达与被过滤目标，说明通知需要面向明确 Space、事件和接收人呈现结果。来源: modules/notify/model.go#L14-L23；来源: modules/notify/model.go#L112-L122
- 内部通知入口使用独立认证能力，未配置时拒绝请求，避免未经授权的内部通知写入。来源: modules/notify/api.go#L216-L228；来源: modules/notify/api.go#L229-L240
- 通知投递前会做目标去重、排除操作者，并校验目标在当前 Space 的成员状态；没有可投递成员时返回空送达和过滤原因。来源: modules/notify/card.go#L107-L121；来源: modules/notify/card.go#L122-L127
- 卡片派发会校验目标 Space 和会话类型，并在派发前按身份、目标和策略进行授权。来源: internal/carddispatch/dispatch.go#L39-L50；来源: internal/carddispatch/dispatch.go#L89-L93；来源: internal/carddispatch/dispatch.go#L222-L234；来源: internal/carddispatch/dispatch.go#L235-L240
- 派发授权要求目标 Space 有效，DM 接收人是目标 Space 活跃成员；群和 Thread 目标也要满足活动状态与归属约束。来源: internal/carddispatch/authorizer_db.go#L23-L36；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: internal/carddispatch/authorizer_db.go#L50-L60；来源: internal/carddispatch/authorizer_db.go#L115-L129；来源: internal/carddispatch/authorizer_db.go#L132-L146；来源: internal/carddispatch/authorizer_db.go#L147-L147；来源: internal/carddispatch/authorizer_db.go#L149-L163；来源: internal/carddispatch/authorizer_db.go#L165-L179；来源: internal/carddispatch/authorizer_db.go#L180-L180
- Bot 发送消息要求目标会话、会话类型和内容有效，并拒绝伪造服务端保留字段。来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L60-L70；来源: modules/bot_api/send.go#L72-L84；来源: modules/bot_api/send.go#L85-L96
- Bot 发送前执行发送权限检查，涉及代用户发送时还会校验授权和目标会话范围。来源: modules/bot_api/send.go#L160-L174；来源: modules/bot_api/send.go#L172-L176；来源: modules/bot_api/send.go#L180-L188；来源: modules/bot_api/send.go#L227-L240；来源: modules/bot_api/send.go#L241-L244
- Bot 事件读取按认证后的 Bot 身份返回可见事件，限制单次读取数量并支持等待，说明提醒链路应避免让订阅者读到不属于自己的事件。来源: modules/bot_api/events.go#L19-L33；来源: modules/bot_api/events.go#L34-L35；来源: modules/bot_api/events.go#L35-L35；来源: modules/bot_api/events.go#L62-L74；来源: modules/bot_api/events.go#L76-L85
- Space 隔离规则要求访问用户数据时不得跨 Space，Bot 操作需校验 ownership，Thread 操作需校验父会话访问。来源: .octospec/rules/space-isolation.md#L21-L31；来源: .octospec/rules/space-isolation.md#L34-L37
- 搜索访问控制要求调用者只能访问已可读取会话，且无权时不得泄露对象是否存在。来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L46-L50
- 限流规则要求认证入口使用共享限流，未认证入口使用严格 IP 限流，通用请求频控应复用统一限流能力。来源: .octospec/rules/rate-limit.md#L19-L29
- Bot API 限流说明明确 token 等凭据只保留不可逆摘要，不进入日志或指标。来源: modules/bot_api/ratelimit.go#L39-L48
- 搜索审计会记录主体、会话、耗时等安全摘要，并对关键词使用哈希，避免在共享审计通道记录敏感明文。来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L41-L46；来源: modules/messages_search/audit.go#L62-L70

## 2. 目标与非目标

### 目标

- 支持用户订阅自己创建或有权关注的需求单，并能取消订阅。
- 当需求单发生关键变化时，向有权接收的订阅者或相关责任人发送 Octo 提醒。
- 关键变化至少覆盖：状态变更、负责人变更、需要补充信息、进入验收、关闭/重开、被标记为 duplicate / wontfix / invalid / blocked 等影响用户判断的节点。
- 通知内容展示用户有权查看的需求单编号、标题摘要、变更类型、当前状态、下一步动作和跳转入口。
- 通知必须以当前真实状态为准，不把 blocked、duplicate、wontfix、invalid、未复现等状态误报为已完成。
- 对订阅范围、通知对象、免打扰、重复提醒、无权/失效场景、频率控制、脱敏和审计建立统一产品口径。

### 非目标

- 不替产品运营负责人裁定需求是否 accepted、duplicate、wontfix、invalid 或最终优先级。
- 不定义内部落地细节、数据结构、部署方案或代码实现。
- 不要求所有需求变化都公开发群；私聊、群聊或 Thread 通知应按订阅关系、权限和免打扰规则决定。
- 不向无权用户展示无权需求、无权评论、无权附件、跨 Space / 跨群 / 跨 Thread / 跨 Bot 的私密详情。
- 不在通知、评论、日志或审计摘要中复述 token、cookie、secret、私钥、生产凭证或完整私密消息正文。
- 不用“通知已发出”代替“用户已读”或“验收通过”。

## 3. 用户故事

### US-01：反馈人订阅自己创建的需求单
- 角色：作为群内反馈人或需求提交人
- 场景：当我提交需求后，不想持续手动刷新需求单状态
- 诉求：希望能订阅该需求单，并在关键状态变化时收到 Octo 提醒
- 价值：以便我及时知道是否需要补充信息、验收或查看处理结论
- 来源: modules/notify/api.go#L51-L59；来源: modules/notify/model.go#L14-L23；来源: modules/bot_api/events.go#L19-L33；来源: modules/bot_api/events.go#L34-L35；来源: modules/bot_api/events.go#L35-L35

### US-02：关注人订阅有权查看的需求单
- 角色：作为需求关注人、协作人或相关群成员
- 场景：当我关注某个已有需求，希望跟进后续状态
- 诉求：希望在有权范围内订阅或取消订阅，并看到订阅是否成功
- 价值：以便我能跟进相关需求，而不会看到无权对象详情
- 来源: internal/carddispatch/authorizer_db.go#L23-L36；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: internal/carddispatch/authorizer_db.go#L50-L60；来源: .octospec/rules/space-isolation.md#L21-L31

### US-03：产品运营负责人明确通知对象和下一步
- 角色：作为 Octo 产品运营负责人
- 场景：当需求进入待评估、PRD、开发中、验收、关闭或需要补充信息等阶段
- 诉求：希望订阅通知能准确告知相关人当前状态、变化原因和下一步动作
- 价值：以便减少重复追问，并让状态沟通与 GitHub 当前事实保持一致
- 来源: modules/notify/model.go#L112-L122；来源: modules/notify/card.go#L245-L256

### US-04：需求管理专员和主考接收关键交接提醒
- 角色：作为 Octo 需求管理专员或主考
- 场景：当需求进入 PRD 草拟、Review、返工或验收节点
- 诉求：希望相关负责人在有权范围内收到交接提醒，提醒包含需求编号、状态和需要处理的下一步
- 价值：以便后台闭环不依赖人工刷屏，也不遗漏 Review 或返工节点
- 来源: modules/notify/api.go#L157-L166；来源: modules/notify/api.go#L298-L312；来源: modules/notify/api.go#L313-L321；来源: modules/notify/api.go#L315-L321

### US-05：无权限、免打扰或敏感内容得到安全处理
- 角色：作为普通成员、订阅者、被通知人或系统运营人员
- 场景：当订阅目标无权、需求跨范围、通知过于频繁或内容含敏感信息
- 诉求：希望系统给出清晰提示或安全降级，不泄露无权和敏感内容
- 价值：以便通知能力提升协作效率，同时保护多租户、权限、安全、限流和审计边界
- 来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L46-L50；来源: .octospec/rules/rate-limit.md#L19-L29；来源: modules/messages_search/audit.go#L12-L24

## 4. 功能需求

### F-01-1 订阅与取消订阅
- 所属故事：US-01、US-02
- 需求描述：用户应能对自己创建或有权关注的需求单执行订阅和取消订阅，并能看到当前订阅状态。
- 业务规则：订阅入口应明确目标需求单编号、标题摘要和当前状态；取消订阅后，除用户仍属于必须通知的责任场景外，不再收到普通订阅提醒。
- 边界场景：需求不存在、已关闭、用户无权查看、跨 Space / 跨群 / 跨 Thread、重复订阅、重复取消或订阅目标失效时，应展示明确原因和可恢复建议，不泄露无权对象详情。
- 来源: internal/carddispatch/authorizer_db.go#L23-L36；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: internal/carddispatch/authorizer_db.go#L50-L60；来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L46-L50；来源: .octospec/rules/space-isolation.md#L21-L31

### F-01-2 自动订阅默认规则
- 所属故事：US-01、US-03
- 需求描述：系统应明确哪些角色会默认收到需求关键变化提醒，例如需求创建人、被指定负责人、被要求补充信息的人或被明确加入关注的人。
- 业务规则：默认订阅应遵循最小必要原则；用户应能理解为什么收到提醒，并能在非强制通知场景下取消订阅或调整提醒。
- 边界场景：创建人离开 Space / 群、负责人变更、关注人失去权限、需求被合并或关闭时，应按当前权限和真实状态处理通知对象。
- 来源: modules/notify/card.go#L107-L121；来源: modules/notify/card.go#L122-L127；来源: internal/carddispatch/authorizer_db.go#L50-L60；来源: .octospec/rules/space-isolation.md#L21-L31

### F-01-3 状态变更通知
- 所属故事：US-01、US-03、US-04
- 需求描述：当需求单状态发生变化时，订阅者应收到包含需求编号、标题摘要、变更类型、当前状态和下一步动作的提醒。
- 业务规则：通知必须使用当前真实状态；不同终态或异常状态应明确区分，例如 accepted、blocked、duplicate、wontfix、invalid、未复现、已关闭、已重开等不得互相混用。
- 边界场景：状态短时间内多次变化、状态被回退、状态与评论口径冲突、需求关闭后重开、多个状态标签冲突时，应提示以当前可核验状态为准，并必要时提示产品运营负责人确认。
- 来源: modules/notify/model.go#L14-L23；来源: modules/notify/model.go#L112-L122；来源: modules/notify/card.go#L245-L256

### F-01-4 负责人变更通知
- 所属故事：US-03、US-04
- 需求描述：当需求负责人或处理责任人变化时，相关订阅者和新负责人应收到提醒，提醒中说明变更类型、当前责任人和下一步。
- 业务规则：通知对象应限于有权查看该需求的人；对外展示的负责人名称或身份信息不得超过接收人权限范围。
- 边界场景：负责人为空、负责人离开 Space、负责人被替换、多人协作、责任范围不清或变更被撤销时，应展示待确认或当前真实负责人状态。
- 来源: modules/notify/model.go#L14-L23；来源: internal/carddispatch/authorizer_db.go#L23-L36；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L41-L46

### F-01-5 待补充信息与验收提醒
- 所属故事：US-01、US-03、US-04
- 需求描述：当需求需要反馈人补充信息、确认范围、参与验收或查看结果时，系统应提醒对应用户并展示明确下一步动作。
- 业务规则：提醒内容应区分“需要补充”“等待 Review”“进入验收”“已完成待确认”等不同场景；不得把“进入验收”表达为“验收已通过”。
- 边界场景：被提醒人无权查看、补充入口失效、需求状态已变化、已经有人完成补充或验收时，应展示当前状态和可恢复操作。
- 来源: modules/bot_api/events.go#L37-L51；来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L160-L174；来源: modules/bot_api/send.go#L172-L176

### F-01-6 通知内容与跳转入口
- 所属故事：US-01、US-02、US-03
- 需求描述：通知应使用用户可读的内容展示需求单编号、标题摘要、变更类型、当前状态、操作者或责任人摘要、发生时间和下一步入口。
- 业务规则：通知内容只展示接收人有权查看的信息；跳转入口应指向接收人有权访问的需求详情、评论补充、验收或订阅管理位置。
- 边界场景：标题过长、内容含敏感信息、来源评论不可见、附件不可见或跳转目标失效时，应截断、脱敏或展示安全提示，而不是泄露完整内容。
- 来源: modules/notify/model.go#L14-L23；来源: internal/carddispatch/dispatch.go#L107-L120；来源: internal/carddispatch/dispatch.go#L124-L138；来源: internal/carddispatch/dispatch.go#L147-L155；来源: internal/carddispatch/dispatch.go#L178-L190；来源: internal/carddispatch/dispatch.go#L191-L199；来源: internal/carddispatch/dispatch.go#L202-L216；来源: internal/carddispatch/dispatch.go#L217-L219

### F-01-7 通知渠道与免打扰
- 所属故事：US-01、US-02、US-05
- 需求描述：用户应能理解提醒会发送到哪里，并能在非强制场景调整提醒强度或取消订阅。
- 业务规则：默认优先使用 Octo 内有权触达的私聊、群聊或 Thread 场景；高优先级、待补充、验收或负责人交接等关键节点可作为强提醒，但仍需遵守权限与免打扰边界。
- 边界场景：用户退群、关闭提醒、Bot 不可用、目标会话不可达、重复通知或短时间多次变化时，应展示可恢复提示或合并通知，避免刷屏。
- 来源: modules/notify/api.go#L51-L59；来源: modules/notify/card.go#L130-L135；来源: modules/bot_api/send.go#L172-L176

### F-01-8 权限与可见性边界
- 所属故事：US-02、US-05
- 需求描述：订阅入口、订阅状态、通知内容、跳转入口和取消订阅入口必须按接收人的当前权限展示。
- 业务规则：用户只能订阅和接收自己有权查看的需求；权限变化后，后续通知应按最新权限过滤；无权用户不能通过订阅状态、通知失败原因或缺失提示推断无权对象是否存在。
- 边界场景：跨 Space、跨群、跨 Thread、跨 Bot、非成员、退群、角色变化、需求迁移、来源对象删除或无权评论时，不展示具体对象详情。
- 来源: .octospec/rules/space-isolation.md#L21-L31；来源: .octospec/rules/space-isolation.md#L34-L37；来源: internal/carddispatch/authorizer_db.go#L115-L129；来源: internal/carddispatch/authorizer_db.go#L132-L146；来源: internal/carddispatch/authorizer_db.go#L147-L147；来源: internal/carddispatch/authorizer_db.go#L149-L163；来源: internal/carddispatch/authorizer_db.go#L165-L179；来源: internal/carddispatch/authorizer_db.go#L180-L180；来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L46-L50

### F-01-9 敏感信息脱敏
- 所属故事：US-05
- 需求描述：当需求标题、评论、附件摘要、变更原因或通知内容包含疑似敏感信息时，通知应展示脱敏摘要或提示人工确认。
- 业务规则：疑似 token、cookie、secret、私钥、生产凭证、客户隐私或内部敏感链接不得在群消息、公开评论、通知正文或审计摘要中明文复述。
- 边界场景：系统无法判断敏感级别、标题本身包含敏感内容、变更原因来自私密评论或附件不可见时，应优先安全降级，只提示存在敏感或不可见内容。
- 来源: modules/bot_api/ratelimit.go#L39-L48；来源: modules/messages_search/audit.go#L12-L24

### F-01-10 频率控制与重复提醒
- 所属故事：US-01、US-05
- 需求描述：订阅、取消订阅、状态变更提醒和批量提醒应具备用户可感知的频率、数量和重复通知边界。
- 业务规则：短时间内同一需求、同一订阅者、同一类型变化可合并或降噪；关键状态不得静默丢失；触发频率或数量限制时应说明原因和下一步。
- 边界场景：批量状态变更、大量订阅者、机器人重复触发、同一状态反复切换、通知目标超过上限或发送失败时，应避免刷屏并保留可追溯结果。
- 来源: modules/notify/api.go#L412-L426；来源: modules/notify/api.go#L433-L447；来源: modules/notify/card.go#L198-L207；来源: .octospec/rules/rate-limit.md#L19-L29

### F-01-11 通知结果与失败提示
- 所属故事：US-03、US-04、US-05
- 需求描述：系统应能区分已送达、因无权限被过滤、目标不可达、通知能力不可用、内容不合规或频率受限等结果，并对操作者或运营人员展示安全摘要。
- 业务规则：通知失败不得被误提示为已通知；部分成功时应展示送达和未送达摘要，但不泄露无权用户或无权对象详情。
- 边界场景：Bot 不可用、目标已退群、通知内容非法、卡片渲染失败、目标被拒绝、并发忙碌或网络异常时，应提供可恢复建议或转人工确认。
- 来源: modules/notify/model.go#L112-L122；来源: modules/notify/card.go#L220-L231；来源: modules/notify/card.go#L235-L243；来源: modules/notify/card.go#L245-L256；来源: internal/carddispatch/dispatch.go#L185-L199；来源: internal/carddispatch/dispatch.go#L202-L216；来源: internal/carddispatch/dispatch.go#L217-L219

### F-01-12 审计与追溯
- 所属故事：US-03、US-04、US-05
- 需求描述：订阅、取消订阅、通知触发、目标过滤、通知发送、失败原因和免打扰处理应有可追溯安全摘要。
- 业务规则：审计摘要应能说明操作者、需求单范围、变更类型、目标数量、送达/过滤结果和处理时间；不得记录明文敏感内容、完整私密正文或无权对象详情。
- 边界场景：重复通知、批量通知、权限变化、状态回退、多人同时订阅或取消时，应能追溯最终以哪个状态和订阅关系为准。
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L41-L46；来源: modules/messages_search/audit.go#L62-L70；来源: modules/notify/card.go#L245-L256

## 5. 状态与提示

- 未订阅：当前用户尚未订阅该需求，若有权可选择订阅。
- 已订阅：当前用户会收到该需求关键变化提醒。
- 已取消订阅：当前用户不再接收普通订阅提醒；若属于必须处理的责任场景，仍可能收到必要提醒。
- 无权订阅：当前用户无权查看或关注该需求，不展示需求详情。
- 订阅目标失效：需求不存在、已迁移、已删除、已关闭且不可再订阅，提示联系产品运营负责人确认。
- 状态已变更：需求状态发生变化，展示当前真实状态和下一步动作。
- 负责人已变更：需求负责人或处理责任人变化，展示当前责任人摘要和下一步。
- 需要补充信息：用户需要补充背景、复现、影响范围、验收反馈或其他材料。
- 进入验收：需求进入等待用户或负责人验收的阶段，不代表已经验收通过。
- 通知已送达：系统已向有权目标发送提醒。
- 部分送达：部分目标因无权、退群、免打扰、不可达或频控未收到提醒，展示安全摘要。
- 已合并提醒：短时间内多次变化被合并展示，避免重复刷屏。
- 疑似敏感内容：通知内容已脱敏或需人工确认后再展示。

## 6. 验收标准

- AC-01：当用户查看自己创建或有权关注的需求单时，能看到订阅、取消订阅和当前订阅状态。
- AC-02：当用户无权查看某需求时，不能通过订阅入口、订阅状态、通知失败原因或跳转入口推断该需求是否存在。
- AC-03：当需求状态发生变化时，有权订阅者能收到包含需求编号、标题摘要、变更类型、当前真实状态和下一步动作的提醒。
- AC-04：当需求负责人或处理责任人变化时，相关有权用户能收到负责人变更提醒，并看到当前责任人摘要和下一步。
- AC-05：当需求需要补充信息或进入验收时，对应反馈人或责任人能收到明确提醒，并能区分“待补充”“待验收”“验收已通过”等不同口径。
- AC-06：通知不得把 blocked、duplicate、wontfix、invalid、未复现、待补充、待验收误报为已完成或已验收。
- AC-07：通知内容只展示接收人有权查看的需求信息、评论摘要、附件状态和跳转入口；跨 Space / 跨群 / 跨 Thread / 跨 Bot 内容不泄露。
- AC-08：当订阅者退群、失去权限、目标会话不可达、Bot 不可用或发送失败时，系统不会误提示为已通知，并能提供安全失败摘要。
- AC-09：当短时间内同一需求发生多次变化时，系统能合并或降噪重复提醒，同时不静默丢失关键状态。
- AC-10：当通知内容包含疑似 token、cookie、secret、私钥、生产凭证、客户隐私或内部敏感链接时，通知和审计只展示脱敏摘要或人工确认提示。
- AC-11：当订阅、取消订阅、通知触发、目标过滤、发送失败或免打扰生效时，运营人员能看到可追溯安全摘要，用于排查和复盘。
- AC-12：产品说明覆盖订阅对象、默认订阅、取消订阅、触发事件、通知对象、通知渠道、免打扰、权限过滤、脱敏、限流、失败提示和审计口径。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/im`、`area/bot-agent`
- V5 only：未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及订阅关系、通知对象、状态真实性、跨 Space / 群 / Thread / Bot 可见性、敏感内容、限流和审计，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 首版自动订阅对象是否仅包含创建人、被要求补充信息的人、当前负责人，还是包含所有手动关注人和被 @ 的协作者。
2. [待确认] 首版通知渠道是否优先使用私聊，还是允许按需求来源群/Thread 发送群内提醒。
3. [待确认] 免打扰策略是否允许用户按需求单、状态类型或时间段配置。

## 9. 五类风险检查

- 多租户 / Space 隔离：订阅入口、订阅状态、通知内容、跳转入口和通知结果必须按当前接收人有权 Space / 群 / Thread / Bot 范围展示；无权对象不展示详情，也不泄露是否存在。
- 权限 / ownership：只有需求创建人、有权关注人、负责人或运营角色能按授权范围订阅、取消订阅或接收必要提醒；产品运营负责人负责最终状态和优先级裁定，需求管理专员不越权拍板。
- 安全 / 外部输入 / 凭证：需求标题、评论、附件摘要、变更原因和通知内容可能含敏感信息；疑似 token、cookie、secret、私钥或生产凭证必须脱敏或人工确认，不进入群消息、公开评论、通知正文或审计明文。
- 限流 / 防滥用：订阅、取消订阅、状态变化通知、批量通知和失败重试需要频率、数量和重复提醒边界，避免刷屏、枚举、通知风暴或 Bot 滥用。
- 审计 / 可追溯：关键动作需记录可追溯安全摘要，包括操作者、需求单范围、变更类型、目标数量、送达/过滤结果和处理时间；审计不得记录明文敏感内容、完整私密正文或无权对象详情。

## 10. What-only 自检摘要

- 技术 How：通过；PRD 仅定义用户可见能力、状态、提示、权限、风险和验收，未包含内部落地细节、数据结构、部署方案或代码实现。
- 引用核验：通过；引用均来自只读目标仓 `Mininglamp-OSS/octo-server`，需通过引用核验脚本检查。
- Label 完整性：通过；Issue #21 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/im`、`area/bot-agent`。
- 状态真实性：通过；Issue #21 当前远端为 open 且 `status/prd-drafting`，本 PRD 完成后应流转为唯一 `status/reviewing`，由产品运营负责人 Review。
- 风险提醒 / 待人工确认：有；重点是默认订阅对象、通知渠道、免打扰策略、状态真实性、跨 Space / 群 / Thread / Bot 可见性、敏感信息脱敏、限流和审计。
