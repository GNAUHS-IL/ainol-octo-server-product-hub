# PRD 草稿：消息发送前的目标与权限预检

## 1. 背景与问题

Issue #29 反馈：Bot / Agent 在发送群消息、私信或 Thread 消息前，缺少一个面向调用方的发送前预检能力。运营和集成方经常要等到发送失败、疑似成功但群里不可见、或关键 @ 没有真实提醒后，才发现目标 ID、群成员关系、好友关系、Thread 状态或 mention 语义存在问题，排障成本高。

现有 Bot 发送入口包含目标会话、会话类型、发送流标识、代用户发送和消息内容等输入，并做基础参数校验；当前入口证据未显示已有独立的发送前预检模式。来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L67；来源: modules/bot_api/send.go#L68-L71

发送链路在构造发送请求后直接执行发送；失败时返回发送失败，成功时返回发送结果。该链路表达的是实际发送动作，不等同于调用方可提前获得“目标是否可达、权限是否满足、mention 是否可真实提醒”的产品化预检结果。来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L441-L446

现有发送权限检查已经覆盖 App Bot 单聊限制、好友/会话发起、Space 成员、群存在/解散、Bot 群成员、Thread 形态等失败来源；这些判断可以转译为发送前预检的产品化原因和建议，但需要避免泄露无权对象详情。来源: modules/bot_api/api_i18n.go#L123-L137；来源: modules/bot_api/send.go#L468-L482；来源: modules/bot_api/send.go#L484-L498；来源: modules/bot_api/send.go#L503-L517；来源: modules/bot_api/send.go#L518-L532；来源: modules/bot_api/send.go#L533-L535；来源: modules/bot_api/send.go#L538-L552；来源: modules/bot_api/send.go#L553-L558；来源: modules/bot_api/send.go#L574-L587；来源: modules/bot_api/send.go#L588-L602；来源: modules/bot_api/send.go#L603-L617；来源: modules/bot_api/send.go#L618-L622

Bot 发送侧的 mention 处理保持结构化 mention 透传，不会把普通文本或裸文本自动推断为真实提醒语义；机器人事件触发也读取结构化 mention 目标或明确的 AI 广播语义。因此发送前预检必须明确区分“消息可发送”和“mention 可真实提醒”。来源: modules/bot_api/send.go#L299-L313；来源: pkg/mentionrewrite/rewrite.go#L79-L87；来源: pkg/mentionrewrite/rewrite.go#L89-L103；来源: pkg/mentionrewrite/rewrite.go#L104-L105；来源: modules/robot/event.go#L307-L321；来源: modules/robot/event.go#L322-L324；来源: modules/robot/event.go#L326-L340；来源: modules/robot/event.go#L358-L372；来源: modules/robot/event.go#L373-L387；来源: modules/robot/event.go#L388-L389

现有卡片分发授权器已有目标授权判断，覆盖目标 Space 活跃性、单聊目标成员与好友关系、群状态、Bot 群成员或黑名单、Thread 解析与活跃状态等场景。这说明系统内已有部分目标可达性依据，但当前证据不能等同于已存在对外发送前预检能力。来源: internal/carddispatch/authorizer_db.go#L23-L37；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: internal/carddispatch/authorizer_db.go#L50-L64；来源: internal/carddispatch/authorizer_db.go#L65-L79；来源: internal/carddispatch/authorizer_db.go#L80-L80；来源: internal/carddispatch/authorizer_db.go#L82-L96；来源: internal/carddispatch/authorizer_db.go#L97-L111；来源: internal/carddispatch/authorizer_db.go#L112-L112；来源: internal/carddispatch/authorizer_db.go#L115-L129；来源: internal/carddispatch/authorizer_db.go#L130-L144；来源: internal/carddispatch/authorizer_db.go#L145-L159；来源: internal/carddispatch/authorizer_db.go#L160-L163；来源: internal/carddispatch/authorizer_db.go#L165-L179；来源: internal/carddispatch/authorizer_db.go#L180-L180

## 2. 目标与非目标

### 目标

