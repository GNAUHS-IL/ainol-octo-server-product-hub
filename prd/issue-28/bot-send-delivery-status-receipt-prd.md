# PRD 草稿：Bot 发送消息的真实触达状态回执

## 1. 背景与问题

Issue #28 反馈：Bot 调用发送能力后，当前调用方通常只能从返回结果判断请求已被受理并拿到消息定位信息，但运营侧仍难以确认消息是否真实触达到目标会话、失败是否来自权限/关系/群或 Thread 状态、以及 mention 提醒是否真实命中。该需求希望补充同步返回与后续查询的触达状态口径，减少“发送成功但群里看不到 / 没触发”的误判。

现有 Bot 发送入口包含目标会话、会话类型、发送流标识、代用户发送和消息内容等调用输入，并进行基础参数校验。来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L67；来源: modules/bot_api/send.go#L68-L71

发送链路在完成发送调用后，失败时返回 Bot API 发送失败；成功时直接返回发送结果。现有入口证据不足以说明成功结果已区分真实触达、部分失败或 mention 提醒成功。来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L443-L446

Bot 发送侧 mention 处理保持结构化 mention 透传，不会把普通文本或裸文本自动推断为真实提醒语义，因此“消息投递”和“提醒触达”需要明确区分。来源: modules/bot_api/send.go#L299-L313

现有权限检查已覆盖 App Bot 单聊限制、好友/会话发起、群存在/解散、Bot 是否在群内、Thread 形态和 Space 成员等失败来源；这些可转译为产品化失败原因，但不能泄露无权对象详情。来源: modules/bot_api/api_i18n.go#L123-L137；来源: modules/bot_api/send.go#L468-L482；来源: modules/bot_api/send.go#L484-L498；来源: modules/bot_api/send.go#L499-L500；来源: modules/bot_api/send.go#L503-L517；来源: modules/bot_api/send.go#L518-L532；来源: modules/bot_api/send.go#L533-L535；来源: modules/bot_api/send.go#L538-L552；来源: modules/bot_api/send.go#L553-L558；来源: modules/bot_api/send.go#L574-L587；来源: modules/bot_api/send.go#L588-L602；来源: modules/bot_api/send.go#L603-L617；来源: modules/bot_api/send.go#L618-L622

单条消息查询已存在群、Thread、单聊等读取形态，并包含群成员、Thread 状态、可见性和防枚举口径，可作为后续按消息定位查询状态的权限边界参考。来源: modules/message/api.go#L420-L430；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L471-L480；来源: modules/message/api.go#L482-L496；来源: modules/message/api.go#L497-L500；来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169；来源: modules/message/api_message_get.go#L29-L43；来源: modules/message/api_message_get.go#L45-L59；来源: modules/message/api_message_get.go#L60-L62

## 2. 目标与非目标

### 目标

- 明确 Bot 发送后的状态枚举和产品语义，区分请求受理、消息投递、部分失败、失败、状态未知和状态过期。
- 明确同步返回与后续查询的边界：同步返回只表达当下可确认的结果；后续查询用于补充延迟可确认的投递与提醒状态。
- 明确失败原因口径和排查建议，覆盖权限、非好友、会话未发起、Bot 非群成员、群不存在/解散、Thread 无效、mention 未解析、提醒未触达、状态过期等运营可理解场景。
- 明确“消息投递成功”与“mention 提醒成功”的区别，避免把可见消息误认为目标用户或 Bot 已收到提醒。
- 明确按消息定位查询触达状态时的权限、隐私、防枚举、限流和审计要求。
- 兼容 #26 的裸 bot_id @ 口径和 #27 的链路诊断面板口径，为后续诊断视图提供一致状态语言。

### 非目标

- 不承诺同步返回一定能给出最终触达结论；对于异步、延迟、不可观测或已过期状态，应允许展示未知或待确认。
- 不要求把普通文本 @ 自动转换为真实 mention；普通文本与结构化 mention 的语义继续区分。
- 不承诺展示内部日志全文、异常栈、底层运行细节或完整消息正文。
- 不允许通过触达状态查询跨 Space、跨群、跨 Thread、跨单聊枚举用户、Bot、好友关系或群成员关系。
- 不改变现有 Bot 发送、消息读取、mention 解析、Bot 事件消费或 Thread 能力本身的产品语义。
- 不在 PRD 中定义具体实现路径、内部存储设计或部署方案。

