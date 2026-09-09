# PRD 草稿：Thread 与主群消息的上下文关联可视化

## 1. 背景与问题

Issue #30 反馈：当群内任务从主群消息进入 Thread / 子区，或进一步转入 Agent 会话处理时，运营和用户很难追踪这件事最初来自哪条主群消息、在哪个 Thread 继续、由哪个 Agent 执行、最后是否回到群内并闭环。当前复盘、排障、考试验收或客户群任务跟进常依赖人工翻聊天记录，容易出现上下文断裂、重复处理或漏闭环。

现有 Thread 创建入口已接收来源消息相关输入，并在创建 Thread 时传入服务层；这说明“主群消息 → Thread”已有局部基础，但该入口证据只覆盖 Thread 创建，不覆盖 Agent session 关联、跨 session 转发来源、反查入口、展示面板或闭环状态。来源: modules/thread/api.go#L252-L265；来源: modules/thread/api.go#L266-L280；来源: modules/thread/api.go#L281-L295；来源: modules/thread/api.go#L296-L308

Thread 数据模型包含来源消息编号，创建 Thread 时也会记录该来源消息编号；但这仍只是 Thread 自身的来源线索，不等于完整的“主群消息 ↔ Thread / 子区 ↔ Agent session ↔ 最后回复 / 闭环状态”上下文链路。来源: modules/thread/db.go#L31-L43；来源: modules/thread/service.go#L215-L223

Thread 创建流程对来源消息内容有明确不可信边界：调用方提供的来源消息内容会被用于拷贝，但服务端不校验该内容与来源消息编号是否对应；卡片来源还会因信任边界风险被拒绝拷贝。这与本需求提出的“跨 session 转发内容要标识来源和信任级别”直接相关。来源: modules/thread/service.go#L131-L145；来源: modules/thread/service.go#L146-L146；来源: modules/thread/service.go#L378-L392；来源: modules/thread/service.go#L393-L407；来源: modules/thread/service.go#L408-L417

父群内 Thread 创建通知当前会在源消息确实拷贝成功时展示来源消息编号、消息数量和最后消息预览；这能支撑来源展示的一部分，但仍缺少按主群消息、Thread 或 Agent session 反查完整上下文、展示当前处理位置和闭环状态的能力。来源: modules/thread/service.go#L485-L499；来源: modules/thread/service.go#L500-L514；来源: modules/thread/service.go#L515-L515；来源: modules/thread/service.go#L516-L530

AI Team 已有 Agent 与 Session 概念，Session 响应包含 session 标识、群、频道、标题、状态、消息数、最后消息和时间等信息；创建 session 的用户可见输入当前主要是名称和幂等语义，未看到来源主群消息、来源 Thread、跨 session 信任级别或闭环信息。来源: modules/ai_team/model.go#L46-L60；来源: modules/ai_team/model.go#L61-L64；来源: modules/ai_team/api.go#L92-L106；来源: modules/ai_team/api.go#L107-L109；来源: modules/ai_team/api.go#L110-L115；来源: modules/ai_team/service.go#L261-L275；来源: modules/ai_team/service.go#L329-L343；来源: modules/ai_team/service.go#L344-L345；来源: modules/ai_team/service.go#L347-L361；来源: modules/ai_team/service.go#L362-L376

现有 AI Team 查询 session 时会按 Space、用户、Agent、Thread 和状态边界返回当前 session 信息，并包含最后消息、置顶、静音等展示相关信息；这可以作为新增上下文展示的现有用户可见基础，但仍不是跨对象的完整上下文链路。来源: modules/ai_team/service.go#L463-L477；来源: modules/ai_team/service.go#L478-L492；来源: modules/ai_team/service.go#L495-L509；来源: modules/ai_team/service.go#L510-L510；来源: modules/ai_team/service.go#L511-L525；来源: modules/ai_team/service.go#L526-L534

消息读取侧已有群消息、Thread 消息和权限边界，包含群成员校验、Thread 状态处理、租户锚点与 Bot token 读取限制；新增反查和展示能力必须继承这些权限边界，不能因上下文关联而扩大可见范围。来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L125；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L482-L496；来源: modules/message/api.go#L497-L500

## 2. 目标与非目标

### 目标

