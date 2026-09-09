# PRD 草稿：群聊 @ 触发链路诊断面板

## 1. 背景与问题

Issue #27 反馈：群聊中出现 Bot 没响应、误触发、重复触发或回复丢失时，运营需要分散查看消息、Bot 唤醒、Agent 会话和回复投递相关信息，定位成本高。该需求希望提供一个面向运营/排查人员的链路诊断面板，帮助判断问题发生在“消息可见、@ 解析、Bot 唤醒、运行会话、回复投递”中的哪一段。

现有源码显示，群消息发送链路会保留结构化 mention 语义，并在群场景中按 `mention.ais` 扩展 Bot 成员可见的 mention 信息。来源: modules/message/api.go#L715-L729；来源: modules/message/api.go#L752-L759；来源: modules/message/api.go#L761-L775

Bot 触发链路会从消息中的目标 Bot、结构化 mention、AI 广播或文本提及等信号中判断需要投递给哪些 Bot，并将消息交给 Bot 可消费的事件流转。来源: modules/robot/event.go#L264-L278；来源: modules/robot/event.go#L287-L300；来源: modules/robot/event.go#L301-L305；来源: modules/robot/event.go#L307-L315；来源: modules/robot/event.go#L316-L324；来源: modules/robot/event.go#L326-L340；来源: modules/robot/event.go#L341-L355；来源: modules/robot/event.go#L358-L372；来源: modules/robot/event.go#L373-L387；来源: modules/robot/event.go#L411-L425；来源: modules/robot/event.go#L427-L437；来源: modules/robot/event.go#L439-L453；来源: modules/robot/event.go#L454-L457

Bot 侧读取事件时，返回内容包含事件定位信息、消息定位信息、来源用户、会话标识和消息内容；AI Team 专属会话还会携带可定位的运行会话信息。来源: modules/bot_api/events.go#L38-L52；来源: modules/robot/event.go#L483-L497；来源: modules/robot/event.go#L528-L542；来源: modules/robot/event.go#L543-L557；来源: modules/robot/event.go#L558-L559

AI Team 会话入口要求启用能力、登录态、Space 上下文和限流；会话创建与读取受 Space、Bot ownership、成员状态和会话状态约束。来源: modules/ai_team/api.go#L31-L45；来源: modules/ai_team/api.go#L49-L60；来源: modules/ai_team/service.go#L37-L51；来源: pkg/aiteam/aiteam.go#L48-L62；来源: pkg/aiteam/aiteam.go#L63-L73

单条消息查询已有群/Thread 维度的成员校验和不可见归并口径，可作为诊断面板权限与防枚举口径的重要依据。来源: modules/message/api.go#L420-L430；来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169

## 2. 目标与非目标

### 目标

- 提供面向 Octo 产品运营负责人、需求管理/排障人员和授权研发的群聊 @ 触发链路诊断面板。
- 支持通过群、发送人、消息编号或可见会话定位信息检索一次群聊触发链路。
- 展示链路关键节点的可理解状态：消息是否可查、@ 是否命中、目标 Bot 是否可触达、Bot 是否被唤醒、运行会话是否创建/执行、回复是否完成投递。
- 将失败原因转译为运营可理解的口径，减少“没 @ 到、没触发、执行失败、回复发不出去”的反复沟通。
- 支持一键复制脱敏诊断摘要，供运营和研发协作排查。
- 明确多租户、群成员、Thread、Bot ownership、隐私脱敏、审计和限流边界，避免诊断面板成为跨群/跨 Space 查询或成员枚举入口。

### 非目标

- 不承诺展示内部日志全文、异常栈、底层记录、后台通道明细或敏感运行细节。
- 不允许未授权用户跨 Space、跨群、跨 Thread 查询消息、成员、Bot 或运行会话信息。
- 不替代正式监控告警、日志平台、全链路追踪系统或研发调试工具；首版聚焦运营可理解的链路定位。
- 不在面板或复制摘要中暴露 token、cookie、secret、私钥、生产凭证、完整敏感正文或无权成员详情。
- 不改变现有 @ 触发、Bot 事件读取、AI Team 会话创建或消息投递的产品语义。
- 不在 PRD 中定义具体实现路径、内部存储设计或部署方案。

## 3. 用户故事

