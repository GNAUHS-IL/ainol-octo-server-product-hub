# PRD：需求单关联消息一键回溯能力

## 1. 背景与问题

Issue #22 反馈：当需求单从 Octo 群聊讨论中产生时，后续产品、研发、测试或需求管理人员查看需求单时，不容易还原当时上下文，需要手动翻聊天记录。用户希望创建需求单时能自动关联原始群消息、前后若干条上下文、相关附件/截图，并在需求单中提供“一键回到原讨论”的入口，提升背景还原和追溯效率。

现有源码显示，Octo 已具备消息读取、会话内搜索、按消息定位上下文、文件上传/下载、群/Thread/DM 可见性、Space 隔离、限流与审计等基础能力；本 PRD 仅定义“需求单关联消息一键回溯”的用户可见行为、范围边界、权限口径和验收标准，不定义内部落地方案。

- 消息模块路由已包含频道消息同步、单条 DM 消息读取、消息搜索、频道文件聚合等与消息上下文读取相关的用户能力。来源: modules/message/api.go#L353-L362；来源: modules/message/api.go#L363-L375；来源: modules/message/api.go#L376-L388
- 单条 DM 消息读取显式挂 Space 校验，避免按消息反查跨 Space DM 元数据。来源: modules/message/api.go#L393-L403
- 会话内搜索文档说明，搜索命中后可用 `message_seq` 定位并拉取命中消息前后上下文。来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L50-L57
- 会话内搜索响应包含消息 id、消息序列、发送人、发送时间和概要片段，可支撑需求单展示原始消息摘要与定位信息。来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L120-L130
- 上下文定位文档说明可按来源会话类型映射 DM、群、Thread，并按命中序列拉取前后消息。来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L293-L303；来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L306-L313
- 上下文定位文档提示同步入口已挂鉴权与 Space 校验，非群内用户按无结果处理，撤回/删除消息可能在窗口中缺失。来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L315-L319
- 会话搜索访问控制要求调用者只能搜索自己已经可读的会话，群必须是活跃成员，Thread 需校验父群访问，拒绝时不泄露对象是否存在。来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L46-L50
- 搜索结果可见性过滤会排除已撤回、全局删除、用户删除、已清空会话前的消息和不在可见名单内的消息；异常时应 fail-closed。来源: modules/messages_search/visibility.go#L195-L203；来源: modules/messages_search/visibility.go#L216-L221
- 消息搜索路由统一挂鉴权、共享 UID 限流、Space 校验、搜索限流、审计和后端可用性门禁。来源: modules/messages_search/api.go#L147-L156；来源: modules/messages_search/api.go#L157-L165
- 搜索输入对关键词、发送人过滤、页大小、排序和游标有边界校验，避免无约束查询。来源: modules/messages_search/validate.go#L11-L18；来源: modules/messages_search/validate.go#L88-L99；来源: modules/messages_search/validate.go#L100-L104；来源: modules/messages_search/validate.go#L105-L113；来源: modules/messages_search/validate.go#L147-L160
- 搜索审计记录主体、会话、耗时、状态和关键词哈希，不记录明文关键词。来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L62-L70
- 文件模块提供认证后的文件预览、上传、预签名上传和下载入口；下载能力依赖对象不可枚举与上层消息读路由的访问边界。来源: modules/file/api.go#L83-L90；来源: modules/file/api.go#L91-L99；来源: modules/file/api.go#L101-L110；来源: modules/file/api.go#L111-L117
- Space 隔离规则要求访问用户数据必须执行隔离和 ownership 检查，读写不得跨 Space。来源: .octospec/rules/space-isolation.md#L21-L31
- 限流规则要求认证路由使用共享 UID 限流，未认证路由使用严格 IP 限流，不应手写通用请求频控。来源: .octospec/rules/rate-limit.md#L21-L29

## 2. 目标与非目标

### 目标

- 从 Octo 群聊、Thread 或其他有权会话中创建需求单时，需求单能关联触发创建的原始消息。
- 需求单详情能展示用户有权查看的原始消息摘要、前后上下文摘要、来源会话摘要、相关附件/截图引用状态和“一键回到原讨论”的入口。
- 自动关联范围有清晰边界，避免无差别保存、展示或传播大量聊天内容。
- 当来源消息、上下文、附件或讨论入口因无权、跨 Space / 跨群 / 跨 Thread、撤回、删除、清空、过期或失效不可见时，给出安全提示，不泄露详情。
- 支持产品、研发、测试、需求管理专员和产品运营负责人快速理解需求背景、讨论结论和待确认材料。
- 对权限可见性、敏感信息脱敏、频率/数量限制、失败提示和审计追溯建立统一产品口径。

