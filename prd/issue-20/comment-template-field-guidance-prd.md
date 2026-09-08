# PRD：需求单评论模板与字段引导能力

## 1. 背景与问题

Issue #20 反馈：群内反馈人在需求单评论或补充信息时，常只描述现象，容易遗漏使用场景、影响范围、复现步骤、期望效果、验收标准、相关消息链接或截图等关键信息。用户希望 Octo Server 在评论或补充信息入口，根据需求类型提供结构化字段引导，帮助反馈人一次性补齐关键上下文，降低产品运营负责人和需求管理专员反复追问成本。

现有源码显示，Octo 已具备结构化需求入口、Bot/Agent 消息触达、事件上下文、文件/截图、搜索/权限/限流/审计等相关基础能力；本 PRD 仅定义“评论模板与字段引导”的用户可见行为、状态提示、权限边界和验收标准，不定义内部实现方式。

- Feature Request 模板要求提交人填写问题动机、期望方案、相关组件和补充上下文，说明 Octo 已存在“按字段收集需求信息”的产品入口。来源: .github/ISSUE_TEMPLATE/feature_request.yml#L1-L8；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L25-L31；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L32-L45；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L46-L59
- Bot 事件返回消息编号、发送人、会话、时间和内容等上下文，可作为评论补充入口引用原始反馈场景的产品证据。来源: modules/bot_api/events.go#L37-L51
- Bot 发消息要求目标会话、会话类型和内容有效，说明模板提示回到群或会话时需要清晰目标与内容边界。来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L60-L70
- 文件模块已有认证下的预览、上传、预签名上传和下载入口，说明截图/附件可作为补充信息材料，但必须遵守访问边界。来源: modules/file/api.go#L83-L92；来源: modules/file/api.go#L93-L99；来源: modules/file/api.go#L101-L109；来源: modules/file/api.go#L111-L117；来源: modules/file/api.go#L118-L130
- 文件上传会校验上传路径和类型，并拒绝异常路径，说明附件/截图补充需要有用户可感知的失败提示和安全边界。来源: modules/file/api.go#L240-L254；来源: modules/file/api.go#L255-L269；来源: modules/file/api.go#L272-L279
- 搜索链路已在认证、Space、用户限流、搜索限流、审计和统一不可用提示下运行，说明评论引导中涉及消息链接、历史上下文或候选内容时必须受权限、限流和审计约束。来源: modules/messages_search/api.go#L122-L132；来源: modules/messages_search/api.go#L133-L139
- 搜索相关输入已有长度、数量和分页边界，说明字段引导应对长文本、过多对象和异常输入给出清晰限制。来源: modules/messages_search/validate.go#L11-L18
- 访问控制要求调用者只能搜索其已可读取的会话，且无权时不暴露对象是否存在。来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L24-L38；来源: modules/messages_search/authz.go#L39-L50
- 审计链路对关键词使用不透明摘要，避免把敏感输入明文写入共享运维通道。来源: modules/messages_search/audit.go#L12-L24
- Space 隔离规则要求用户数据读写不得跨 Space，Bot 操作需校验 ownership，Thread 操作需校验父会话访问。来源: .octospec/rules/space-isolation.md#L19-L31；来源: .octospec/rules/space-isolation.md#L34-L37
- 频率限制规则要求敏感或高频入口使用统一限流，避免滥用。来源: .octospec/rules/rate-limit.md#L19-L29

## 2. 目标与非目标

### 目标

- 在用户评论需求单或补充需求信息时，根据需求类型展示结构化字段引导。
- 引导字段覆盖背景、当前问题、期望效果、验收标准、影响范围、复现步骤、相关消息链接/截图/附件等关键上下文。
- 区分必填、建议填写和可选字段；不得把用户未确认内容自动补成事实。
- 支持用户按引导补充，也允许在合理场景下跳过非必填字段，并说明缺失影响。
- 对截图、附件、消息链接、来源群和敏感内容提供权限、可见性和脱敏边界。
- 为产品运营负责人和需求管理专员提供一致的信息质量判断口径，减少后续反复追问。