### US-01：运营按消息定位一次群聊 @ 触发链路
- 角色：作为 Octo 产品运营负责人或授权运营人员
- 场景：当群里反馈“@ 了 Bot 但 Bot 没响应”或“重复触发”
- 诉求：希望按群、发送人或消息编号查到该消息从可见性到 Bot 唤醒的链路状态
- 价值：以便快速判断是消息不可见、@ 未命中、Bot 不可触达、运行失败还是回复投递异常
- 来源: modules/message/api.go#L420-L430；来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/robot/event.go#L264-L278；来源: modules/robot/event.go#L287-L300；来源: modules/robot/event.go#L301-L305；来源: modules/robot/event.go#L411-L425；来源: modules/robot/event.go#L427-L437；来源: modules/robot/event.go#L439-L453；来源: modules/robot/event.go#L454-L457

### US-02：运营理解 @ 解析与 Bot 命中结果
- 角色：作为 Octo 产品运营负责人或需求管理专员
- 场景：当一条消息包含结构化 mention、AI 广播或裸文本 @
- 诉求：希望面板明确展示哪些目标被识别为有效 Bot 触发对象，哪些只是普通文本或无效目标
- 价值：以便统一解释“看起来 @ 了”和“真实触发了”的差异
- 来源: modules/message/api.go#L715-L729；来源: modules/message/api.go#L752-L759；来源: modules/message/api.go#L761-L775；来源: modules/robot/event.go#L307-L315；来源: modules/robot/event.go#L316-L324；来源: modules/robot/event.go#L326-L340；来源: modules/robot/event.go#L341-L355；来源: modules/robot/event.go#L358-L372；来源: modules/robot/event.go#L373-L387

### US-03：运营查看运行会话和回复投递状态
- 角色：作为授权运营人员或排障研发
- 场景：当 Bot 已被唤醒但群内没有看到预期回复
- 诉求：希望看到可定位的运行会话、执行状态、最后失败原因和回复投递结果
- 价值：以便区分“Bot 没被唤醒”“运行中/失败”“回复被拒绝或不可见”
- 来源: modules/bot_api/events.go#L38-L52；来源: modules/robot/event.go#L483-L497；来源: modules/robot/event.go#L528-L542；来源: modules/robot/event.go#L543-L557；来源: modules/robot/event.go#L558-L559；来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L443-L446

### US-04：运营复制脱敏诊断摘要协作排查
- 角色：作为 Octo 产品运营负责人、需求管理专员或授权研发
- 场景：当需要把一次失败链路转交给研发或考试主考核验
- 诉求：希望一键复制包含关键状态、失败口径、时间和定位信息的脱敏摘要
- 价值：以便减少手工拼接截图、消息编号、运行状态和日志片段造成的信息遗漏
- 来源: modules/bot_api/events.go#L38-L52；来源: modules/message/api_message_get.go#L29-L43；来源: modules/message/api_message_get.go#L45-L59；来源: modules/message/api_message_get.go#L60-L61；来源: modules/message/api.go#L3526-L3540；来源: modules/message/api.go#L3553-L3562

### US-05：安全地限制诊断可见范围
- 角色：作为普通群成员、Bot 创建者或 Space 管理者
- 场景：当有人尝试查询自己无权访问的群、Thread、Bot 或会话链路
- 诉求：希望系统不泄露无权对象是否存在、成员名单、Bot 状态或敏感消息内容
- 价值：以便诊断能力提升排障效率的同时不破坏多租户和隐私边界
- 来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169；来源: modules/ai_team/service.go#L37-L51；来源: pkg/aiteam/aiteam.go#L48-L62；来源: pkg/aiteam/aiteam.go#L63-L73

## 4. 功能需求

### F-01-1 查询入口与检索范围
- 所属故事：US-01、US-03、US-05
- 需求描述：诊断面板应支持授权用户按群、发送人、消息编号和可见会话定位信息查询一次群聊 @ 触发链路。
- 业务规则：查询结果必须限定在查询人有权访问的 Space、群、Thread、Bot 和消息范围内；无权、不可见或不存在的对象应使用统一不可用口径，不暴露对象是否真实存在。
- 边界场景：消息被撤回、对查询人不可见、群已解散、Thread 已删除、Bot 已退群、Bot 被禁用、会话不可用时，面板应显示安全状态和可恢复建议。
- 来源: modules/message/api.go#L420-L430；来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169