### 非目标

- 不替产品运营负责人裁定需求是否进入需求池、最终优先级、最终状态或是否接受。
- 不定义内部落地方案、服务结构、部署方式或研发细节。
- 不要求把完整聊天记录复制到需求单，也不要求保留用户无权查看或已经不可见的消息正文。
- 不把“一键回到原讨论”作为绕过群、Thread、Space 或 Bot 权限的访问能力。
- 不要求对所有历史需求单批量补齐关联；历史需求可按可用证据展示“未关联”或“关联不可用”。
- 不在需求单、评论、通知、日志或审计中明文展示 token、cookie、secret、私钥、生产凭证或私密消息全文。

## 3. 用户故事

### US-01：反馈人从群聊创建需求单时保留来源
- 角色：作为群内反馈人或需求提交人
- 场景：当我在群聊讨论中提出需求并由 Bot 或运营创建需求单
- 诉求：希望需求单自动关联触发创建的原始消息和必要上下文
- 价值：以便后续处理人能快速理解当时背景，不反复追问或手动翻记录
- 来源: modules/message/api.go#L353-L362；来源: modules/message/api.go#L363-L375；来源: modules/message/api.go#L376-L388；来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L50-L57

### US-02：产品、研发和测试一键回到原讨论
- 角色：作为产品、研发、测试或需求管理专员
- 场景：当我查看需求单并需要确认原始语境、讨论结论或附件截图
- 诉求：希望在有权范围内点击入口回到原讨论位置，并看到必要上下文
- 价值：以便降低理解偏差和沟通成本
- 来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L293-L303；来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L306-L313；来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L315-L319

### US-03：产品运营负责人核验需求背景和材料完整性
- 角色：作为 Octo 产品运营负责人
- 场景：当我分诊、补充或 Review 需求时，需要确认需求来自哪段讨论、有哪些附件和上下文
- 诉求：希望需求单展示来源会话、触发消息摘要、上下文摘要和附件/截图引用状态
- 价值：以便判断材料是否完整，并要求反馈人补充缺失信息
- 来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L120-L130；来源: modules/file/api.go#L83-L90；来源: modules/file/api.go#L91-L99

### US-04：无权或失效场景安全降级
- 角色：作为普通成员、跨群成员、退群成员或无权查看者
- 场景：当我打开一个包含来源讨论的需求单，但我无权查看原会话或原消息已不可见
- 诉求：希望系统明确告诉我无法查看或入口失效，而不是暴露私密消息详情
- 价值：以便保护群聊、Thread、Space 和附件权限边界
- 来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L46-L50；来源: modules/messages_search/visibility.go#L195-L203

### US-05：运营和审计人员追溯关联动作
- 角色：作为系统运营人员、需求管理专员或主考
- 场景：当来源关联、回溯入口、附件引用或上下文展示出现争议或失败
- 诉求：希望看到可追溯的安全摘要，知道是谁、在什么需求范围、基于哪个来源会话、发生了什么结果
- 价值：以便排查问题，同时不泄露敏感内容
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L62-L70

## 4. 功能需求

### F-01-1 创建需求单时关联触发消息
- 所属故事：US-01、US-03
- 需求描述：从群聊或 Thread 讨论创建需求单时，系统应将触发创建的原始消息作为需求来源展示，并能在需求单中看到来源会话摘要、发送人摘要、发送时间和消息摘要。
- 业务规则：仅关联创建人和后续查看人有权查看的来源信息；来源摘要应足够识别背景，但不应无差别复制完整会话。
- 边界场景：来源消息为空、格式不支持、已撤回、已删除、用户清空过会话、来源会话失效或创建时没有明确触发消息时，应展示“来源不可用 / 未关联 / 已不可见”等安全状态。
- 来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L120-L130；来源: modules/messages_search/visibility.go#L195-L203；来源: modules/messages_search/visibility.go#L216-L221

