# PRD 草稿：Bot 发送接口明确处理裸 bot_id @ 的非真实 mention 行为

## 1. 背景与问题

Issue #26 反馈：Bot 调用发送接口在群内主动发消息时，如果正文中写入裸 bot_id 形式的 `@xxx_bot`，发送可以成功并返回消息编号，但目标 Bot 不一定收到真实 @ 提醒；只有使用结构化 mention 或正确成员实体时才会触发真实提醒。该现象容易让调用方把“消息发送成功”误解为“@ 提醒已触发”，造成协作遗漏。

当前源码证据显示，Bot 发送入口校验的是会话、会话类型和消息内容等基础条件；后续将消息内容投递出去，发送成功不等于 mention 语义已成立。来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L61-L69；来源: modules/bot_api/send.go#L426-L438

mention 处理路径当前对结构化 mention 信息保持透传，不会从正文裸文本自动推断出真实被 @ 对象；结构化 mention 中的成员绑定和目标列表才是渲染与提醒语义的依据。来源: pkg/mentionrewrite/rewrite.go#L79-L87；来源: pkg/mentionrewrite/rewrite.go#L89-L103；来源: pkg/mentionrewrite/rewrite.go#L104-L105；来源: modules/bot_api/send.go#L299-L313

Bot / OBO 触发语义读取结构化 mention 中的定向目标和广播信号；无结构化 mention 时会被视为没有召唤目标。来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904；来源: modules/bot_api/obo_fanout.go#L956-L970；来源: modules/bot_api/obo_fanout.go#L971-L975

## 2. 目标与非目标

### 目标

- 明确 Bot 发送接口中“裸 bot_id 文本 @”与“真实 mention 提醒”的产品口径，避免调用方误判。
- 当调用方疑似把裸 bot_id 当作真实 @ 使用但未提供结构化 mention 时，系统应给出明确、可理解、可修复的结果提示。
- 推荐首版采用“明确失败 + 修正提示”策略：当系统识别为疑似裸 bot_id @ 且缺少对应结构化 mention 时，不静默表现为已 @ 成功。
- 保持正确结构化 mention 的现有能力和用户预期：使用结构化 mention 时，消息展示、提醒触发、Bot 召唤和发送结果应保持一致。
- 明确文档和示例口径：消息编号只代表消息投递已受理或发送成功，不代表正文裸文本 @ 已触发提醒；真实 @ 需要使用结构化 mention 或客户端/SDK 推荐的成员实体方式。
- 对无法唯一识别、无权限、非群成员、跨 Space / 跨群 / 跨 Thread、敏感内容和高频误用建立用户可见的安全边界。

### 非目标

- 首版不要求把所有正文中的 `@xxx_bot` 自动转换为真实 mention；自动转换可作为后续增强，但必须经过兼容性、唯一性和权限评估。
- 不把普通文本中的 `@xxx_bot` 一律视为错误；仅在产品规则定义的“疑似意图为真实 mention”场景提示或阻止误用。
- 不改变结构化 mention 的既有语义，不把 legacy `@所有人` 隐式扩展为 Bot 召唤。
- 不要求无权限用户知道某个 bot_id 是否存在、是否属于目标群、是否属于目标 Space。
- 不在 PRD 中定义内部数据结构、字段扩展、接口实现、内部实现方案或具体错误编号。
- 不在错误提示、日志、审计或 issue 评论中明文暴露 token、cookie、secret、私钥或生产凭证。

## 3. 用户故事

### US-01：Bot API 调用方发现裸 bot_id @ 未形成真实提醒
- 角色：作为 Bot API 调用方
- 场景：当我在群消息正文中输入裸 bot_id 形式的 @，但没有使用结构化 mention
- 诉求：希望系统不要让我误以为目标 Bot 已收到真实 @ 提醒
- 价值：以便我及时修正调用方式，避免任务或告警漏触达
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L61-L69；来源: modules/bot_api/send.go#L426-L438；来源: pkg/mentionrewrite/rewrite.go#L97-L105

### US-02：Bot API 调用方按推荐方式发送真实 mention
- 角色：作为 Bot API 调用方
- 场景：当我确实需要 @ 某个 Bot、某个成员或一组 AI 时
- 诉求：希望文档和失败提示告诉我应使用结构化 mention 或正确成员实体，而不是只写裸文本
- 价值：以便我用一次可验证的调用完成消息展示和真实提醒
- 来源: pkg/mentionrewrite/rewrite.go#L38-L39；来源: pkg/mentionrewrite/rewrite.go#L79-L87；来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904