### F-01-2 链路总览状态
- 所属故事：US-01、US-03
- 需求描述：面板应以一条链路视图展示关键节点状态，至少覆盖消息可查、@ 解析、Bot 命中、Bot 唤醒、运行会话、回复投递。
- 业务规则：每个节点应有运营可理解状态，例如：未开始、已命中、未命中、执行中、成功、失败、不可见、无权限、已过期、状态未知。
- 边界场景：链路部分信息缺失、后台状态延迟、运行仍在进行、或事件已过期时，应明确显示“状态未知/已过期/稍后重试”，不得伪装为成功。
- 来源: modules/robot/event.go#L264-L278；来源: modules/robot/event.go#L287-L300；来源: modules/robot/event.go#L301-L305；来源: modules/robot/event.go#L411-L425；来源: modules/robot/event.go#L427-L437；来源: modules/robot/event.go#L439-L453；来源: modules/robot/event.go#L454-L457；来源: modules/bot_api/events.go#L38-L52

### F-01-3 @ 解析与目标命中展示
- 所属故事：US-02、US-05
- 需求描述：面板应说明触发来源是结构化定向 @、AI 广播、普通文本 @、专属会话消息或其它可识别路径，并展示授权范围内的目标命中摘要。
- 业务规则：授权用户可看到“是否命中 Bot、命中数量、命中方式、被过滤原因摘要”；不得展示无权成员清单、跨 Space 对象详情或可用于枚举 Bot 的差异化错误。
- 边界场景：`mention.ais`、`mention.uids`、裸文本 @、目标重复、目标不存在、目标非 Bot、Bot 不在群、群成员读取失败时，应给出稳定、可解释且不泄露的原因口径。
- 来源: modules/message/api.go#L715-L729；来源: modules/message/api.go#L752-L759；来源: modules/message/api.go#L761-L775；来源: modules/robot/event.go#L307-L315；来源: modules/robot/event.go#L316-L324；来源: modules/robot/event.go#L326-L340；来源: modules/robot/event.go#L341-L355；来源: modules/robot/event.go#L358-L372；来源: modules/robot/event.go#L373-L387

### F-01-4 Bot 唤醒与事件可消费状态
- 所属故事：US-01、US-03
- 需求描述：面板应展示目标 Bot 是否收到可消费事件、事件是否仍可定位、是否已被消费或等待消费，以及失败/过期的可理解原因。
- 业务规则：展示给运营的是“Bot 可消费事件状态”和“最后可见状态”，不是内部流转明细或消费者实现细节。
- 边界场景：事件生成失败、事件已过期、Bot 长时间未读取、Bot 读取被限流或读取结果为空时，应提示可能原因和下一步排查方向。
- 来源: modules/robot/event.go#L528-L542；来源: modules/robot/event.go#L543-L557；来源: modules/robot/event.go#L558-L559；来源: modules/robot/event.go#L560-L574；来源: modules/bot_api/events.go#L54-L68；来源: modules/bot_api/events.go#L74-L88；来源: modules/bot_api/events.go#L89-L103；来源: modules/bot_api/events_wait.go#L385-L399；来源: modules/bot_api/events_wait.go#L400-L414；来源: modules/bot_api/events_wait.go#L415-L429

### F-01-5 运行会话诊断
- 所属故事：US-03、US-05
- 需求描述：当链路进入 Agent/AI Team 会话时，面板应展示可定位的运行会话摘要、会话状态、所属 Bot、所属 Space/群/Thread 的授权摘要和最后失败原因。
- 业务规则：会话定位信息应脱敏或最小化展示；只有有权访问该 Space、Bot 和会话的角色可查看。失败原因应面向运营表达，不展示内部异常栈、敏感上下文或凭证。
- 边界场景：会话未创建、创建中、就绪、失败、Thread 删除、Bot ownership 不匹配、Space 成员状态异常时，应分别给出清晰状态。
- 来源: modules/ai_team/api.go#L31-L45；来源: modules/ai_team/api.go#L49-L60；来源: modules/ai_team/model.go#L46-L60；来源: modules/ai_team/model.go#L61-L64；来源: modules/ai_team/service.go#L381-L395；来源: modules/ai_team/service.go#L396-L409

### F-01-6 回复投递诊断
- 所属故事：US-03
- 需求描述：面板应展示 Bot/Agent 回复是否已发出、是否投递到目标群或 Thread、是否被权限/成员/会话状态阻止，以及可见失败口径。
- 业务规则：回复投递成功只表示消息按产品规则完成投递或受理；若目标用户不可见、消息被撤回、会话不可访问，应如实展示为不可见或不可确认。
- 边界场景：Bot 不在群、群不存在或解散、Thread 无效、发送被拒绝、消息内容不合法、投递后用户侧不可见时，应给出可恢复提示。
- 来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L443-L446；来源: modules/bot_api/api_i18n.go#L123-L137；来源: modules/bot_api/api_i18n.go#L139-L153