### 非目标

- 不替产品运营负责人判断需求是否 accepted、duplicate、wontfix、invalid 或最终优先级。
- 不强制所有评论都必须填完整模板；紧急补充、确认回复、Review 结论等场景应允许轻量评论。
- 不自动把用户未填写字段推断为事实，不自动生成未确认的复现步骤、影响范围或验收标准。
- 不展示无权消息、无权附件、跨 Space/群/Thread/Bot 的私密对象详情。
- 不定义内部实现方式、内部存储方式或部署方案。
- 不记录或外发 token、cookie、secret、私钥、生产凭证或完整私密消息正文。

## 3. 用户故事

### US-01：反馈人按字段补充需求信息
- 角色：作为群内反馈人或需求提交人
- 场景：当我在需求单评论区补充信息，但不确定应该提供哪些内容
- 诉求：希望系统按需求类型展示字段引导，提醒我填写背景、问题、期望效果、影响范围、复现步骤或验收标准
- 价值：以便我一次性提供更完整的信息，减少后续被反复追问
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L53-L59

### US-02：反馈人补充截图、附件和消息链接
- 角色：作为群内反馈人或需求提交人
- 场景：当需求需要截图、日志摘要、文件或原始群消息作为背景材料
- 诉求：希望字段引导告诉我哪些材料建议上传、哪些链接可引用、不可见或失效时如何补充
- 价值：以便产品运营负责人和需求管理专员能基于可核验材料判断需求范围
- 来源: modules/bot_api/events.go#L37-L51；来源: modules/file/api.go#L83-L92；来源: modules/file/api.go#L93-L99；来源: modules/file/api.go#L240-L254；来源: modules/file/api.go#L255-L269

### US-03：产品运营负责人减少追问并保持状态真实
- 角色：作为 Octo 产品运营负责人
- 场景：当需求单评论质量参差不齐，需要判断是否足够分诊或进入 PRD
- 诉求：希望评论补充能按类型呈现关键字段、缺失项和用户确认状态
- 价值：以便准确判断是否需要追问、是否进入 PRD，避免把信息不足的需求误判为已确认
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L32-L45；来源: modules/messages_search/audit.go#L12-L24

### US-04：需求管理专员基于完整补充材料写 PRD
- 角色：作为 Octo 需求管理专员
- 场景：当需求进入 `status/prd-drafting` 或 `status/rework`
- 诉求：希望看到结构化补充材料、缺失项、截图/消息链接状态和用户确认信息
- 价值：以便草拟 What-only PRD 时减少遗漏，明确待确认事项和风险边界
- 来源: modules/bot_api/events.go#L37-L51；来源: modules/messages_search/api.go#L122-L132；来源: modules/messages_search/api.go#L133-L139

### US-05：无权限或敏感内容获得安全提示
- 角色：作为普通群成员、Bot 调用方或运营人员
- 场景：当补充信息包含无权消息链接、跨范围附件、敏感字段或疑似凭证
- 诉求：希望系统给出可理解的安全提示，不泄露无权对象详情，也不公开敏感内容
- 价值：以便在提升材料质量的同时保护多租户、权限和安全边界
- 来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L24-L38；来源: modules/messages_search/authz.go#L39-L50；来源: modules/app_bot/app_bot.go#L156-L168；来源: modules/app_bot/app_bot.go#L171-L183；来源: .octospec/rules/space-isolation.md#L19-L31

## 4. 功能需求

### F-01-1 按需求类型展示评论字段引导
- 所属故事：US-01、US-03
- 需求描述：当用户在需求单评论或补充信息入口准备提交内容时，系统应根据需求类型展示匹配的字段引导。
- 业务规则：字段引导至少支持 feature、bug、待澄清/补充信息等常见类型；不同类型展示不同重点，例如 feature 关注背景、目标、期望效果和验收标准，bug 关注当前问题、影响范围、复现步骤和实际/期望表现。
- 边界场景：需求类型未知、标签缺失、类型冲突或状态不适合补充时，应展示通用引导或提示由产品运营负责人确认类型。
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L1-L8；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L32-L45