- 将现有 Thread 来源消息线索扩展为用户和运营可理解的上下文链路：主群消息、Thread / 子区、Agent session、目标 Bot / Agent、触发用户、最后回复和闭环状态。
- 支持按主群消息、Thread / 子区、Agent session 标识等入口反查关联链路，并明确每类入口可见范围和返回口径。
- 在群内和后台分别展示合适粒度的上下文摘要，使用户能知道任务来源、当前处理位置、最后动作和是否已闭环。
- 明确跨 session 转发或引用内容的来源标识和信任级别，避免把转述、拷贝或不可信内容误认为直接用户指令。
- 明确闭环状态口径：处理中、等待用户、等待 Agent、已回复、已关闭、无法确认等状态应有用户可理解含义。
- 保持与 #28 发送后触达回执、#29 发送前预检的边界：本单关注上下文追踪与展示，不替代发送链路的预检或投递回执。
- 强化多租户、群 / Thread / Agent 权限、隐私脱敏、审计和保留期限要求。

### 非目标

- 不从零重做 Thread 创建能力；已有 Thread 来源消息能力是基础，本单关注完整链路产品化、反查和展示。
- 不定义内部数据库表、缓存、队列、SQL、代码实现或具体接口字段。
- 不承诺所有历史 Thread、历史消息或历史 Agent session 都能补全完整链路；缺失历史关系时应展示未知或不可确认。
- 不把发送前目标权限预检纳入本单验收；发送前是否可达以 #29 口径为准。
- 不把发送后真实投递、mention 提醒或阅读状态纳入本单验收；发送后触达以 #28 口径为准。
- 不在群内展示私聊内容、跨 Space 信息、无权消息正文、敏感凭证或内部诊断细节。

## 3. 用户故事

### US-01：群内用户追踪任务从哪条消息进入 Thread
- 角色：作为群内提问用户或任务发起人
- 场景：当我的主群消息被创建为 Thread / 子区继续处理
- 诉求：希望在群内或后台看到该 Thread 对应的来源消息、当前处理位置和最后动态
- 价值：以便我不用人工翻记录，也能知道任务是否正在推进
- 来源: modules/thread/api.go#L252-L265；来源: modules/thread/api.go#L266-L280；来源: modules/thread/service.go#L215-L223；来源: modules/thread/service.go#L485-L499；来源: modules/thread/service.go#L500-L514；来源: modules/thread/service.go#L515-L515；来源: modules/thread/service.go#L516-L530

### US-02：运营按任一线索反查完整上下文链路
- 角色：作为 Octo 产品运营负责人或授权排障人员
- 场景：当用户只提供一条消息、一个 Thread 或一个 Agent session 标识
- 诉求：希望后台能反查该事项关联的主群消息、Thread、Agent session、目标 Agent、最后回复和闭环状态
- 价值：以便快速复盘、排障和判断是否漏处理
- 来源: modules/ai_team/model.go#L46-L60；来源: modules/ai_team/model.go#L61-L64；来源: modules/ai_team/api.go#L30-L44；来源: modules/ai_team/api.go#L45-L47；来源: modules/ai_team/api.go#L117-L131；来源: modules/ai_team/api.go#L132-L140；来源: modules/ai_team/service.go#L463-L477；来源: modules/ai_team/service.go#L478-L492；来源: modules/ai_team/service.go#L495-L509；来源: modules/ai_team/service.go#L510-L510；来源: modules/ai_team/service.go#L511-L525；来源: modules/ai_team/service.go#L526-L534

### US-03：Agent / Bot 执行者理解来源和信任级别
- 角色：作为 Agent / Bot 执行者或其调用方
- 场景：当我收到来自 Thread、另一个 session 或转发内容的任务上下文
- 诉求：希望系统清楚标识内容来源、是否为直接用户输入、是否为转述/拷贝/不可信内容
- 价值：以便我不会把跨 session 转发内容误当作直接指令，也能按正确信任级别处理
- 来源: modules/thread/service.go#L131-L145；来源: modules/thread/service.go#L146-L146；来源: modules/thread/service.go#L378-L392；来源: modules/thread/service.go#L393-L407；来源: modules/thread/service.go#L408-L417

### US-04：群内成员看到安全的闭环摘要
- 角色：作为有权查看该群或 Thread 的群成员
- 场景：当任务由 Agent 处理并产生最后回复或状态变化
- 诉求：希望群内摘要能提示当前是否已回复、是否等待用户、是否已关闭或无法确认，但不暴露我无权查看的内容
- 价值：以便减少重复追问，同时保护私聊、跨 Space 和敏感信息
- 来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L125；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L456-L470