### F-01-2 自动关联上下文摘要
- 所属故事：US-01、US-02、US-03
- 需求描述：需求单应展示触发消息前后有限范围内、用户有权查看的上下文摘要，帮助还原讨论脉络。
- 业务规则：上下文范围必须有明确数量或时间边界；展示内容按查看人的当前权限过滤；上下文仅作为需求背景，不改变需求当前状态和裁定口径。
- 边界场景：前后消息不足、部分消息被撤回/删除、部分内容对当前查看人不可见、上下文窗口过大、来源为 Thread 或 DM、消息排序不连续时，应展示可理解的缺失或过滤提示。
- 来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L293-L303；来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L306-L313；来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L315-L319；来源: modules/messages_search/visibility.go#L195-L203

### F-01-3 一键回到原讨论入口
- 所属故事：US-02、US-04
- 需求描述：需求单详情应提供“一键回到原讨论”入口，使有权用户能回到原始群聊、Thread 或会话中的对应位置。
- 业务规则：入口只对当前有权访问来源会话和来源消息的用户可用；入口文案应说明目标会话类型和可访问状态。
- 边界场景：用户已退群、Thread 已删除、来源会话不可访问、消息已撤回/删除、入口过期、客户端不支持定位或跨端打开失败时，应提示原因和可恢复操作，不展示无权消息详情。
- 来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L293-L303；来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L306-L313；来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L46-L50

### F-01-4 附件和截图引用状态
- 所属故事：US-02、US-03、US-04
- 需求描述：当来源讨论包含相关附件、截图、图片或文件时，需求单应展示附件/截图的引用状态和可访问提示。
- 业务规则：附件/截图只展示接收人有权访问的摘要、文件名或缩略提示；下载、预览或跳转能力必须遵守原会话和文件访问边界。
- 边界场景：附件被删除、预览失效、下载入口不可用、对象不可访问、用户无权查看、文件名含敏感信息或附件数量过多时，应展示安全摘要或折叠状态，不泄露文件正文或私密对象信息。
- 来源: modules/file/api.go#L83-L90；来源: modules/file/api.go#L91-L99；来源: modules/file/api.go#L101-L110；来源: modules/file/api.go#L111-L117；来源: modules/file/api.go#L660-L667；来源: modules/file/api.go#L668-L675

### F-01-5 来源关联可见性与权限过滤
- 所属故事：US-02、US-04
- 需求描述：需求来源、上下文、附件引用和回溯入口必须按照查看人的当前权限展示。
- 业务规则：跨 Space、跨群、跨 Thread、跨 Bot、非成员、退群、角色变化或来源对象不可见时，不展示具体消息、附件或会话详情；无权提示不得成为枚举来源会话或消息是否存在的信道。
- 边界场景：需求单本身可见但来源讨论不可见、多人协作但权限不同、原群已解散、Thread 已归档或删除、DM 属于不同 Space 时，应按最小可见原则展示“不可查看来源详情”。
- 来源: .octospec/rules/space-isolation.md#L21-L31；来源: modules/message/api.go#L393-L403；来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L46-L50

### F-01-6 敏感内容脱敏与人工确认
- 所属故事：US-03、US-04、US-05
- 需求描述：来源消息、上下文摘要、附件名、图片说明、需求标题或评论中包含疑似敏感信息时，应优先展示脱敏摘要或提示人工确认。
- 业务规则：疑似 token、cookie、secret、私钥、生产凭证、客户隐私、内部敏感链接或私密消息全文不得被自动复制到需求单公开区域、群通知或审计明文中。
- 边界场景：系统无法判断敏感级别、敏感内容位于图片/附件中、仅部分成员有权查看或需要人工补充摘要时，应安全降级，不硬推公开展示。
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L62-L70

### F-01-7 关联范围与数量控制
- 所属故事：US-01、US-05
- 需求描述：系统应明确自动关联的上下文条数、附件数量、展示长度和可回溯范围边界。
- 业务规则：默认只关联与需求创建直接相关的有限上下文；超出范围时展示“更多上下文请回到原讨论查看”，并仍按权限控制。
- 边界场景：高频群聊、长讨论、批量附件、重复创建需求、同一消息关联多个需求或需求跨多个讨论来源时，应避免刷屏、重复关联或过量展示。
- 来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L293-L303；来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L306-L313；来源: modules/messages_search/validate.go#L11-L18；来源: modules/messages_search/validate.go#L147-L160