### F-01-7 失败原因口径
- 所属故事：US-01、US-02、US-03、US-04
- 需求描述：面板应将失败原因归类为运营可理解的少量口径，并给出下一步建议。
- 业务规则：建议口径包括：消息不可查、查询人无权限、@ 未命中、目标 Bot 不可触达、Bot 未读取、运行会话未就绪、执行失败、回复投递失败、状态已过期、系统暂不可判定。
- 边界场景：同一链路出现多个失败点时，应展示最早阻断点和后续未发生节点；无法确认时标记“未知”，不得凭推测填充成功或失败。
- 来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/robot/event.go#L264-L278；来源: modules/robot/event.go#L287-L300；来源: modules/robot/event.go#L301-L305；来源: modules/bot_api/events.go#L88-L102；来源: modules/ai_team/service.go#L381-L395；来源: modules/ai_team/service.go#L396-L409

### F-01-8 一键复制脱敏诊断摘要
- 所属故事：US-04、US-05
- 需求描述：面板应提供一键复制诊断摘要，包含链路时间、查询范围、消息定位、命中摘要、关键节点状态、失败口径、下一步建议和脱敏追踪信息。
- 业务规则：复制内容不得包含 token、cookie、secret、私钥、生产凭证、完整敏感正文、无权成员清单或跨 Space 对象详情；长消息、撤回消息、不可见消息应只给摘要或占位。
- 边界场景：消息正文疑似包含凭证、个人隐私、客户敏感信息或不可见内容时，复制摘要应默认脱敏；用户不得通过复制功能绕过面板可见性限制。
- 来源: modules/message/api_message_get.go#L29-L43；来源: modules/message/api_message_get.go#L45-L59；来源: modules/message/api_message_get.go#L60-L61；来源: modules/message/api.go#L3526-L3540；来源: modules/message/api.go#L3553-L3562; 来源: modules/message/api.go#L3623-L3637；来源: modules/message/api.go#L3638-L3652；来源: modules/message/api.go#L3653-L3667；来源: modules/message/api.go#L3668-L3668

### F-01-9 权限、隐私与防枚举
- 所属故事：US-05
- 需求描述：诊断面板必须执行最小可见原则，只向有权角色展示其有权范围内的消息、Bot、会话和成员摘要。
- 业务规则：无权查询应使用统一提示；不得通过错误文案差异、命中数量、复制摘要或时间差暴露跨群、跨 Space、跨 Thread 的对象存在性。
- 边界场景：普通成员查询运营视图、Bot 创建者查询非自己 Bot、运营查询非授权 Space、外部用户猜测消息编号或群号时，应安全拒绝或展示最小化结果。
- 来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169；来源: modules/ai_team/service.go#L37-L51；来源: pkg/aiteam/aiteam.go#L48-L62；来源: pkg/aiteam/aiteam.go#L63-L73

### F-01-10 限流、审计与保留
- 所属故事：US-04、US-05
- 需求描述：诊断查询应有防滥用约束，并为授权排障保留可追溯记录。
- 业务规则：高频查询、批量猜测消息编号、跨范围探测或异常复制行为应被限制或降噪；审计记录应说明谁在何时查询了哪个授权范围和诊断结果摘要，但不得记录明文敏感信息。
- 边界场景：遇到系统不可用、查询依赖异常、疑似凭证输入或异常高频请求时，应优先保护隐私与系统稳定，并向运营展示安全失败口径。
- 来源: modules/ai_team/api.go#L31-L45；来源: modules/bot_task/api.go#L250-L264；来源: modules/message/api_message_get.go#L29-L43；来源: modules/message/api_message_get.go#L45-L59；来源: modules/message/api_message_get.go#L60-L61

## 5. 状态与提示