### F-01-2 字段必填、建议填写与可选边界
- 所属故事：US-01、US-03
- 需求描述：每个引导字段应清晰标识必填、建议填写或可选，并说明缺失后可能影响后续处理。
- 业务规则：必填字段缺失时应提示补充；建议填写字段缺失时允许继续但展示风险提示；可选字段不得阻塞提交。系统不得把用户未确认内容自动补成事实。
- 边界场景：用户只想回复“已确认”“收到”“Review 通过”等轻量评论时，应允许跳过模板或使用轻量模式，避免干扰协作。
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L25-L31；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L53-L59

### F-01-3 缺失信息提示与继续提交
- 所属故事：US-01、US-03、US-04
- 需求描述：当用户填写内容不完整时，系统应展示缺失项、建议补充方式和继续提交的后果。
- 业务规则：缺失提示应区分“必须补充后才能提交”和“可继续但可能需要后续追问”；继续提交时应记录哪些关键字段仍未确认。
- 边界场景：内容过短、字段为空、附件缺失、消息链接不可见、复现步骤不适用或用户明确无法提供时，应允许用户说明原因。
- 来源: modules/messages_search/validate.go#L11-L18；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L60-L70

### F-01-4 评论入口与群内提示
- 所属故事：US-01、US-02
- 需求描述：字段引导应能在需求单评论入口或群内补充信息场景中，以用户可读方式提示下一步填写内容。
- 业务规则：提示应明确要补充到哪个需求单、当前需求状态、建议填写字段和可跳过项；不得把提示误表现为已经提交成功或已经进入 PRD。
- 边界场景：目标需求单不存在、已关闭、无权评论、状态已变化、重复点击或多人同时补充时，应给出明确原因和可恢复建议。
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L60-L70；来源: modules/bot_api/events.go#L37-L51

### F-01-5 截图、附件与消息链接引导
- 所属故事：US-02、US-05
- 需求描述：模板应提示用户在需要时补充截图、附件、相关文件或来源消息链接，并显示当前材料的可见/不可见/待补充状态。
- 业务规则：截图、附件和消息链接只作为需求背景材料；无权、失效、跨范围或不可验证材料应展示安全提示，不泄露对象详情。
- 边界场景：附件过大、路径异常、格式不支持、链接失效、消息被删除/撤回、来源群不可访问或跨 Space 引用时，应提示重新上传、重新选择来源或改用文字说明。
- 来源: modules/file/api.go#L83-L92；来源: modules/file/api.go#L93-L99；来源: modules/file/api.go#L101-L109；来源: modules/file/api.go#L111-L117；来源: modules/file/api.go#L118-L130；来源: modules/file/api.go#L240-L254；来源: modules/file/api.go#L255-L269；来源: modules/file/api.go#L272-L279；来源: modules/bot_api/events.go#L37-L51

### F-01-6 权限与可见性边界
- 所属故事：US-02、US-04、US-05
- 需求描述：字段引导、已填内容、附件、消息链接和历史评论只展示给有权用户，不得通过模板或缺失提示暴露无权对象。
- 业务规则：普通反馈人只能看到其有权范围内的需求和材料；产品运营负责人按其有权范围查看和追问；需求管理专员只在明确指派、进入 PRD 或返工时使用材料。
- 边界场景：跨 Space、跨群、跨 Thread、跨 Bot、非成员、退群、角色变化、来源不可见时，不返回具体对象详情、群名、成员、附件或消息正文。
- 来源: .octospec/rules/space-isolation.md#L19-L31；来源: .octospec/rules/space-isolation.md#L34-L37；来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L24-L38；来源: modules/messages_search/authz.go#L39-L50；来源: modules/app_bot/app_bot.go#L156-L168；来源: modules/app_bot/app_bot.go#L171-L183