### F-01-8 来源关联状态展示
- 所属故事：US-02、US-03、US-04
- 需求描述：需求单应清晰展示来源关联的当前状态，包括已关联、部分可见、无权查看、来源已失效、附件不可用、未关联或待补充。
- 业务规则：状态文案应帮助处理人判断是否需要补充材料；不得把“入口可打开”误表达为“上下文完整”或“需求已确认”。
- 边界场景：来源消息可见但附件不可见、上下文部分缺失、回溯入口可用但原消息已不可见、需求从非 Octo 渠道创建时，应分别展示真实状态。
- 来源: docs/messages-search/api-spec-v2-server-to-frontend.html#L315-L319；来源: modules/messages_search/visibility.go#L195-L203

### F-01-9 失败提示与可恢复操作
- 所属故事：US-02、US-04、US-05
- 需求描述：当自动关联、上下文读取、附件引用或回溯入口失败时，系统应给出用户可理解的原因类别和下一步建议。
- 业务规则：失败提示应区分未关联、无权、来源失效、内容已删除/撤回、附件不可用、客户端不支持、频率受限或系统暂不可用；但不得泄露无权对象详情。
- 边界场景：部分成功、重复点击、网络异常、消息服务不可用、来源对象短时间内状态变化时，应提示用户稍后重试、联系产品运营负责人或补充文字背景。
- 来源: modules/messages_search/visibility.go#L216-L221；来源: modules/messages_search/api.go#L147-L156；来源: modules/messages_search/api.go#L157-L165

### F-01-10 限流与防滥用
- 所属故事：US-01、US-05
- 需求描述：创建需求时自动关联、需求详情查看上下文、点击回溯入口和附件预览应具备频率、范围和数量约束。
- 业务规则：能力不得被用于批量抓取聊天记录、枚举群/Thread/消息、绕过文件访问或对 Bot/消息服务造成过载；触发限制时展示安全提示。
- 边界场景：同一用户高频创建需求、高频点击回溯入口、批量读取上下文、超大附件、跨多个来源批量关联时，应降噪、拒绝或提示稍后重试。
- 来源: modules/messages_search/api.go#L147-L156；来源: modules/messages_search/api.go#L157-L165；来源: modules/messages_search/validate.go#L105-L113；来源: .octospec/rules/rate-limit.md#L21-L29

### F-01-11 审计与追溯摘要
- 所属故事：US-03、US-05
- 需求描述：来源关联、上下文读取、回溯入口点击、附件引用展示、权限过滤和失败结果应保留可追溯安全摘要。
- 业务规则：审计摘要应能说明操作者、需求单范围、来源会话类型、来源关联状态、过滤结果和处理时间；不得记录明文敏感内容、完整私密正文或无权对象详情。
- 边界场景：多人同时查看、权限变化、同一来源关联多个需求、来源被删除、附件失效或疑似滥用时，应能支持事后排查和产品运营确认。
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L62-L70

## 5. 状态与提示

- 已关联来源：需求单已关联原始消息，当前用户可查看来源摘要。
- 未关联来源：创建需求时没有可用来源消息，建议补充背景说明。
- 来源部分可见：当前用户只能看到部分上下文或附件，其他内容因权限、删除、撤回或失效不可见。
- 无权查看来源：当前用户无权访问来源会话、消息或附件，不展示详情。
- 来源已不可用：原消息、Thread、群或附件已删除、撤回、失效或无法定位。
- 可回到原讨论：当前用户有权打开来源讨论入口。
- 回溯入口不可用：入口过期、客户端不支持、来源会话不可达或权限不足。
- 上下文已过滤：部分消息因撤回、删除、清空或可见性规则被隐藏。
- 附件可查看：当前用户有权预览或下载该附件/截图。
- 附件不可查看：附件已删除、失效、无权或来源不可见。
- 疑似敏感内容：摘要已脱敏或需人工确认后补充。
- 操作过于频繁：当前读取或回溯动作触发频率/数量限制，请稍后重试或缩小范围。

## 6. 验收标准