- 消息可查：查询人在授权范围内能定位到目标消息；不代表 Bot 已被唤醒。
- 消息不可见：消息不存在、已删除、已撤回、群/Thread 不可访问或查询人无权；提示应归并，避免枚举。
- @ 已命中：结构化 mention、AI 广播、专属会话或其它有效触发路径命中目标 Bot。
- @ 未命中：消息没有可触发 Bot 的有效目标，或目标不在授权/可触达范围内。
- Bot 已唤醒：目标 Bot 收到可消费事件或等价可见状态。
- Bot 未读取：事件仍等待 Bot 消费，或超过可观察窗口仍未被消费。
- 运行中：运行会话已进入处理过程，暂未产生最终回复。
- 运行失败：运行会话或执行过程失败，展示脱敏失败口径和建议下一步。
- 回复已投递：Bot/Agent 回复已按产品规则投递到目标群或 Thread。
- 回复不可见/不可确认：回复可能被权限、会话状态、消息可见性或系统异常阻断，需按提示继续排查。

## 6. 验收标准

- AC-01：当授权运营输入群、发送人或消息编号时，能够看到该消息的链路总览，并区分消息可查、@ 命中、Bot 唤醒、运行会话和回复投递状态。
- AC-02：当消息仅包含普通文本 @ 而没有有效触发语义时，面板显示“@ 未命中/普通文本”口径，不误导为 Bot 已被真实唤醒。
- AC-03：当消息通过结构化 mention 或 AI 广播命中 Bot 时，面板能展示授权范围内的目标命中摘要和命中方式。
- AC-04：当 Bot 已被唤醒但未回复时，面板能区分等待消费、运行中、运行失败、回复投递失败或状态未知，并给出运营可执行的下一步建议。
- AC-05：当链路进入 AI Team/Agent 会话时，授权用户能看到脱敏会话定位信息、会话状态和最后失败口径；无权用户不能查看或枚举该会话。
- AC-06：当用户查询无权 Space、群、Thread、Bot、成员或消息时，面板给出统一不可用提示，不泄露对象是否存在。
- AC-07：当复制诊断摘要时，内容包含定位所需的脱敏信息、关键节点状态、失败口径和下一步建议；不包含凭证、完整敏感正文或无权对象详情。
- AC-08：当发生高频查询、批量猜测或疑似滥用时，系统能限制或降噪，并保留脱敏审计摘要。
- AC-09：当后台链路状态缺失、过期或依赖异常时，面板如实显示“状态未知/已过期/稍后重试”，不得把未知状态显示为成功。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/im`、`area/bot-agent`
- V5 only：当前未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及跨群/跨 Space 诊断、成员可见性、Bot ownership、敏感信息脱敏、限流和审计，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 首版诊断入口面向哪些角色开放：仅产品运营负责人/授权研发，还是包含 Bot 创建者和群管理员的受限视图。
2. [待确认] 首版支持的查询键优先级：消息编号必做；群+时间/发送人、会话定位信息、回复消息反查是否进入首版。
3. [待确认] 诊断状态保留窗口与“已过期”展示口径，需要产品运营负责人结合运营排障时效确认。

## 9. 五类风险检查

- 多租户 / Space 隔离：诊断结果必须限制在查询人有权访问的 Space、群、Thread 和会话范围内；跨 Space 或跨群对象统一不可用，不展示存在性。
- 权限 / ownership：Bot、AI Team 会话和专属 Thread 信息只能向具备对应权限的角色展示；Bot 创建者不应越权查看其它 Bot 或其它 Space 的链路。
- 安全 / 外部输入 / 凭证：消息正文、错误原因、复制摘要和审计记录都可能包含外部输入；必须默认脱敏 token、cookie、secret、私钥、生产凭证和敏感正文。
- 限流 / 防滥用：按消息编号、群号或会话定位信息批量查询可能形成成员/消息/Bot 枚举，需要限制频率、归并错误和降噪。
- 审计 / 可追溯：诊断面板本身应可追溯查询人、查询范围、时间、结果摘要和复制动作；审计不得记录明文敏感信息或无权对象详情。

## 10. What-only 自检摘要

- 技术 How：通过。PRD 只定义运营可见能力、状态口径、权限边界、脱敏和验收；未定义内部存储设计、部署或实现方案。
- 引用核验：通过。源码引用覆盖消息读取权限、mention 处理、Bot 触发、事件读取、AI Team 会话、发送失败口径、限流与脱敏相关现有边界。
- Label 完整性：通过。Issue #27 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/im`、`area/bot-agent`；PRD 完成后建议唯一状态更新为 `status/reviewing`。
- 状态真实性：通过。当前为 PRD 草拟中；完成远端 PRD、issue 回填和群内交接后可进入 `status/reviewing`。
- 风险提醒 / 待人工确认：是。需产品运营负责人确认首版开放角色、查询键范围和诊断状态保留窗口。