### F-01-7 敏感信息识别与脱敏提示
- 所属故事：US-04、US-05
- 需求描述：当用户在字段中输入疑似凭证、隐私数据、内部链接或敏感截图时，系统应提示脱敏或人工确认。
- 业务规则：敏感提示应说明“不要公开提交明文敏感信息”，并引导用户改写为脱敏摘要；必要时交由产品运营负责人或人工确认。
- 边界场景：用户输入疑似 token、cookie、secret、私钥、生产凭证、客户隐私或内部地址时，不应在群消息、公开评论或审计摘要中复述明文内容。
- 来源: modules/messages_search/audit.go#L12-L24

### F-01-8 限流、防滥用与输入容量提示
- 所属故事：US-01、US-05
- 需求描述：字段引导、材料上传、消息链接校验和评论提交应具备用户可感知的频率、数量和长度边界。
- 业务规则：触发频率、数量、内容长度或异常输入限制时，应给出明确原因和可恢复建议；失败不得被误提示为补充成功。
- 边界场景：短时间大量提交、重复上传、超长评论、异常链接、无意义内容或自动化刷屏时，应限制并保护正常需求处理。
- 来源: .octospec/rules/rate-limit.md#L19-L29；来源: modules/messages_search/api.go#L122-L132；来源: modules/messages_search/api.go#L133-L139；来源: modules/messages_search/validate.go#L11-L18

### F-01-9 审计与追溯
- 所属故事：US-03、US-04、US-05
- 需求描述：字段引导展示、用户填写、跳过字段、附件/消息链接补充、敏感提示、权限拒绝和提交结果应有可追溯安全摘要。
- 业务规则：审计摘要应能说明操作者、需求单范围、动作、字段完成度、材料状态和结果；不得记录明文敏感内容、完整私密正文或无权对象详情。
- 边界场景：当用户撤回、修改、重复提交或多人同时补充时，应能追溯最终以哪个补充内容和确认状态为准。
- 来源: modules/messages_search/audit.go#L12-L24

### F-01-10 交接与质量口径
- 所属故事：US-03、US-04
- 需求描述：产品说明和交接摘要应明确字段引导的适用范围、字段含义、缺失项、用户确认状态和待确认问题。
- 业务规则：进入 PRD 前，需求管理专员应能看到结构化补充摘要和缺失项；信息不足时最多提出 3 个关键待确认问题，不应强行生成完整结论。
- 边界场景：用户跳过关键字段、类型不清、附件不可见、状态冲突或负责人尚未裁定时，应标记待确认，并由产品运营负责人或反馈人确认。
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L53-L59；来源: modules/bot_api/events.go#L37-L51

## 5. 状态与提示

- 显示字段引导：系统已根据需求类型展示建议补充字段。
- 必填缺失：仍缺少进入后续处理所需的关键信息，需要补充后再提交。
- 建议补充：当前可继续提交，但缺失内容可能导致后续追问或处理延迟。
- 可选跳过：该字段对当前场景非必需，用户可跳过。
- 已补充：用户已提交结构化补充内容，展示补充成功和后续处理提示。
- 材料不可见/已失效：截图、附件或消息链接当前不可验证，提示重新上传或改用文字说明。
- 无权限：当前操作者无权查看或补充该需求、附件、消息链接或来源上下文，不暴露对象详情。
- 疑似敏感信息：提示用户脱敏后再提交，必要时转产品运营负责人或人工确认。
- 状态已变化：目标需求单状态已变化，用户应按当前状态补充或联系负责人确认。

## 6. 验收标准