- 为 Bot / Agent 调用方提供发送前预检能力，使其在正式发送前能判断目标会话是否可达、发送权限是否满足、Thread 是否可用、mention 是否可能形成真实提醒。
- 对群聊、私聊、Thread 三类目标分别给出调用方可理解的预检状态、失败原因和修复建议。
- 明确 mention 预检口径：可真实提醒、仅普通文本展示、目标不存在或不可见、无权限确认、部分可提醒或当前不可确认。
- 明确发送前预检与发送后触达回执的边界：预检用于正式发送前降低失败概率；回执用于发送后确认实际投递和提醒结果。预检通过不保证发送时一定成功。
- 衔接 #26 的 mention 语义：裸 bot_id / 普通文本 @ 不等于真实 mention，预检应提前发现并提示修正。
- 衔接 #28 的发送后回执语义：发送前预检结果不得替代发送后的真实投递状态、提醒状态和后续查询结论。
- 明确权限、隐私、防枚举、限流、审计和脱敏要求，避免预检能力成为探测好友关系、群成员、Thread、Bot 或 Space 对象的通道。

### 非目标

- 不承诺预检通过后实际发送一定成功；发送时目标状态、权限关系、限流或系统状态可能变化，最终仍以发送动作和发送后回执为准。
- 不要求把裸 bot_id 或普通文本 @ 自动转换为真实 mention；自动转换如需支持，应由 #26 或后续需求单独裁定。
- 不把发送后投递状态、客户端已读、端侧通知到达、Bot 是否响应等能力纳入本单验收；这些属于 #28 或诊断类能力范围。
- 不向无权调用方暴露具体用户、Bot、群成员、好友关系、Thread 或 Space 对象是否存在。
- 不展示内部日志全文、异常栈、底层运行细节、完整消息正文或敏感凭证。
- 不在本 PRD 中冻结具体接口字段、内部数据结构、数据库、缓存、队列、SQL、部署或代码实现方案。

## 3. 用户故事

### US-01：Bot / Agent 调用方在发送前确认目标可达
- 角色：作为 Bot / Agent 调用方
- 场景：当我准备向群聊、私聊或 Thread 发送消息
- 诉求：希望在正式发送前知道目标是否可达、当前身份是否具备发送条件，以及如果不可发送应如何修复
- 价值：以便减少无效发送、盲目重试和“接口成功但用户没看到”的误判
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L67；来源: modules/bot_api/send.go#L68-L71；来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L441-L446；来源: modules/bot_api/send.go#L468-L482；来源: modules/bot_api/send.go#L503-L517；来源: modules/bot_api/send.go#L518-L532；来源: modules/bot_api/send.go#L533-L535；来源: modules/bot_api/send.go#L538-L552；来源: modules/bot_api/send.go#L553-L558；来源: modules/bot_api/send.go#L588-L602；来源: modules/bot_api/send.go#L603-L617；来源: modules/bot_api/send.go#L618-L622

### US-02：运营人员提前定位权限和成员关系问题
- 角色：作为 Octo 产品运营负责人或授权排障人员
- 场景：当调用方准备发送任务分派、告警、审批或协作消息，但目标可能填错或 Bot 未入群
- 诉求：希望预检结果能说明当前失败属于目标不可达、权限不足、关系未建立、群/Thread 不可用、或系统当前不可确认
- 价值：以便在发送前给出可执行修复建议，降低排障沟通成本
- 来源: modules/bot_api/api_i18n.go#L123-L137；来源: modules/bot_api/api_i18n.go#L139-L153；来源: modules/bot_api/api_i18n.go#L154-L162；来源: internal/carddispatch/authorizer_db.go#L23-L37；来源: internal/carddispatch/authorizer_db.go#L38-L47；来源: internal/carddispatch/authorizer_db.go#L115-L129；来源: internal/carddispatch/authorizer_db.go#L130-L144；来源: internal/carddispatch/authorizer_db.go#L145-L159；来源: internal/carddispatch/authorizer_db.go#L160-L163；来源: internal/carddispatch/authorizer_db.go#L165-L179；来源: internal/carddispatch/authorizer_db.go#L180-L180