- AC-01：当用户从有权群聊或 Thread 讨论创建需求单时，需求单能展示触发消息的来源摘要和来源关联状态。
- AC-02：当用户查看有权需求单时，能看到有限范围内、有权可见的上下文摘要，并能识别哪些内容被过滤或不可用。
- AC-03：当用户点击“一键回到原讨论”且仍有权访问来源会话时，能回到对应讨论位置或看到可理解的定位结果。
- AC-04：当用户无权访问来源会话、来源消息或附件时，需求单不展示具体消息、附件或会话详情，并给出安全提示。
- AC-05：当来源消息被撤回、删除、用户清空会话、Thread 删除、附件失效或入口不可用时，需求单展示真实不可用状态，不误报为可访问或完整。
- AC-06：当来源讨论包含附件、截图或文件时，需求单能展示用户有权查看的附件引用状态；无权或失效附件不泄露文件内容。
- AC-07：当上下文条数、附件数量或展示长度超出范围时，系统能截断、折叠或提示回到原讨论查看，而不是无边界复制聊天记录。
- AC-08：当不同角色查看同一需求单时，来源摘要、上下文、附件和回溯入口按各自当前权限展示，不跨 Space / 群 / Thread / Bot 泄露。
- AC-09：当来源内容包含疑似 token、cookie、secret、私钥、生产凭证、客户隐私或内部敏感链接时，需求单、通知和审计仅展示脱敏摘要或人工确认提示。
- AC-10：当用户高频创建、读取上下文、点击回溯入口或批量查看附件时，系统有频率、范围或数量边界，并提供安全提示。
- AC-11：当来源关联或回溯失败时，用户能看到未关联、无权、失效、已删除/撤回、附件不可用、客户端不支持、频率受限或系统暂不可用等原因类别和可恢复建议。
- AC-12：运营或需求管理人员能基于安全摘要追溯来源关联、上下文过滤、附件状态、回溯入口点击和失败结果；审计不记录明文敏感内容或完整私密正文。
- AC-13：产品说明覆盖触发条件、默认关联范围、上下文边界、附件/截图引用、回溯入口、无权/失效处理、脱敏、限流、失败提示和审计口径。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/im`、`area/bot-agent`
- V5 only：未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及原始群消息、上下文、附件/截图、跨 Space / 群 / Thread 可见性、敏感内容、限流和审计，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 首版自动关联的上下文范围采用固定条数、固定时间窗口，还是由需求创建入口提供默认配置。
2. [待确认] 首版是否支持一个需求单关联多个来源讨论，还是仅保留主来源并允许人工补充文字背景。
3. [待确认] 附件/截图首版展示到“引用状态 + 文件名/缩略提示”，还是需要在需求单内直接预览有权图片。

## 9. 五类风险检查

- 多租户 / Space 隔离：来源消息、上下文、附件、回溯入口和失败状态必须按当前查看人的 Space / 群 / Thread / Bot 权限展示；跨范围对象不展示详情，也不泄露是否存在。
- 权限 / ownership：只有有权创建、查看或处理该需求的人可查看来源关联；一键回溯不得绕过原会话成员关系、Thread 父群访问、DM Space 隔离或文件访问边界。
- 安全 / 外部输入 / 凭证：原始消息、上下文、附件名、图片内容和需求正文可能含敏感信息；疑似 token、cookie、secret、私钥、生产凭证、客户隐私或内部敏感链接必须脱敏或人工确认，不进入公开需求单、群通知或审计明文。
- 限流 / 防滥用：自动关联、上下文读取、回溯入口和附件预览需要频率、数量和范围约束，避免批量抓取聊天记录、枚举来源对象或造成消息/文件服务压力。
- 审计 / 可追溯：关键动作需记录可追溯安全摘要，包括操作者、需求范围、来源会话类型、关联状态、过滤结果、失败原因类别和处理时间；审计不得记录明文敏感内容、完整私密正文或无权对象详情。

## 10. What-only 自检摘要

- 技术 How：无。本文只定义用户可见能力、范围、状态、权限、安全、限流、审计和验收口径；未写内部落地方案、服务结构、部署方式或研发细节。
- 引用核验：待脚本核验；全部引用均使用 `来源: <相对路径>#L<起>-L<止>` 格式。
- Label 完整性：通过；当前远端包含 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/im`、`area/bot-agent`。
- 状态真实性：当前 issue 仍为 `status/prd-drafting`；PRD 文件提交、评论回填和核验通过后应更新为唯一 `status/reviewing`。
- 风险提醒 / 待人工确认：无阻塞级风险；建议 Review 重点关注来源消息/附件可见性、无权提示防枚举、上下文范围、敏感信息脱敏、限流和审计。