### US-03：群成员看到的 @ 展示与实际提醒一致
- 角色：作为群成员或被 @ Bot 的负责人
- 场景：当群里出现看起来像 @Bot 的消息
- 诉求：希望可见展示和实际提醒语义一致，避免“看起来 @ 了但实际没提醒”
- 价值：以便群内协作对象能正确判断谁被召唤、谁需要响应
- 来源: pkg/mentionrewrite/rewrite.go#L79-L87；来源: pkg/mentionrewrite/rewrite.go#L97-L105

### US-04：产品运营负责人能解释兼容策略
- 角色：作为 Octo 产品运营负责人
- 场景：当调用方反馈裸 bot_id @ 未触发提醒，或升级后收到失败提示
- 诉求：希望有明确口径说明这是普通文本和真实 mention 的区别，并给出迁移建议
- 价值：以便我稳定处理反馈，不把消息发送成功误判为后端已完成真实 @
- 来源: modules/bot_api/send.go#L426-L438；来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904

### US-05：无权限、跨范围和滥用场景被安全处理
- 角色：作为普通成员、Bot API 调用方或系统运营人员
- 场景：当裸 bot_id @ 指向不存在、非本群、无权触达或跨 Space 的对象，或被高频批量尝试
- 诉求：希望系统给出安全、克制、不可枚举的提示，并保留必要追溯
- 价值：以便修复体验问题的同时不引入越权、枚举、骚扰或审计风险
- 来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904；来源: modules/bot_api/obo_fanout.go#L956-L970；来源: modules/bot_api/obo_fanout.go#L971-L975

## 4. 功能需求

### F-01-1 裸 bot_id @ 与真实 mention 的产品口径
- 所属故事：US-01、US-03、US-04
- 需求描述：系统应明确区分“正文中的普通 @ 文本”和“会触发提醒/召唤的真实 mention”。裸 bot_id 文本本身不得被表述为已触发真实 @。
- 业务规则：消息发送成功、返回消息编号、消息可见，不等同于目标成员或 Bot 已被真实 @；产品文案、接口说明和运营说明需统一这一口径。
- 边界场景：当用户只是想展示一段普通文本 `@xxx_bot` 时，不应被误描述为通知失败；当用户意图触发提醒时，应引导使用结构化 mention。
- 来源: modules/bot_api/send.go#L426-L438；来源: pkg/mentionrewrite/rewrite.go#L97-L105

### F-01-2 疑似误用时给出明确失败或修正提示
- 所属故事：US-01、US-02、US-04
- 需求描述：当调用方疑似在群消息中使用裸 bot_id @ 作为真实 mention，但未提供对应结构化 mention 时，系统应返回清晰结果，说明裸文本不会触发真实 @，并提示正确修正方式。
- 业务规则：推荐首版采用“明确失败 + 修正提示”策略；失败说明需面向调用者可理解，避免只返回泛化发送失败。
- 边界场景：正文包含多个疑似 bot_id、大小写或空格异常、同时存在普通文本 @、消息为非群聊、消息内容过长、无法判断意图时，应给出保守提示或按普通文本处理，避免误伤。
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L61-L69；来源: pkg/mentionrewrite/rewrite.go#L89-L103；来源: pkg/mentionrewrite/rewrite.go#L104-L105

### F-01-3 正确结构化 mention 保持可用
- 所属故事：US-02、US-03
- 需求描述：当调用方使用结构化 mention 或客户端/SDK 推荐成员实体方式时，系统应保持现有真实提醒和展示语义。
- 业务规则：结构化 mention 可表达定向成员、AI 广播、人类广播和展示绑定；这些语义不应因裸 bot_id @ 提示策略而被削弱。
- 边界场景：结构化 mention 为空、格式异常、目标重复、目标不在当前会话、目标无效或广播语义冲突时，应按既有产品规则提示或降级，不产生虚假提醒。
- 来源: pkg/mentionrewrite/rewrite.go#L38-L39；来源: pkg/mentionrewrite/rewrite.go#L79-L87；来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904；来源: modules/bot_api/obo_fanout.go#L956-L970；来源: modules/bot_api/obo_fanout.go#L971-L975