### US-03：调用方在发送前确认 mention 是否会真实提醒
- 角色：作为 Bot API 调用方或群运营人员
- 场景：当消息中包含结构化 mention、AI 广播、用户提醒或看起来像 @ 的普通文本
- 诉求：希望预检能提前区分“可真实提醒”“仅文本展示”“目标不可解析/不可见”“部分可提醒”
- 价值：以便在正式发送前修正 mention 结构，避免关键人员或 Bot 未被真实提醒
- 来源: modules/bot_api/send.go#L299-L313；来源: pkg/mentionrewrite/rewrite.go#L79-L87；来源: pkg/mentionrewrite/rewrite.go#L89-L103；来源: pkg/mentionrewrite/rewrite.go#L104-L105；来源: modules/robot/event.go#L307-L321；来源: modules/robot/event.go#L322-L324；来源: modules/robot/event.go#L326-L340；来源: modules/robot/event.go#L358-L372；来源: modules/robot/event.go#L373-L387；来源: modules/robot/event.go#L388-L389

### US-04：调用方理解预检和发送后回执的区别
- 角色：作为 Bot / Agent 调用方
- 场景：当预检通过后我继续执行正式发送，或预检失败后我修正目标再发送
- 诉求：希望系统明确告诉我预检只是发送前判断，不能替代发送后的投递状态和提醒状态
- 价值：以便我不会把“可以尝试发送”误解为“已经送达”或“@ 已提醒成功”
- 来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L441-L446；来源: modules/message/api.go#L420-L430；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L471-L480；来源: modules/message/api.go#L482-L496；来源: modules/message/api.go#L497-L500

### US-05：无权、跨范围和高频探测被安全处理
- 角色：作为普通调用方、Bot 创建者、Space 管理者或外部集成方
- 场景：当有人用预检能力批量猜测用户 ID、群 ID、Thread、Bot 或成员关系
- 诉求：希望系统只返回授权范围内的可行动信息，对无权对象使用安全归并口径，并对高频探测进行限制和审计
- 价值：以便新增预检能力不引入越权、枚举、骚扰或隐私泄露风险
- 来源: modules/bot_api/authtree_guard.go#L17-L28；来源: modules/bot_api/authtree_guard.go#L42-L45；来源: modules/bot_api/ratelimit.go#L21-L35；来源: modules/bot_api/ratelimit.go#L45-L50；来源: internal/carddispatch/authorizer_db.go#L30-L44；来源: internal/carddispatch/authorizer_db.go#L45-L47

## 4. 功能需求

### F-01-1 发送前预检入口与模式
- 所属故事：US-01、US-04
- 需求描述：系统应提供面向 Bot / Agent 调用方的发送前预检能力，使调用方能在不产生正式消息的前提下获得目标、权限、Thread 和 mention 的可发送性判断。
- 业务规则：预检输入应与正式发送所需的目标、会话类型和消息内容保持语义一致；预检结果应明确这是“发送前判断”，不代表已发送、已投递或已提醒。
- 边界场景：当目标信息缺失、会话类型缺失、消息内容为空、格式不符合要求或预检本身不可执行时，调用方应看到明确的输入修正提示。
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L67；来源: modules/bot_api/send.go#L68-L71；来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L441-L446

### F-01-2 目标可达性预检
- 所属故事：US-01、US-02
- 需求描述：预检应判断目标会话是否处于调用方当前身份可尝试发送的范围内，并给出可读结论。
- 业务规则：群聊应关注群是否可用、Bot 是否具备当前群发送条件；私聊应关注是否具备可发起或继续会话的关系；Thread 应关注目标形态、父群和 Thread 当前可用性；App Bot 与用户 Bot 应按各自能力边界展示结果。
- 边界场景：目标不存在、群已解散、Bot 不在群、私聊关系未建立、对端不在绑定 Space、Thread 形态错误、父群不可用或目标状态无法确认时，应返回安全、可修复的结论。
- 来源: modules/bot_api/send.go#L468-L482；来源: modules/bot_api/send.go#L484-L498；来源: modules/bot_api/send.go#L503-L517；来源: modules/bot_api/send.go#L518-L532；来源: modules/bot_api/send.go#L533-L535；来源: modules/bot_api/send.go#L538-L552；来源: modules/bot_api/send.go#L553-L558；来源: modules/bot_api/send.go#L574-L587；来源: modules/bot_api/send.go#L588-L602；来源: modules/bot_api/send.go#L603-L617；来源: modules/bot_api/send.go#L618-L622；来源: internal/carddispatch/authorizer_db.go#L115-L129；来源: internal/carddispatch/authorizer_db.go#L130-L144；来源: internal/carddispatch/authorizer_db.go#L145-L159；来源: internal/carddispatch/authorizer_db.go#L160-L163；来源: internal/carddispatch/authorizer_db.go#L165-L179；来源: internal/carddispatch/authorizer_db.go#L180-L180