## 3. 用户故事

### US-01：Bot 调用方理解同步发送结果
- 角色：作为 Bot API 调用方
- 场景：当我调用 Bot 发送能力后
- 诉求：希望同步结果明确告诉我请求是已受理、已确认投递、失败还是暂不可确认，而不是只靠消息定位信息猜测真实触达
- 价值：以便我正确决定是否展示成功、重试、提示用户或转入后续查询
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L443-L446

### US-02：运营按消息定位查询后续触达状态
- 角色：作为 Octo 产品运营负责人或授权排障人员
- 场景：当用户反馈“接口成功但群里看不到 / 没触发”
- 诉求：希望通过消息定位信息查询后续投递状态、失败原因和排查建议
- 价值：以便减少在消息、权限和 Bot 触发链路之间反复确认
- 来源: modules/message/api.go#L420-L430；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L471-L480；来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126

### US-03：调用方区分消息投递和 mention 提醒
- 角色：作为 Bot API 调用方或群运营人员
- 场景：当 Bot 发送群聊、Thread 或包含 mention 的消息
- 诉求：希望知道消息是否投递成功，以及 mention 是否解析并触达目标提醒对象
- 价值：以便避免“消息发出”被误判为“@ 已提醒目标”
- 来源: modules/bot_api/send.go#L299-L313；来源: modules/robot/event.go#L307-L321；来源: modules/robot/event.go#L322-L324；来源: modules/robot/event.go#L326-L340；来源: modules/robot/event.go#L358-L372；来源: modules/robot/event.go#L373-L387；来源: modules/robot/event.go#L388-L389

### US-04：调用方获得可读失败原因和建议
- 角色：作为 Bot API 调用方、产品运营负责人或授权研发
- 场景：当发送或后续查询发现失败、部分失败或无法确认
- 诉求：希望失败原因稳定、可读、可行动，并给出下一步排查建议
- 价值：以便快速定位权限、关系、群/Thread 状态、mention 语义或系统暂不可判定的问题
- 来源: modules/bot_api/api_i18n.go#L123-L137；来源: modules/bot_api/api_i18n.go#L139-L153；来源: modules/bot_api/api_i18n.go#L156-L162

### US-05：安全地限制触达状态可见范围
- 角色：作为普通调用方、Bot 创建者、Space 管理者或外部集成方
- 场景：当有人尝试通过消息定位、失败原因或 mention 状态探测无权对象
- 诉求：希望系统只展示授权范围内的状态，不泄露好友关系、群成员、Thread、Bot 或 Space 对象是否存在
- 价值：以便新增回执能力不引入越权、枚举或隐私泄露风险
- 来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169；来源: modules/message/api_message_get.go#L29-L43；来源: modules/message/api_message_get.go#L45-L59；来源: modules/message/api_message_get.go#L60-L62；来源: modules/bot_api/authtree_guard.go#L17-L28；来源: modules/bot_api/authtree_guard.go#L42-L45

## 4. 功能需求

### F-01-1 同步返回状态枚举
- 所属故事：US-01、US-04
- 需求描述：Bot 发送同步返回应提供调用方可理解的基础状态，建议首版产品枚举包括：`accepted`、`delivered`、`failed`、`partial_failed`、`unknown`。
- 业务规则：`accepted` 表示请求已被受理但尚不能证明目标已可见；`delivered` 表示当前已能确认消息进入目标会话可见范围；`failed` 表示当前已确认不能完成投递；`partial_failed` 表示多目标或多提醒对象中存在部分成功、部分失败；`unknown` 表示当前无法安全确认。
- 边界场景：当发送结果只能证明请求已处理但不能证明最终可见时，不得展示为 `delivered`；当失败原因涉及无权对象时，应使用安全归并口径。
- 来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L443-L446；来源: modules/bot_api/api_i18n.go#L123-L137