### F-01-4 兼容范围与升级口径
- 所属故事：US-01、US-04
- 需求描述：系统应明确兼容范围：已使用结构化 mention 的调用方不受影响；只把 `@xxx_bot` 当普通文本展示的调用方不应被错误要求迁移；将裸 bot_id 当真实 @ 使用的调用方需收到迁移提示。
- 业务规则：产品运营说明需明确首版不会承诺对裸 bot_id 自动转换；如后续选择自动转换，应仅在目标唯一、调用方有权触达且不会泄露成员存在性时生效。
- 边界场景：历史调用方依赖普通文本展示、消息模板中含 `@xxx_bot` 示例、文档引用、代码片段、聊天记录转发等场景，应避免被错误识别为真实 @ 意图。
- 来源: pkg/mentionrewrite/rewrite.go#L23-L36；来源: pkg/mentionrewrite/rewrite.go#L38-L39；来源: pkg/mentionrewrite/rewrite.go#L97-L105

### F-01-5 错误提示文案要求
- 所属故事：US-01、US-02、US-04
- 需求描述：错误或修正提示应同时说明“哪里不生效”“为什么不生效”“如何修正”。
- 业务规则：推荐提示口径为：裸 bot_id 只是正文文本，不会触发真实 @；如需提醒 Bot 或成员，请使用官方结构化 mention 示例或 SDK 能力；消息编号只代表发送成功，不代表 @ 已触发。
- 边界场景：目标不可见、目标不存在、目标不在当前群、调用方无权识别目标时，提示不得暴露具体对象是否存在，可统一表达为“未找到可提醒的有效成员或缺少结构化 mention”。
- 来源: modules/bot_api/send.go#L426-L438；来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904

### F-01-6 文档与示例
- 所属故事：US-02、US-04
- 需求描述：Bot API 文档、SDK 示例或运营答复应补充“普通文本 @”和“真实 mention”的区别，并提供最小正确示例。
- 业务规则：示例应展示：发送正文文本、绑定可提醒对象、触发定向提醒或 AI 广播的推荐方式；同时提醒调用方不要依赖裸 bot_id 自动识别。
- 边界场景：示例中的目标身份、群、Thread、Space 或 Bot 名称应使用脱敏占位，不使用真实生产账号、token、cookie、secret 或私钥。
- 来源: pkg/mentionrewrite/rewrite.go#L38-L39；来源: pkg/mentionrewrite/rewrite.go#L79-L87；来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904

### F-01-7 权限与范围校验口径
- 所属故事：US-03、US-05
- 需求描述：真实 mention 的目标必须限定在调用方有权发送且目标可触达的会话范围内；跨 Space、跨群、跨 Thread、Bot 不在群或成员不可见时，应给出安全结果。
- 业务规则：提示应避免泄露无权对象是否存在；不得让调用方通过批量裸 bot_id @ 或错误差异枚举 Bot / 成员。
- 边界场景：调用方尝试 @ 非本群 Bot、已退群 Bot、禁用 Bot、外部 Space Bot、无权 Thread 成员或大量 bot_id 时，应安全拒绝、降噪或提示无法完成。
- 来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904；来源: modules/bot_api/obo_fanout.go#L956-L970；来源: modules/bot_api/obo_fanout.go#L971-L975

### F-01-8 限流、防滥用与审计
- 所属故事：US-05
- 需求描述：系统应对高频裸 bot_id @ 误用、批量探测、重复失败和大量成员提醒提供防滥用与安全追溯口径。
- 业务规则：运营侧应能看到脱敏失败摘要、触发频率、影响范围和建议修复方向；审计不得记录明文凭证或完整敏感正文。
- 边界场景：短时间大量请求、多个疑似 bot_id、跨群尝试、失败重试风暴、异常来源或内容疑似凭证时，应优先保护系统和隐私。
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L61-L69；来源: modules/bot_api/obo_fanout.go#L877-L891；来源: modules/bot_api/obo_fanout.go#L892-L904

## 5. 状态与提示

- 消息发送成功：消息已完成发送流程或被受理；不代表正文裸 `@xxx_bot` 已触发真实 mention。
- 真实 mention 已触发：调用方使用结构化 mention 或正确成员实体，目标在可触达范围内，系统按产品规则触发提醒或 Bot 召唤。
- 裸 bot_id @ 不生效：系统识别到疑似裸文本 @，但没有可验证的真实 mention 绑定；调用方需要按文档修正。
- 普通文本展示：`@xxx_bot` 仅作为消息正文展示，不触发提醒；适用于示例、日志、说明文字等非召唤场景。
- 目标不可提醒：目标不存在、不可见、不在当前会话、无权触达或无法唯一确认；提示不得泄露无权对象详情。
- 兼容迁移提示：历史调用方应迁移到官方结构化 mention 或 SDK 推荐方式；消息编号不再被解释为 @ 成功凭证。