### F-01-3 权限与身份预检
- 所属故事：US-01、US-02、US-05
- 需求描述：预检应根据调用身份说明当前是否允许尝试发送，并在不泄露无权对象详情的前提下给出原因分类。
- 业务规则：App Bot、用户 Bot、代用户发送或授权排障身份应按各自产品边界获得不同可见范围；无权、跨 Space、跨群、跨 Thread 或关系不可见时，应使用归并原因和通用修复建议。
- 边界场景：代用户权限变化、成员退出 Space、好友关系变化、Bot 被移出群或加入黑名单、授权关系撤销、身份上下文异常时，预检应保守失败或标记不可确认。
- 来源: modules/bot_api/send.go#L160-L174；来源: modules/bot_api/send.go#L175-L176；来源: modules/bot_api/send.go#L180-L187；来源: modules/bot_api/obo_check.go#L29-L43；来源: modules/bot_api/obo_check.go#L44-L58；来源: modules/bot_api/obo_check.go#L59-L67；来源: modules/bot_api/obo_check.go#L188-L202；来源: modules/bot_api/obo_check.go#L203-L211；来源: internal/carddispatch/authorizer_db.go#L50-L64；来源: internal/carddispatch/authorizer_db.go#L65-L79；来源: internal/carddispatch/authorizer_db.go#L80-L80；来源: internal/carddispatch/authorizer_db.go#L82-L96；来源: internal/carddispatch/authorizer_db.go#L97-L111；来源: internal/carddispatch/authorizer_db.go#L112-L112

### F-01-4 Thread 预检口径
- 所属故事：US-01、US-02
- 需求描述：预检应对 Thread 目标单独给出可理解结果，明确 Thread 形态错误、Thread 不可用、父群不可用、Bot 不具备父群发送条件等场景。
- 业务规则：Thread 预检不得只返回笼统失败；但当精确原因可能泄露无权对象存在性时，应归并为“目标不可用或无权确认”。
- 边界场景：Thread ID 格式错误、Thread 已删除或不可用、父群已解散、调用方不在父群可达范围、Thread 能读但不能发或状态刚变化时，应给出保守且可恢复的结果。
- 来源: modules/bot_api/send.go#L538-L552；来源: modules/bot_api/send.go#L553-L558；来源: modules/bot_api/send.go#L574-L587；来源: internal/carddispatch/authorizer_db.go#L165-L179；来源: internal/carddispatch/authorizer_db.go#L180-L180；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169

### F-01-5 mention 解析与提醒预检
- 所属故事：US-03、US-04
- 需求描述：预检应独立返回 mention 相关结论，区分消息本身可发送与 mention 是否可真实提醒。
- 业务规则：结构化 mention、定向成员、AI 广播、人类广播和普通文本 @ 应使用一致产品语言说明；普通文本 @、裸 bot_id、无效目标、不可见目标或无法唯一确认目标不得被标记为真实提醒可达。
- 边界场景：无 mention、仅普通文本 @、结构化 mention 为空、目标重复、部分目标不可达、目标不在当前群、跨 Space 目标、Thread 内目标与父群成员关系不一致、广播目标过多时，应分别给出无提醒、仅文本、部分可提醒或不可确认结果。
- 来源: modules/bot_api/send.go#L299-L313；来源: pkg/mentionrewrite/rewrite.go#L38-L39；来源: pkg/mentionrewrite/rewrite.go#L79-L87；来源: pkg/mentionrewrite/rewrite.go#L89-L103；来源: pkg/mentionrewrite/rewrite.go#L104-L105；来源: modules/robot/event.go#L307-L321；来源: modules/robot/event.go#L322-L324；来源: modules/robot/event.go#L326-L340；来源: modules/robot/event.go#L358-L372；来源: modules/robot/event.go#L373-L387；来源: modules/robot/event.go#L388-L389