### F-01-2 同步返回与后续查询边界
- 所属故事：US-01、US-02
- 需求描述：系统应明确同步返回和后续查询的职责：同步返回给出当下可确认状态；后续查询按消息定位补充延迟可确认的投递、可见性和提醒状态。
- 业务规则：同步返回不得承诺无法立即确认的最终触达；后续查询应支持按消息定位信息查询，并返回状态更新时间、当前状态、失败原因、排查建议和过期提示。
- 边界场景：消息定位信息缺失、消息不可见、查询人无权、状态仍在变化、状态已过期或依赖暂不可用时，应返回可理解且安全的结果。
- 来源: modules/bot_api/send.go#L436-L446；来源: modules/message/api.go#L420-L430；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L471-L480

### F-01-3 后续查询权限边界
- 所属故事：US-02、US-05
- 需求描述：后续查询必须限定在调用方有权访问的会话、消息、Bot 和 Space 范围内。
- 业务规则：Bot token 查询只能看到该 Bot 有权看到的消息与触达状态；用户或运营侧查询应遵循其绑定 Space、群成员、Thread 访问和消息可见性规则。
- 边界场景：无权、不可见、不存在、已删除、已撤回、跨 Space、跨群、跨 Thread、跨单聊时，应使用统一不可用或不可确认口径，不能通过差异化原因泄露对象存在性。
- 来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L471-L480；来源: modules/message/api.go#L482-L496；来源: modules/message/api.go#L497-L500；来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169

### F-01-4 失败原因口径
- 所属故事：US-04、US-05
- 需求描述：系统应提供稳定、可读、可行动且可脱敏的失败原因口径。
- 业务规则：建议首版原因包括：`not_friend`、`conversation_not_started`、`not_group_member`、`group_not_found_or_unavailable`、`group_disbanded`、`thread_invalid_or_unavailable`、`space_not_allowed`、`message_not_visible`、`mention_not_resolved`、`mention_not_delivered`、`delivery_unconfirmed`、`expired`、`system_unavailable`。
- 边界场景：对无权对象、跨范围对象或可能造成枚举的场景，应将原因归并为不可用/不可确认，不返回精确对象状态；系统异常不得暴露内部异常栈或敏感上下文。
- 来源: modules/bot_api/api_i18n.go#L123-L137；来源: modules/bot_api/api_i18n.go#L139-L153；来源: modules/bot_api/api_i18n.go#L156-L162；来源: modules/message/api_message_get.go#L158-L169

### F-01-5 消息投递状态与 mention 提醒状态分离
- 所属故事：US-03、US-04
- 需求描述：回执结果必须分开展示消息投递状态和 mention 提醒状态。
- 业务规则：消息投递成功只代表消息在授权目标会话中可见或已被受理；mention 提醒成功需要结构化 mention 或明确触发语义被解析并命中目标提醒对象。普通文本 @、裸 bot_id、无效目标或无权目标不得标记为提醒成功。
- 边界场景：消息投递成功但 mention 未解析、部分目标被提醒、部分目标不可见、AI 广播命中部分 Bot、Bot 已收到消息但未响应时，应分别展示投递状态、提醒状态和后续建议。
- 来源: modules/bot_api/send.go#L299-L313；来源: modules/robot/event.go#L307-L321；来源: modules/robot/event.go#L322-L324；来源: modules/robot/event.go#L326-L340；来源: modules/robot/event.go#L358-L372；来源: modules/robot/event.go#L373-L387；来源: modules/robot/event.go#L388-L389

### F-01-6 部分失败与多目标场景
- 所属故事：US-01、US-03、US-04
- 需求描述：当一次发送涉及多个可见对象、多个 mention 目标、AI 广播或代用户扩散场景时，系统应支持表达部分成功和部分失败。
- 业务规则：`partial_failed` 应说明成功范围摘要、失败范围摘要和可行动原因，但不得列出无权对象明细；调用方可据此决定是否重试、降级提示或进入诊断。
- 边界场景：一条消息本身投递成功但部分 mention 目标未提醒；代用户扩散中部分目标不可达；群内 Bot 已可见但某些提醒对象未触达时，应避免把整体状态简单标记为成功。
- 来源: modules/bot_api/obo_fanout.go#L543-L557；来源: modules/bot_api/obo_fanout.go#L557-L571；来源: modules/bot_api/obo_fanout.go#L652-L665；来源: modules/bot_api/obo_fanout.go#L724-L735