### US-05：安全与审计人员避免上下文链路成为越权通道
- 角色：作为 Space 管理者、产品运营负责人或安全审计人员
- 场景：当有人尝试通过 message、Thread 或 session 反查跨 Space、跨群、私聊或无权 Agent 信息
- 诉求：希望系统只展示授权范围内的链路摘要，并保留脱敏审计
- 价值：以便上下文可追踪能力不引入对象枚举、隐私泄露或越权复盘风险
- 来源: modules/ai_team/service.go#L37-L51；来源: modules/ai_team/service.go#L52-L54；来源: modules/ai_team/service.go#L57-L71；来源: modules/ai_team/service.go#L72-L73；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L482-L496；来源: modules/message/api.go#L497-L500

## 4. 功能需求

### F-01-1 上下文链路对象与范围
- 所属故事：US-01、US-02
- 需求描述：系统应以一个事项链路的方式呈现主群消息、Thread / 子区、Agent session、目标 Bot / Agent、触发用户、最后回复摘要和闭环状态。
- 业务规则：链路中每个对象都应标识其对象类型、当前可见状态和与上一环节的关系；已有 Thread 来源消息仅作为链路起点之一，不应被表述为完整链路能力。
- 边界场景：当只有主群消息和 Thread、没有 Agent session；只有 Agent session、来源消息缺失；历史数据不完整；Thread 已归档或删除；Agent session 不可用时，应展示部分链路和未知/不可确认状态。
- 来源: modules/thread/db.go#L31-L43；来源: modules/thread/service.go#L215-L223；来源: modules/ai_team/model.go#L46-L60；来源: modules/ai_team/model.go#L61-L64；来源: modules/ai_team/service.go#L463-L477；来源: modules/ai_team/service.go#L478-L492

### F-01-2 反查入口
- 所属故事：US-02、US-05
- 需求描述：系统应支持授权用户按主群消息、Thread / 子区或 Agent session 标识反查上下文链路，并返回与权限匹配的摘要。
- 业务规则：按消息查询时应展示该消息是否已关联 Thread / Agent session；按 Thread 查询时应展示来源消息、关联 session 和最后动态；按 Agent session 查询时应展示来源 Thread、来源消息、目标 Bot / Agent、当前状态和闭环摘要。
- 边界场景：查询对象不存在、无权查看、跨 Space、跨群、跨 Thread、跨私聊或关联链缺失时，应返回不可用/无权确认/暂无关联，不能泄露对象是否真实存在。
- 来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L125；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169；来源: modules/ai_team/api.go#L117-L131；来源: modules/ai_team/api.go#L132-L140；来源: modules/ai_team/service.go#L495-L509；来源: modules/ai_team/service.go#L510-L510；来源: modules/ai_team/service.go#L511-L525；来源: modules/ai_team/service.go#L526-L534

### F-01-3 群内展示口径
- 所属故事：US-01、US-04
- 需求描述：群内展示应提供简短、低噪音、可理解的上下文摘要，帮助用户知道任务来源、当前位置和是否闭环。
- 业务规则：群内只展示当前群/Thread 成员有权看到的信息；可展示来源消息的脱敏摘要、Thread 名称或位置、负责 Agent、最后公开回复摘要和闭环状态；不得展示私聊正文、跨 Space 信息、无权 session 内容或内部诊断细节。
- 边界场景：来源消息已删除、不可见、敏感、来自私聊或跨 Space；最后回复只在私聊或后台可见；群成员权限发生变化时，群内摘要应降级或不展示。
- 来源: modules/thread/service.go#L485-L499；来源: modules/thread/service.go#L500-L514；来源: modules/thread/service.go#L515-L515；来源: modules/thread/service.go#L516-L530；来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L125；来源: modules/message/api_message_get.go#L128-L142

### F-01-4 后台展示口径
- 所属故事：US-02、US-05
- 需求描述：后台展示应提供比群内更完整但仍受权限控制的链路视图，用于运营复盘、排障、考试验收和客户群任务追踪。
- 业务规则：后台可展示链路各节点、触发用户、目标 Agent、状态变化、最后回复摘要、闭环判断和不可见原因；不同角色看到的详情应与其 Space、群、Thread、Agent 和消息权限一致。
- 边界场景：授权排障人员、产品运营负责人、普通群管理员、普通成员、Bot token 或外部集成方权限不同；后台不得因排障便利绕过消息可见性、私聊边界或 Space 隔离。
- 来源: modules/ai_team/service.go#L37-L51；来源: modules/ai_team/service.go#L52-L54；来源: modules/ai_team/service.go#L57-L71；来源: modules/ai_team/service.go#L72-L73；来源: modules/ai_team/service.go#L463-L477；来源: modules/ai_team/service.go#L478-L492；来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455