### F-01-6 预检结果状态与修复建议
- 所属故事：US-01、US-02、US-03
- 需求描述：预检结果应包含调用方可理解的总体结论、目标结论、权限结论、mention 结论、风险提示和下一步建议。
- 业务规则：建议产品语义覆盖：可尝试发送、不可发送、部分可提醒、仅文本展示、无权确认、当前不可确认、输入需修正、系统暂不可用。每个失败或不可确认结论都应尽量给出可执行建议，例如检查目标 ID、邀请 Bot 入群、确认好友关系、修正 Thread、改用结构化 mention、减少批量目标或稍后重试。
- 边界场景：当多个问题同时存在时，应按对调用方最可行动、最安全的顺序展示；涉及无权对象时不列明具体对象清单；系统异常时不展示内部细节。
- 来源: modules/bot_api/api_i18n.go#L123-L137；来源: modules/bot_api/api_i18n.go#L139-L153；来源: modules/bot_api/api_i18n.go#L154-L162；来源: modules/bot_api/send.go#L468-L482；来源: modules/bot_api/send.go#L503-L517；来源: modules/bot_api/send.go#L518-L532；来源: modules/bot_api/send.go#L533-L535；来源: modules/bot_api/send.go#L538-L552；来源: modules/bot_api/send.go#L553-L558；来源: modules/bot_api/send.go#L588-L602；来源: modules/bot_api/send.go#L603-L617；来源: modules/bot_api/send.go#L618-L622

### F-01-7 与发送后回执的衔接
- 所属故事：US-04
- 需求描述：预检结果应明确提示后续正式发送仍需参考发送结果和发送后触达回执；预检通过只表示当前条件下可以尝试发送。
- 业务规则：预检不得生成真实消息，不得产生被提醒对象的通知，不得被运营解释为消息已送达；正式发送后的投递、提醒、部分失败、未知或过期状态应由 #28 口径承接。
- 边界场景：预检通过后目标群解散、Bot 被移出群、好友关系解除、Thread 状态变化、消息内容变化、限流触发或系统暂不可用时，正式发送或回执结果可以不同于预检结果。
- 来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L441-L446；来源: modules/message/api.go#L420-L430；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L471-L480；来源: modules/message/api.go#L482-L496；来源: modules/message/api.go#L497-L500

### F-01-8 文档、兼容与迁移提示
- 所属故事：US-01、US-03、US-04
- 需求描述：Bot API 文档、SDK 示例或运营说明应补充发送前预检、普通文本 @ 与真实 mention、预检与回执区别、以及常见修复建议。
- 业务规则：文档应避免把预检说成发送成功；应明确裸 bot_id / 普通文本 @ 不能被承诺为真实提醒；应提示调用方使用官方结构化 mention 或推荐成员实体方式。
- 边界场景：老调用方不使用预检、只使用正式发送、只把 @ 当普通文本展示、或尚未接入发送后回执时，应有清晰兼容说明，不强制误伤。
- 来源: modules/bot_api/send.go#L299-L313；来源: pkg/mentionrewrite/rewrite.go#L23-L37；来源: pkg/mentionrewrite/rewrite.go#L38-L39；来源: pkg/mentionrewrite/rewrite.go#L89-L103；来源: pkg/mentionrewrite/rewrite.go#L104-L105；来源: modules/bot_api/send.go#L426-L440；来源: modules/bot_api/send.go#L441-L446