### F-01-7 状态过期与不可确认口径
- 所属故事：US-02、US-04
- 需求描述：后续查询应明确状态可查询窗口；超过窗口或状态依据不足时，展示“状态已过期/不可确认”。
- 业务规则：过期不等于失败；不可确认不等于成功。产品文案应提示调用方结合消息定位、诊断面板或运营排查继续确认。
- 边界场景：消息存在但状态依据过期、消息已撤回、目标会话已变化、Bot 长时间未读取、查询依赖暂不可用时，应优先返回安全的未知/过期口径。
- 来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L126；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169；来源: modules/message/api_message_get.go#L29-L43；来源: modules/message/api_message_get.go#L45-L59；来源: modules/message/api_message_get.go#L60-L62

### F-01-8 文档、兼容与迁移提示
- 所属故事：US-01、US-03、US-04
- 需求描述：Bot API 文档和运营口径应说明新旧返回理解差异、状态枚举含义、失败原因含义、查询入口和兼容策略。
- 业务规则：历史调用方仍可使用消息定位信息；新增状态不得让调用方误以为 `accepted` 就等于最终触达。文档需明确普通文本 @ 与真实 mention 提醒的区别。
- 边界场景：老客户端不识别新状态、只读取消息定位信息、或只关心发送请求是否被受理时，应保持可理解的兼容说明。
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L443-L446；来源: modules/bot_api/send.go#L299-L313

### F-01-9 防枚举、限流与滥用控制
- 所属故事：US-05
- 需求描述：触达状态查询和失败原因返回必须防止被用于枚举好友关系、群成员、Thread、Bot、Space 成员或消息存在性。
- 业务规则：高频查询、批量猜测消息定位信息、跨范围探测、异常失败重试应被限制或降噪；错误文案、状态枚举和响应时机不得提供可利用的差异信号。
- 边界场景：App Bot 查询非绑定 Space 对象、Bot token 查询非自身会话、外部集成批量猜测消息编号、短时间大量失败查询时，应安全拒绝或归并结果。
- 来源: modules/bot_api/authtree_guard.go#L17-L28；来源: modules/bot_api/authtree_guard.go#L42-L45；来源: modules/bot_api/ratelimit.go#L21-L35；来源: modules/bot_api/ratelimit.go#L45-L50

### F-01-10 审计与脱敏
- 所属故事：US-04、US-05
- 需求描述：系统应为触达状态查询、失败原因查看和敏感诊断信息复制保留脱敏审计摘要。
- 业务规则：审计摘要应能追溯调用方、目标范围、消息定位、查询时间、状态类别和失败原因类别；不得记录 token、cookie、secret、私钥、完整敏感正文、无权成员清单或无权对象详情。
- 边界场景：请求内容疑似含凭证、消息正文包含个人隐私、失败原因涉及跨 Space 对象或系统异常时，应默认最小化展示和记录。
- 来源: modules/bot_api/ratelimit.go#L45-L50；来源: modules/message/api_message_get.go#L29-L43；来源: modules/message/api_message_get.go#L45-L59；来源: modules/message/api_message_get.go#L60-L62；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455

## 5. 状态与提示

### 消息投递状态

- `accepted`：请求已受理或发送流程已开始，但尚不能证明目标会话最终可见。
- `delivered`：当前已能确认消息在授权目标会话中可见或完成投递。
- `failed`：当前已确认消息未能投递，且可给出安全失败原因。
- `partial_failed`：一次发送中的部分目标或部分相关动作成功，部分失败。
- `unknown`：当前无法安全确认成功或失败，需稍后查询或进入诊断。
- `expired`：超过状态可查窗口，结果不可确认。

### mention 提醒状态

- `not_requested`：本次消息没有真实 mention 触发诉求。
- `resolved`：结构化 mention 或明确触发语义已解析并命中授权范围内目标。
- `not_resolved`：mention 信息缺失、普通文本 @、目标无效、目标不可见或无法唯一确认。
- `delivered`：提醒已在授权范围内触达目标对象。
- `partial_failed`：部分 mention 目标触达，部分未触达或不可确认。
- `unknown`：当前无法确认提醒是否触达。

### 推荐提示口径