### F-01-5 Agent session 关联
- 所属故事：US-01、US-02、US-03
- 需求描述：当 Thread / 子区触发或承载 Agent session 时，系统应在用户可见链路中体现 session 与来源消息、Thread、触发用户和目标 Agent 的关系。
- 业务规则：Agent session 不是 Thread 来源消息能力的自然延伸；需要单独在产品口径中说明 session 从何处发起、当前在哪个会话处理、最后活动是什么、是否仍在处理。
- 边界场景：一个 Thread 关联多个 session、一个 session 被多次唤起、session 被归档/删除/失败、Agent 被移除、同一消息触发多个 Agent 时，应展示清楚的多节点或不可确认状态。
- 来源: modules/ai_team/model.go#L46-L60；来源: modules/ai_team/model.go#L61-L64；来源: modules/ai_team/api.go#L92-L106；来源: modules/ai_team/api.go#L107-L109；来源: modules/ai_team/service.go#L261-L275；来源: modules/ai_team/service.go#L329-L343；来源: modules/ai_team/service.go#L344-L345；来源: modules/ai_team/service.go#L347-L361；来源: modules/ai_team/service.go#L362-L376；来源: modules/ai_team/service.go#L584-L598；来源: modules/ai_team/service.go#L599-L612

### F-01-6 跨 session 来源标识与信任级别
- 所属故事：US-03、US-05
- 需求描述：当内容来自跨 session 转发、拷贝、摘要、引用或人工补录时，系统应标识来源类型和信任级别，避免被误当成直接用户指令。
- 业务规则：建议产品语义至少区分：直接来源、系统记录来源、用户提供来源、跨 session 转述、不可验证来源；不同信任级别应影响展示文案和 Agent 可执行判断。
- 边界场景：调用方提供的来源内容与原消息不一致、来源消息不可见、卡片或交互内容不可信、跨 Space 转发、摘要由 Agent 生成或人工编辑时，应显式标记不可验证或需人工确认。
- 来源: modules/thread/service.go#L131-L145；来源: modules/thread/service.go#L146-L146；来源: modules/thread/service.go#L378-L392；来源: modules/thread/service.go#L393-L407；来源: modules/thread/service.go#L408-L417

### F-01-7 闭环状态口径
- 所属故事：US-01、US-02、US-04
- 需求描述：系统应为上下文链路提供用户可理解的闭环状态，辅助判断事项是否仍需处理。
- 业务规则：建议状态包括：处理中、等待用户、等待 Agent、已有最后回复、已闭环、已归档、失败、无法确认。状态应基于用户可见事实表达，不应把发送成功、Thread 存在或 session 存在直接等同于已闭环。
- 边界场景：最后回复不可见、回复只在私聊、Agent session 失败、Thread 归档但问题未解决、用户重新追问、多个 Agent 部分完成、发送后触达未知时，应展示未闭环或无法确认。
- 来源: modules/ai_team/model.go#L46-L60；来源: modules/ai_team/model.go#L61-L64；来源: modules/ai_team/service.go#L463-L477；来源: modules/ai_team/service.go#L478-L492；来源: modules/ai_team/service.go#L495-L509；来源: modules/ai_team/service.go#L510-L510；来源: modules/ai_team/service.go#L511-L525；来源: modules/ai_team/service.go#L526-L534；来源: modules/ai_team/service.go#L584-L598；来源: modules/ai_team/service.go#L599-L612

### F-01-8 与发送前预检和发送后回执的边界
- 所属故事：US-02、US-04
- 需求描述：上下文链路可引用“预检结果”或“发送后回执”作为节点摘要，但不得替代 #29 的发送前可达性判断或 #28 的真实投递 / mention 回执。
- 业务规则：链路展示应表达“这件事关联了哪些对象、当前在哪里、最后发生了什么、是否闭环”；目标是否可发、消息是否投递、mention 是否真实触达，应由对应能力给出。
- 边界场景：预检通过但发送失败、发送成功但群内不可见、mention 未提醒、最后回复发送失败或触达未知时，链路状态不得误报为已闭环。
- 来源: modules/thread/service.go#L485-L499；来源: modules/thread/service.go#L500-L514；来源: modules/thread/service.go#L515-L529；来源: modules/thread/service.go#L530-L530；来源: modules/ai_team/model.go#L46-L60；来源: modules/ai_team/model.go#L61-L64；来源: modules/message/api_message_get.go#L107-L121；来源: modules/message/api_message_get.go#L122-L125；来源: modules/message/api_message_get.go#L128-L142；来源: modules/message/api_message_get.go#L143-L157；来源: modules/message/api_message_get.go#L158-L169