### F-01-9 防枚举、限流与滥用控制
- 所属故事：US-05
- 需求描述：预检能力必须防止被用于高频探测目标、枚举成员关系或批量验证 Bot / Thread / Space 对象存在性。
- 业务规则：对高频预检、批量目标、连续失败、跨范围探测和异常来源应具备降噪、限制或安全拒绝口径；提示文案、原因粒度和响应差异不得向无权调用方泄露可利用信号。
- 边界场景：大量猜测用户 ID / 群 ID / Thread ID / bot_id、反复验证好友关系、扫描群成员、批量探测 Space 归属或失败重试风暴时，应返回安全归并结果并保留脱敏审计摘要。
- 来源: modules/bot_api/authtree_guard.go#L17-L28；来源: modules/bot_api/authtree_guard.go#L42-L45；来源: modules/bot_api/ratelimit.go#L21-L35；来源: modules/bot_api/ratelimit.go#L45-L50

### F-01-10 审计与脱敏
- 所属故事：US-02、US-05
- 需求描述：系统应为预检调用、失败原因查看、敏感目标判断和高频异常保留可追溯但脱敏的审计摘要。
- 业务规则：审计摘要应能支持运营排障和安全追溯，覆盖调用方、目标类型、时间、结论类别和失败原因类别；不得记录 token、cookie、secret、私钥、完整敏感正文、无权成员清单或无权对象详情。
- 边界场景：请求内容疑似包含凭证、消息正文包含隐私、预检目标跨 Space、系统异常或被限流时，应默认最小化展示和记录。
- 来源: modules/bot_api/ratelimit.go#L45-L50；来源: modules/message/api_message_get.go#L29-L43；来源: modules/message/api_message_get.go#L45-L59；来源: modules/message/api_message_get.go#L60-L62；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L471-L480

## 5. 状态与提示

### 发送前总体结论

- 可尝试发送：当前输入、目标和身份条件下，系统未发现阻断正式发送的问题；仍需以正式发送结果和发送后回执为准。
- 不可发送：当前条件下已发现明确阻断因素，调用方应按建议修正后再发送。
- 部分可发送 / 部分可提醒：目标或 mention 中只有部分对象当前可确认，调用方应查看脱敏摘要并决定是否调整。
- 当前不可确认：系统无法安全判断或依赖暂不可用；调用方可稍后重试或联系授权排障人员。
- 输入需修正：目标、会话类型、Thread 形态、消息内容或 mention 信息不完整/不符合产品规则。

### 目标与权限提示

- 目标可达：目标会话在当前身份可尝试发送范围内。
- 目标不可用或无权确认：目标不存在、不可见、已不可用、跨范围或无权限确认；不暴露具体对象详情。
- Bot 不具备目标会话发送条件：请确认 Bot 类型、入群状态、会话发起关系、Space 范围或授权关系。
- Thread 不可用：请确认 Thread 定位、父群状态和当前身份是否仍可访问。

### mention 提示

- 可真实提醒：mention 目标在授权范围内可解析，且符合真实提醒语义。
- 仅文本展示：正文看起来像 @，但未形成真实 mention；如需提醒请使用结构化 mention 或官方推荐方式。
- mention 不可解析：目标缺失、格式不符合规则、无法唯一确认或不在当前会话可提醒范围内。
- mention 无权确认：当前身份无权确认该对象是否存在或是否可提醒。
- mention 部分可提醒：部分目标可提醒，部分目标不可达或不可确认；仅展示授权范围内的脱敏摘要。

### 与发送后回执的提示

- 预检通过不代表消息已发送。
- 预检通过不代表消息一定会最终投递。
- 预检通过不代表 mention 已真实提醒。
- 正式发送后的投递状态、提醒状态、失败原因和过期口径，以发送后回执或后续查询为准。

## 6. 验收标准