- 发送已受理：消息请求已处理，最终触达状态可稍后查询。
- 投递已确认：消息已在目标会话范围内可见。
- 投递失败：消息未能送达目标会话，请根据失败原因检查权限、关系、群/Thread 状态或重试。
- 提醒未解析：消息可能已发送，但没有形成真实 @ 提醒；请使用结构化 mention 或官方推荐方式。
- 状态已过期/不可确认：当前无法再确认真实触达，请结合消息定位或诊断面板继续排查。

## 6. 验收标准

- AC-01：当 Bot 调用发送能力后，调用方能看到基础触达状态，不再只能依赖消息定位信息判断成功。
- AC-02：当同步阶段只能确认请求受理时，系统显示 `accepted` 或 `unknown`，不误报为最终 `delivered`。
- AC-03：当后续查询按授权消息定位信息查询时，调用方能看到当前投递状态、状态更新时间、失败原因口径和排查建议。
- AC-04：当发送失败来自非好友、会话未发起、Bot 非群成员、群不可用、Thread 无效或 Space 不允许时，调用方能看到安全、可读且可行动的失败原因。
- AC-05：当消息投递成功但 mention 未解析或未提醒时，系统分开展示消息投递成功与 mention 提醒未成功，不混淆两者。
- AC-06：当一次发送涉及多个目标或多个提醒对象并出现部分失败时，系统展示 `partial_failed` 和脱敏摘要，不泄露无权对象详情。
- AC-07：当查询人无权访问目标 Space、群、Thread、单聊、Bot 或消息时，系统使用统一不可用/不可确认口径，不暴露对象是否存在。
- AC-08：当状态超过可查窗口或依据不足时，系统展示 `expired` 或 `unknown`，并说明不可确认不等于成功或失败。
- AC-09：当出现高频查询、批量猜测或异常失败重试时，系统能限制、降噪或安全拒绝，并保留脱敏审计摘要。
- AC-10：文档明确新状态枚举、同步返回与后续查询边界、失败原因含义、普通文本 @ 与真实 mention 的区别、兼容策略和安全限制。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/api-error`、`area/im`、`area/bot-agent`
- V5 only：当前未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及好友关系、群成员、Thread、Space、Bot 和消息存在性防枚举，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 首版状态可查询窗口是否与 #27 诊断面板保持 7 天一致。
2. [待确认] 首版后续查询入口面向哪些调用方开放：仅 Bot token 自查，还是同时开放给产品运营负责人/授权排障人员。
3. [待确认] `delivered` 的首版确认强度：以目标会话可见为准，还是需要等待客户端/目标对象读侧确认。

## 9. 五类风险检查

- 多租户 / Space 隔离：触达状态和失败原因必须限制在调用方有权访问的 Space、会话、消息和 Bot 范围内；跨 Space 对象统一不可用或不可确认。
- 权限 / ownership：Bot token 只能查询自身发送或自身可见范围内的状态；代用户发送、App Bot、用户 Bot 和运营查询必须遵循各自权限边界。
- 安全 / 外部输入 / 凭证：请求内容、消息正文、失败原因、排查建议和审计摘要不得包含 token、cookie、secret、私钥、生产凭证或完整敏感正文。
- 限流 / 防滥用：按消息定位信息批量查询状态可能造成消息、成员、好友关系、群/Thread 或 Bot 枚举，需要限流、降噪和统一失败口径。
- 审计 / 可追溯：发送状态查询、失败原因查看和诊断信息复制应可追溯调用方、时间、目标范围和结果类别；审计只记录脱敏摘要。

## 10. What-only 自检摘要

- 技术 How：通过。PRD 只定义调用方/运营可见状态、失败原因、查询边界、权限、脱敏、限流和验收；未定义内部实现方案。
- 引用核验：通过。源码引用覆盖 Bot 发送入口、同步返回、mention 透传、发送权限错误、消息读取权限、Bot 触发和防枚举/限流相关边界。
- Label 完整性：通过。Issue #28 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/api-error`、`area/im`、`area/bot-agent`；PRD 完成后建议唯一状态更新为 `status/reviewing`。
- 状态真实性：通过。当前为 PRD 草拟中；完成远端 PRD、issue 回填和群内交接后可进入 `status/reviewing`。
- 风险提醒 / 待人工确认：是。需产品运营负责人确认状态可查窗口、查询入口开放角色和 `delivered` 的首版确认强度。