### F-01-9 权限、隐私与脱敏
- 所属故事：US-04、US-05
- 需求描述：上下文反查和展示必须继承消息、Thread、Agent session 和 Space 的权限边界，只展示当前角色有权看到的摘要和状态。
- 业务规则：对无权、跨范围、私聊、敏感正文、被删除消息、不可见 session 或不存在对象，应使用统一不可用/无权确认/已不可见口径；展示摘要应最小化，不输出 token、cookie、secret、私钥或完整敏感正文。
- 边界场景：普通群成员查看后台链路、Bot token 查询非自身 session、跨 Space 查询、外部集成方批量查 message / thread / session、成员退出群后继续访问历史链路时，应安全拒绝或降级展示。
- 来源: modules/message/api.go#L432-L446；来源: modules/message/api.go#L447-L455；来源: modules/message/api.go#L456-L470；来源: modules/message/api.go#L482-L496；来源: modules/message/api.go#L497-L500；来源: modules/ai_team/service.go#L37-L51；来源: modules/ai_team/service.go#L52-L54；来源: modules/ai_team/service.go#L57-L71；来源: modules/ai_team/service.go#L72-L73

### F-01-10 审计、保留期限与异常处理
- 所属故事：US-02、US-05
- 需求描述：系统应为上下文反查、后台查看、群内摘要展示、跨 session 来源标记和闭环状态变更保留可追溯但脱敏的审计记录，并明确链路可追踪期限。
- 业务规则：审计应能说明谁在什么 Space / 群 / Thread / session 范围查看或变更了链路状态、看到的结果类别和是否命中降级；不得记录明文凭证、完整敏感正文、无权对象清单或内部异常细节。
- 边界场景：链路历史超过保留期限、对象被删除、消息不可见、session 失败或系统依赖暂不可用时，应展示过期、不可确认或需授权排障，不把缺失误判为无关联。
- 来源: modules/ai_team/service.go#L444-L458；来源: modules/ai_team/service.go#L459-L460；来源: modules/message/api_message_get.go#L158-L169；来源: modules/thread/service.go#L294-L308；来源: modules/thread/service.go#L309-L321; 来源: modules/thread/service.go#L334-L348；来源: modules/thread/service.go#L349-L363；来源: modules/thread/service.go#L364-L369

## 5. 状态与提示

### 链路节点状态

- 来源已确认：当前角色有权看到来源消息或其脱敏摘要，且该来源与 Thread / session 的关系可确认。
- 来源不可验证：来源内容来自调用方提供、转述、拷贝、摘要或历史补录，无法证明与原消息完全一致。
- 来源不可见：来源消息存在性或内容对当前角色不可见，系统只展示授权范围内的安全摘要。
- Thread 处理中：Thread / 子区仍可用于推进事项。
- Thread 已归档 / 已删除：Thread 不再作为活跃处理位置；历史链路按权限展示。
- Session 处理中：Agent session 仍处于可处理或等待响应状态。
- Session 不可用 / 失败：Agent session 当前不可继续处理，需重新发起或人工介入。

### 闭环状态

- 处理中：事项正在 Thread 或 Agent session 中推进。
- 等待用户：已有回复或问题需要用户补充。
- 等待 Agent：用户或运营已提交内容，正在等待 Agent 处理。
- 已有最后回复：系统能展示最后一条授权可见回复摘要，但不自动等同已闭环。
- 已闭环：有明确用户可见结论或人工标记表明事项已完成。
- 已归档：事项已从活跃处理列表移出，但不一定代表成功解决。
- 失败：链路处理出现明确失败且需要重试或人工处理。
- 无法确认：缺少授权可见事实、对象过期、依赖不可用或历史链路不完整。

### 信任级别提示

- 直接来源：来自当前群/Thread 中可验证的原始消息。
- 系统记录来源：来自系统记录的创建、跳转或关联事件。
- 用户提供来源：由调用方或用户提供，内容未必与原消息一致。
- 跨 session 转述：来自另一个 session 的摘要或转发，不应直接视为原始指令。
- 不可验证来源：来源对象不可见、已删除、过期或无法核验。