## 6. 验收标准

- AC-01：当 Bot API 调用方在群消息正文中疑似使用裸 bot_id @ 作为真实提醒但未提供结构化 mention 时，调用方能看到明确失败或修正提示，不会只看到“发送成功”后误以为 @ 已触发。
- AC-02：当调用方只是把 `@xxx_bot` 作为普通文本展示时，产品口径能清楚说明该文本不代表真实提醒，且不要求目标 Bot 收到召唤。
- AC-03：当调用方使用结构化 mention 或 SDK 推荐成员实体方式时，目标 Bot / 成员在有权范围内能按既有语义收到真实提醒或召唤。
- AC-04：当结构化 mention 的目标无效、无权、跨 Space、跨群、跨 Thread 或不可唯一确认时，调用方能看到安全、可修复的提示，且不能通过提示枚举无权成员或 Bot。
- AC-05：当消息发送成功但未触发真实 mention 时，返回信息、文档或运营说明不会把消息编号解释为 @ 已成功触发。
- AC-06：当一个消息同时包含正文文本和结构化 mention 时，用户看到的可见 @ 展示与实际提醒对象保持一致；不产生看起来 @ 了但实际未提醒的错觉。
- AC-07：当调用方短时间大量使用裸 bot_id @ 或批量尝试目标时，系统能按产品规则降噪、限制或给出安全失败摘要，避免骚扰、枚举和通知风暴。
- AC-08：文档或示例中明确给出结构化 mention 的推荐写法、普通文本 @ 的非提醒含义，以及迁移建议；示例不得包含真实生产凭证或敏感账号信息。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/api-error`、`area/im`、`area/bot-agent`
- V5 only：当前未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及成员可见性、Bot 召唤语义、错误提示防枚举、限流和审计，Review 应重点核验。

## 8. 待确认事项

1. [待确认] “疑似把裸 bot_id @ 当真实 mention 使用”的识别范围：仅群聊 Bot 发送接口，还是同步覆盖 legacy Bot 发送入口、用户消息发送入口和 webhook 场景。
2. [待确认] 首版是否正式采用“明确失败 + 修正提示”为唯一策略；自动转换是否作为后续版本，并仅在目标唯一且权限可验证时开放。
3. [待确认] 官方文档示例由哪个入口承载：Bot API 文档、SDK 示例、错误提示链接，还是三者都补。

## 9. 五类风险检查

- 多租户 / Space 隔离：不得通过裸 bot_id 解析或错误提示泄露跨 Space、跨群、跨 Thread 的 Bot / 成员存在性；真实 mention 只在调用方有权触达范围内生效。
- 权限 / ownership：调用方只能提醒当前会话中可触达且允许被提醒的目标；无权或不可达目标应安全失败，不得被自动转换成有效提醒。
- 安全 / 外部输入 / 凭证：正文、示例和错误提示可能包含外部输入；疑似 token、cookie、secret、私钥、生产凭证不得出现在文档示例、日志、审计或公开反馈中。
- 限流 / 防滥用：裸 bot_id 批量尝试可能造成成员枚举、通知风暴或 Bot 召唤滥用；需要限制、降噪和安全失败摘要。
- 审计 / 可追溯：运营侧应能追溯发送成功、真实 mention 触发、裸文本误用、目标过滤和失败提示，但审计只记录脱敏摘要，不记录明文敏感信息或无权对象详情。

## 10. What-only 自检摘要

- 技术 How：通过。PRD 只定义调用方可见行为、提示、兼容范围、文档示例和风险边界；未定义内部实现方案。
- 引用核验：通过。源码引用已按当前只读目标仓核验，行号覆盖发送入口、发送结果、mention pass-through、结构化 mention 和 fan-out 触发语义。
- Label 完整性：通过。Issue #26 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/api-error`、`area/im`、`area/bot-agent`；PRD 完成后建议唯一状态更新为 `status/reviewing`。
- 状态真实性：通过。当前为 PRD 草拟中；完成远端 PRD、issue 回填和群内交接后可进入 `status/reviewing`。
- 风险提醒 / 待人工确认：是。需产品运营负责人确认首版是否选择“明确失败 + 修正提示”，以及是否把自动转换留作后续版本。