- AC-01：当用户在需求单评论或补充信息入口操作时，能看到与需求类型匹配的字段引导。
- AC-02：字段引导覆盖背景、当前问题、期望效果、验收标准、影响范围、复现步骤、相关消息链接/截图/附件等关键项，并能按类型差异展示。
- AC-03：每个字段能清晰区分必填、建议填写和可选；系统不会把用户未确认内容自动补成事实。
- AC-04：当必填字段缺失时，用户看到缺失项和补充建议；当只缺建议字段时，用户可继续提交并看到可能影响。
- AC-05：用户可以上传或引用有权范围内的截图、附件、文件或消息链接，并看到材料是否可见、已失效或待补充。
- AC-06：当附件过大、路径异常、格式不支持、消息链接不可见、来源群不可访问或跨 Space 引用时，用户看到安全提示和可恢复操作。
- AC-07：无权用户不能通过模板、缺失提示、附件状态、消息链接状态或评论入口推断无权对象是否存在。
- AC-08：疑似敏感信息不会被公开复述到群消息、公开评论或审计摘要；用户能看到脱敏或人工确认提示。
- AC-09：当用户只做轻量确认、Review 回复或状态确认时，可以跳过完整模板，不被强制填写无关字段。
- AC-10：当触发频率、数量、内容长度或异常输入限制时，用户看到明确原因和可恢复建议，且不会误提示为补充成功。
- AC-11：产品运营负责人和需求管理专员能看到字段完成度、缺失项、材料状态和用户确认状态，用于分诊、PRD 草拟或返工判断。
- AC-12：产品说明覆盖适用入口、需求类型匹配、字段含义、必填/建议/可选边界、跳过规则、附件/消息链接处理、敏感脱敏、权限与审计口径。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/im`、`area/bot-agent`
- V5 only：未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及用户补充内容、截图/附件、消息链接、敏感信息、跨 Space/群/Thread/Bot 可见性、限流和审计，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 首版需求类型模板是否仅覆盖 feature / bug / 待澄清，还是包含 duplicate 申诉、验收反馈、Review 打回补充等类型。
2. [待确认] 每类模板的必填字段是否由产品运营负责人统一维护，还是允许按 Space / 群 / 项目配置。
3. [待确认] 评论补充时的截图/附件数量和大小提示采用统一限制，还是按需求类型展示不同建议。

## 9. 五类风险检查

- 多租户 / Space 隔离：字段引导、附件、消息链接、来源上下文和历史评论必须按当前操作者有权 Space / 群 / Thread / Bot 范围展示；无权对象不展示详情，也不泄露是否存在。
- 权限 / ownership：评论、补充、跳过字段、引用材料和查看模板完成度必须有明确操作者边界；产品运营负责人负责最终分诊和状态裁定，需求管理专员不越权拍板。
- 安全 / 外部输入 / 凭证：评论正文、截图、附件、链接可能包含敏感信息；疑似 token、cookie、secret、私钥或生产凭证必须脱敏或人工确认，不进入公开群消息、issue 评论或审计明文。
- 限流 / 防滥用：字段引导、附件补充、消息链接校验和评论提交需有频率、数量、长度和异常输入边界，避免刷屏、枚举或恶意内容影响正常需求处理。
- 审计 / 可追溯：关键动作需记录可追溯安全摘要，包括操作者、需求单范围、字段完成度、材料状态、跳过原因和结果；审计不得记录明文敏感内容或无权对象详情。

## 10. What-only 自检摘要

- 技术 How：通过；PRD 仅定义用户可见能力、状态、提示、权限、风险和验收，不写内部实现方式、内部存储方式或部署方案。
- 引用核验：通过；引用均来自只读目标仓 `Mininglamp-OSS/octo-server`，需通过引用核验脚本检查。
- Label 完整性：通过；Issue #20 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/im`、`area/bot-agent`。
- 状态真实性：通过；产品运营负责人已将 Issue #20 标记为 `status/prd-drafting`，本 PRD 完成后应流转为唯一 `status/reviewing`，由产品运营负责人 Review。
- 风险提醒 / 待人工确认：有；重点是类型模板范围、必填字段维护方式、截图/附件限制、跨 Space/群/Thread/Bot 可见性、敏感信息脱敏、限流和审计。