- AC-01：当 Bot / Agent 调用方对群聊、私聊或 Thread 目标执行发送前预检时，能看到是否可尝试发送、不可发送或当前不可确认的清晰结论。
- AC-02：当目标群 ID / 用户 ID / Thread 定位错误、目标不可用、Bot 不在群、私聊关系未建立或 Space 范围不满足时，调用方能看到安全、可理解、可行动的失败原因和修复建议。
- AC-03：当消息包含结构化 mention、AI 广播、人类广播、裸 bot_id 或普通文本 @ 时，预检能分开展示消息可发送性与 mention 可提醒性，不把普通文本 @ 标记为真实提醒。
- AC-04：当部分 mention 目标可提醒、部分不可提醒或不可确认时，调用方能看到部分成功/失败的脱敏摘要，不暴露无权对象详情。
- AC-05：当预检通过后，系统提示该结果只代表当前可尝试发送；正式发送后仍需以发送结果和发送后回执为准。
- AC-06：当调用方无权访问目标 Space、群、Thread、单聊、Bot 或成员信息时，预检使用统一不可用/不可确认口径，不能通过原因差异枚举对象存在性或成员关系。
- AC-07：当出现高频预检、批量猜测、连续失败或异常重试时，系统能按产品规则限制、降噪或安全拒绝，并保留脱敏审计摘要。
- AC-08：当预检依赖暂不可用或目标状态可能在发送前后变化时，系统能展示不可确认或需再次确认的提示，不把未知结果误报为成功。
- AC-09：文档或示例明确预检使用场景、常见失败原因、修复建议、普通文本 @ 与真实 mention 的区别，以及预检与发送后回执的边界。
- AC-10：预检过程和展示结果不得泄露 token、cookie、secret、私钥、生产凭证、完整敏感正文、无权成员清单或无权对象详情。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/api-error`、`area/im`、`area/bot-agent`
- V5 only：当前未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及目标可达性、好友/成员/Thread/Space/Bot 存在性、防枚举、限流和审计，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 首版产品形态采用独立发送前预检入口，还是在正式发送能力中提供预检模式；PRD 当前只固定用户可见能力和边界，不冻结具体接口形态。
2. [待确认] 首版开放角色：仅 Bot / Agent 调用方自查自身发送，还是同时开放给产品运营负责人、授权排障人员或授权研发。
3. [待确认] 预检结果的原因粒度：哪些场景可返回精确修复建议，哪些场景必须归并为“目标不可用或无权确认”以防枚举。

## 9. 五类风险检查

- 多租户 / Space 隔离：预检结果必须限制在调用方有权访问的 Space、会话、目标和 Bot 范围内；跨 Space、跨群、跨 Thread 或跨单聊对象统一使用不可用/不可确认口径。
- 权限 / ownership：调用方只能预检自身身份有权尝试发送的目标；App Bot、用户 Bot、代用户发送、运营排障身份必须遵循各自产品权限边界。
- 安全 / 外部输入 / 凭证：预检输入可能包含正文、mention、目标标识或外部系统传入内容；提示、日志、审计和 issue 评论不得包含 token、cookie、secret、私钥、生产凭证或完整敏感正文。
- 限流 / 防滥用：预检天然适合被用来批量验证对象是否存在；必须对高频、批量、连续失败和跨范围探测做限制、降噪和安全归并。
- 审计 / 可追溯：预检调用、失败原因查看、异常探测和被限流事件应可追溯调用方、时间、目标类型、结论类别和失败原因类别；审计只记录脱敏摘要。

## 10. What-only 自检摘要

- 技术 How：通过。PRD 只定义调用方/运营可见的预检能力、状态口径、失败原因、修复建议、与 #26/#28 的边界、安全限制和验收；未定义数据库、缓存、队列、SQL、代码、内部实现路径或具体接口字段。
- 引用核验：通过。源码引用覆盖 Bot 发送入口、实际发送链路、发送权限检查、Thread 形态、mention pass-through、机器人事件触发、消息读取权限边界、卡片分发授权判断、防枚举和限流相关边界。
- Label 完整性：通过。Issue #29 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/api-error`、`area/im`、`area/bot-agent`；PRD 完成后建议唯一状态更新为 `status/reviewing`。
- 状态真实性：通过。当前为 PRD 草拟中；完成远端 PRD、issue 回填和群内交接后可进入 `status/reviewing`。
- 风险提醒 / 待人工确认：是。需产品运营负责人确认首版产品形态、开放角色和失败原因粒度，尤其是防枚举归并策略。