## 6. 验收标准

- AC-01：当主群消息被创建为 Thread / 子区后，授权用户能看到该 Thread 与来源消息的关系，并能区分这是已有 Thread 来源能力还是完整上下文链路的一部分。
- AC-02：当 Thread 进一步关联 Agent session 时，授权用户能看到来源消息、Thread、session、目标 Agent、触发用户、最后活动和闭环状态的链路摘要。
- AC-03：当用户按主群消息、Thread 或 Agent session 查询时，系统能返回授权范围内的关联链路；无关联、无权或不可确认时给出安全提示。
- AC-04：当群内展示上下文摘要时，只展示当前群/Thread 成员有权查看的信息，不暴露私聊、跨 Space、无权 session 或敏感正文。
- AC-05：当后台展示上下文链路时，不同角色只能看到其权限范围内的节点详情和摘要；不可见节点应降级为不可用/无权确认。
- AC-06：当内容来自跨 session 转发、拷贝、摘要、调用方提供或人工补录时，系统能标识来源类型和信任级别，避免被误当成直接用户指令。
- AC-07：当最后回复、Thread 状态、session 状态或人工标记发生变化时，闭环状态能反映用户可见事实，不把发送成功、session 存在或 Thread 存在直接等同于已闭环。
- AC-08：当链路对象被删除、归档、过期、权限变化或历史关系缺失时，系统显示未知、不可确认、已归档或不可见，不误报无关联或已完成。
- AC-09：当有人高频反查 message / Thread / session 或尝试跨 Space / 跨群 / 跨私聊探测时，系统能安全拒绝、降级展示或记录脱敏审计，防止枚举。
- AC-10：文档和运营口径明确本单与已有 Thread `source_message_id`、#28 发送后回执、#29 发送前预检的边界。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/im`、`area/bot-agent`、`area/api-error`
- V5 only：当前未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及跨对象链路、跨 session 转述、私聊/群/Space 权限、防枚举和审计，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 首版反查入口是否覆盖三类入口：主群消息、Thread / 子区、Agent session，还是先聚焦 Thread 与 Agent session。
2. [待确认] 群内展示是否允许显示最后回复摘要；若最后回复来自私聊、后台或无权 session，是否仅展示状态不展示正文。
3. [待确认] 闭环状态是否允许由授权运营人工标记；如允许，人工标记与系统状态冲突时以哪类用户可见事实优先。

## 9. 五类风险检查

- 多租户 / Space 隔离：上下文链路必须以 Space、群、Thread、Agent session 和消息可见性为边界；跨 Space 或跨群对象不得通过链路反查泄露。
- 权限 / ownership：普通群成员、触发用户、Agent owner、Bot token、产品运营负责人、授权排障人员和授权研发可见范围不同；不得因“完整链路”绕过原有对象权限。
- 安全 / 外部输入 / 凭证：来源消息、跨 session 转述、用户提供 payload、最后回复摘要和审计内容都可能包含外部输入；必须脱敏，不展示 token、cookie、secret、私钥、生产凭证或完整敏感正文。
- 限流 / 防滥用：按 message / Thread / session 反查可能被用于枚举对象、成员关系或处理状态；需要限制、降噪、统一失败口径和异常追踪。
- 审计 / 可追溯：后台查看、群内展示、状态变更、跨 session 来源标记和人工闭环应可追溯谁、在哪个 Space / 群 / Thread / session 范围、对哪个事项做了什么；审计只记录脱敏摘要。

## 10. What-only 自检摘要

- 技术 How：通过。PRD 只定义用户/运营可见的上下文链路、反查、展示、信任级别、闭环状态、权限边界和验收；未定义数据库、缓存、队列、SQL、代码或内部实现路径。
- 引用核验：通过。源码引用覆盖 Thread 创建与来源消息、来源内容不可信边界、父群通知展示基础、AI Team session 创建/查询、消息读取权限和 Space / Agent 权限边界。
- Label 完整性：通过。Issue #30 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/im`、`area/bot-agent`、`area/api-error`；PRD 完成后建议唯一状态更新为 `status/reviewing`。
- 状态真实性：通过。当前为 PRD 草拟中；完成远端 PRD、issue 回填和群内交接后可进入 `status/reviewing`。
- 风险提醒 / 待人工确认：是。需产品运营负责人确认首版反查入口范围、群内最后回复摘要展示边界、闭环状态是否允许人工标记。
