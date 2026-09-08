# PRD：需求单重复检测与相似需求提醒能力

## 1. 背景与问题

Issue #19 反馈：群内反馈人在提交新需求单前，希望系统能根据标题和描述提示可能相似的历史需求，展示可能重复的需求单编号、当前状态和负责人/跟进人，并允许用户选择复用已有需求、补充评论或继续创建新需求。该能力目标是降低重复创建需求单的概率，同时避免系统越权自动裁定 duplicate。

现有源码显示，Octo 已具备需求反馈、Bot/Agent 触达、会话上下文读取、消息搜索、权限隔离、限流和审计等相关基础能力；本 PRD 仅定义“提交前相似需求提醒”的用户可见产品行为、权限边界、风险约束和验收标准，不定义内部实现方案。

- Feature Request 模板要求提交人描述问题、期望方案、相关组件和补充上下文，说明“提交前材料结构化”是现有需求入口的用户可见形态。来源: .github/ISSUE_TEMPLATE/feature_request.yml#L1-L8；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L31；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L32-L45；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L46-L59
- Bot 事件可携带消息编号、发送人、会话、时间和内容等上下文，适合作为群内需求入口识别和反馈链路的产品证据。来源: modules/bot_api/events.go#L37-L51
- Bot 发送消息要求目标会话、会话类型和内容有效，可作为相似提醒结果回到用户所在会话时的产品约束参考。来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L60-L70
- 消息搜索链路已有认证、Space、用户限流、搜索限流、审计和统一不可用提示等安全链路，说明搜索/相似提示类能力需要受权限、限流和审计约束。来源: modules/messages_search/api.go#L122-L132；来源: modules/messages_search/api.go#L133-L139
- 搜索输入已有关键词长度、筛选数量、分页和空搜索保护等用户可感知边界，说明相似匹配入口需要明确输入、数量和异常提示边界。来源: modules/messages_search/validate.go#L11-L18；来源: modules/messages_search/validate.go#L88-L99；来源: modules/messages_search/validate.go#L100-L103；来源: modules/messages_search/validate.go#L105-L112；来源: modules/messages_search/validate.go#L114-L122；来源: modules/messages_search/validate.go#L123-L132；来源: modules/messages_search/validate.go#L135-L145；来源: modules/messages_search/validate.go#L147-L154；来源: modules/messages_search/validate.go#L156-L168；来源: modules/messages_search/validate.go#L170-L183；来源: modules/messages_search/validate.go#L214-L225；来源: modules/messages_search/validate.go#L227-L235
- 搜索访问控制要求调用者只能搜索其已可读取的会话，且无权时不暴露对象是否存在。来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L24-L38；来源: modules/messages_search/authz.go#L39-L50
- 群和 Thread 访问需校验群成员与 Thread 状态，不能通过搜索或相似提示绕过既有读路径边界。来源: modules/messages_search/authz.go#L254-L260；来源: modules/messages_search/authz.go#L261-L273；来源: modules/messages_search/authz.go#L274-L287；来源: modules/messages_search/authz.go#L289-L299；来源: modules/messages_search/authz.go#L300-L313；来源: modules/messages_search/authz.go#L314-L327
- 审计链路使用不透明摘要记录关键词，避免把敏感检索词明文写入共享运维通道。来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L134-L142；来源: modules/messages_search/audit.go#L144-L151；来源: modules/messages_search/audit.go#L167-L174
- 仓库规则明确用户数据访问必须执行 Space 隔离和 ownership 校验，跨 Space 读写属于核心安全边界。来源: .octospec/rules/space-isolation.md#L19-L31；来源: .octospec/rules/space-isolation.md#L34-L37
- 仓库规则要求按统一方式做访问频率限制，避免高频请求造成滥用。来源: .octospec/rules/rate-limit.md#L19-L29

## 2. 目标与非目标

### 目标

- 在用户正式创建需求单前，基于用户填写的标题、背景/描述和可见上下文，提示可能相似或疑似重复的历史需求。
- 相似提醒向用户展示其有权查看的需求单编号、标题摘要、当前状态、负责人/跟进人和相似原因摘要。
- 用户可以基于提醒选择：复用已有需求、在已有需求下补充评论、继续创建新需求，或取消本次提交。
- 相似提醒必须明确“仅辅助判断”，不自动关闭、合并、改状态或裁定 duplicate。
- 相似提醒必须遵守 Space、群、Thread、Bot、用户角色和需求池可见性边界，不泄露无权需求、私密内容或跨空间信息。
- 为产品运营负责人和需求管理专员提供清晰交接口径：哪些用户选择了复用，哪些继续创建，哪些疑似重复仍需人工确认。

### 非目标

- 不替产品运营负责人做 Duplicate / Wontfix / Invalid / Accepted / Done 等最终状态裁定。
- 不承诺自动合并需求、自动关闭 issue、自动迁移评论或自动变更负责人。
- 不展示无权需求详情、无权群/Thread 名称、无权附件、无权消息正文或隐藏对象是否存在。
- 不把相似提醒结果作为唯一真相；低相似度、语义误判、同词不同义均需允许用户继续创建。
- 不定义内部实现方式、内部存储方式或部署方案。
- 不在审计、日志、群消息或 issue 评论中记录明文 token、cookie、secret、私钥或生产凭证。

## 3. 用户故事

### US-01：反馈人在提交前发现可能重复需求
- 角色：作为群内反馈人或需求提交人
- 场景：当我准备提交一个新需求，并已填写标题和描述
- 诉求：希望系统在正式创建前提示可能相似的历史需求及当前处理状态
- 价值：以便我优先复用已有需求或补充评论，减少重复单据和沟通成本
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L1-L8；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L31；来源: modules/messages_search/validate.go#L170-L183

### US-02：反馈人选择复用、补充或继续创建
- 角色：作为群内反馈人或需求提交人
- 场景：当系统提示一个或多个可能相似需求
- 诉求：希望看到每个候选项的关键信息和可选动作，并能明确选择后续路径
- 价值：以便我不被系统强制拦截，同时能把补充信息放到更合适的位置
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L60-L70；来源: modules/bot_api/events.go#L37-L51

### US-03：产品运营负责人识别疑似重复但不被系统越权裁定
- 角色：作为 Octo 产品运营负责人
- 场景：当多个需求主题相似但业务背景、优先级或影响范围可能不同
- 诉求：希望系统给出相似提醒和用户选择记录，但最终 duplicate / 继续拆分仍由负责人判断
- 价值：以便兼顾去重效率和需求真实性，避免误合并或误关闭
- 来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L24-L38；来源: modules/messages_search/authz.go#L39-L50；来源: modules/messages_search/audit.go#L12-L24

### US-04：无权限或跨范围候选项不泄露
- 角色：作为普通群成员、Bot 调用方或运营人员
- 场景：当相似历史需求位于我无权查看的 Space、群、Thread、Bot 或私密范围
- 诉求：希望系统只展示安全提示或不展示该候选，不暴露无权对象详情
- 价值：以便在提升去重体验的同时保护多租户和会话隐私
- 来源: .octospec/rules/space-isolation.md#L19-L31；来源: .octospec/rules/space-isolation.md#L34-L37；来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L24-L38；来源: modules/messages_search/authz.go#L39-L50；来源: modules/messages_search/authz.go#L254-L260；来源: modules/messages_search/authz.go#L261-L273；来源: modules/messages_search/authz.go#L274-L287；来源: modules/messages_search/authz.go#L289-L299；来源: modules/messages_search/authz.go#L300-L313；来源: modules/messages_search/authz.go#L314-L327

### US-05：需求管理专员基于用户选择继续闭环
- 角色：作为 Octo 需求管理专员
- 场景：当用户选择继续创建，或产品运营负责人确认该需求进入 PRD
- 诉求：希望 issue 中保留相似提醒结果、用户选择和人工确认状态
- 价值：以便后续草拟 PRD、Review Gate 和风险检查时知道是否已排查重复需求
- 来源: modules/messages_search/audit.go#L134-L142；来源: modules/messages_search/audit.go#L144-L151；来源: modules/messages_search/audit.go#L167-L174；来源: modules/bot_api/events.go#L37-L51

## 4. 功能需求

### F-01-1 提交前相似需求提醒
- 所属故事：US-01、US-03
- 需求描述：当用户准备正式创建新需求单时，系统应基于标题、背景/描述和用户有权上下文提示可能相似的历史需求。
- 业务规则：提醒应发生在正式创建前；若未填写足够内容，应提示“信息不足，无法判断相似需求”并允许用户补充或继续创建。
- 展示内容：每个候选项应展示用户有权查看的需求单编号、标题摘要、当前状态、负责人/跟进人、最近更新时间和相似原因摘要。
- 边界场景：标题过短、描述为空、输入超长、特殊字符、仅通用词、相似结果为空或相似结果过多时，应给出清晰提示，不阻断用户合理提交。
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: modules/messages_search/validate.go#L11-L18；来源: modules/messages_search/validate.go#L170-L183；来源: modules/messages_search/validate.go#L214-L225；来源: modules/messages_search/validate.go#L227-L235

### F-01-2 候选结果排序与数量边界
- 所属故事：US-01、US-02
- 需求描述：相似候选应以用户可理解的顺序展示，并控制展示数量，避免信息过载。
- 业务规则：候选结果应优先展示更可能相关、状态更需要关注、用户更有权处理或最近有更新的需求；页面或消息中应说明“以下为可能相似需求，不代表系统已判定重复”。
- 边界场景：候选结果较多时，只展示有限数量并提供查看更多入口；候选结果不足以判断时，应提示用户可继续创建。
- 来源: modules/messages_search/validate.go#L88-L99；来源: modules/messages_search/validate.go#L100-L103；来源: modules/messages_search/validate.go#L105-L112；来源: modules/messages_search/validate.go#L114-L122；来源: modules/messages_search/validate.go#L123-L132；来源: modules/messages_search/validate.go#L135-L145；来源: modules/messages_search/validate.go#L147-L154；来源: modules/messages_search/validate.go#L156-L168；来源: modules/messages_search/validate.go#L214-L225；来源: modules/messages_search/validate.go#L227-L235

### F-01-3 用户选择路径
- 所属故事：US-02、US-05
- 需求描述：用户看到相似提醒后，可以选择复用已有需求、补充评论、继续创建新需求或取消本次提交。
- 业务规则：选择复用时，应引导用户查看已有需求及当前状态；选择补充评论时，应明确评论会追加到哪个已有需求；选择继续创建时，应保留“已查看相似提醒但仍继续”的记录；选择取消时，不应创建正式需求单。
- 边界场景：已有需求已关闭、已完成、状态存疑、负责人缺失、用户无评论权限、用户重复点击或多人同时操作时，应给出明确原因和下一步建议。
- 来源: modules/bot_api/send.go#L36-L49；来源: modules/bot_api/send.go#L53-L60；来源: modules/bot_api/send.go#L60-L70；来源: modules/bot_api/events.go#L37-L51

### F-01-4 不自动裁定 duplicate
- 所属故事：US-03、US-05
- 需求描述：相似提醒只能辅助用户和产品运营负责人判断，不得自动把新需求标记为 duplicate、关闭、合并或改变优先级。
- 业务规则：系统文案应区分“可能相似”和“已裁定重复”；最终 duplicate、继续拆分、wontfix、invalid、accepted 等状态仍由产品运营负责人或人工规则确认。
- 边界场景：标题高度相似但背景不同、同一痛点影响不同角色、相同附件但需求目标不同、历史需求已拒绝但用户提出新证据时，不得自动阻断继续创建。
- 来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L24-L38；来源: modules/messages_search/authz.go#L39-L50；来源: modules/messages_search/audit.go#L12-L24

### F-01-5 权限与可见性边界
- 所属故事：US-04
- 需求描述：相似提醒只展示当前操作者有权查看的需求和上下文，不得通过候选项暴露跨 Space、跨群、跨 Thread、跨 Bot 或私密对象。
- 业务规则：无权候选不展示详情；如需要提示存在不可展示内容，只能使用不泄露对象身份的安全文案。用户不能通过标题、编号、状态、负责人、附件、消息链接或结果数量推断无权对象是否存在。
- 边界场景：用户退群、群成员状态异常、Thread 已删除、私聊关系不满足、Bot ownership 不匹配、Space 切换、外部群或历史消息不可见时，应按不可访问处理。
- 来源: .octospec/rules/space-isolation.md#L19-L31；来源: .octospec/rules/space-isolation.md#L34-L37；来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L24-L38；来源: modules/messages_search/authz.go#L39-L50；来源: modules/messages_search/authz.go#L254-L260；来源: modules/messages_search/authz.go#L261-L273；来源: modules/messages_search/authz.go#L274-L287；来源: modules/messages_search/authz.go#L289-L299；来源: modules/messages_search/authz.go#L300-L313；来源: modules/messages_search/authz.go#L314-L327；来源: modules/app_bot/app_bot.go#L156-L168；来源: modules/app_bot/app_bot.go#L171-L183

### F-01-6 状态、负责人和来源展示
- 所属故事：US-01、US-02、US-03
- 需求描述：相似提醒应展示每个可见候选需求的当前状态、负责人/跟进人和来源摘要，帮助用户判断下一步。
- 业务规则：状态展示必须使用当前真实状态，不能把“已接受、已完成、重复、无效、待澄清、PRD 草拟中、Review 中”等状态混用；负责人缺失时应显示“待确认”或“暂无负责人”。
- 边界场景：状态刚刚变化、负责人被移除、历史评论与当前标签冲突、需求已关闭或重开时，应以当前可核验状态为准，并提示可能需要产品运营负责人确认。
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L32-L45；来源: modules/bot_api/events.go#L37-L51

### F-01-7 误判处理与人工确认
- 所属故事：US-02、US-03、US-05
- 需求描述：系统应允许用户说明“不是重复”的原因，并支持产品运营负责人后续人工确认。
- 业务规则：当用户选择继续创建时，应允许填写差异点；当产品运营负责人确认重复或不重复时，后续状态和说明应以负责人裁定为准。
- 边界场景：相似提醒误召回、漏召回、多个候选均部分相似、历史需求状态不清、用户补充了新证据时，应保留人工确认入口。
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L134-L142；来源: modules/messages_search/audit.go#L144-L151；来源: modules/messages_search/audit.go#L167-L174

### F-01-8 限流、防滥用与容量提示
- 所属故事：US-01、US-04
- 需求描述：相似检测、候选查看更多、补充评论和继续创建等动作应有用户可感知的频率、数量和内容长度边界。
- 业务规则：触发频率、候选数量、内容长度或异常输入限制时，应展示明确原因和可恢复建议；限制失败不得误报为创建成功、评论成功或复用成功。
- 边界场景：短时间大量提交相似请求、恶意构造超长描述、批量枚举关键词、重复点击、自动化刷屏、异常来源消息或附件时，应限制并保护正常需求流。
- 来源: .octospec/rules/rate-limit.md#L19-L29；来源: modules/messages_search/api.go#L122-L132；来源: modules/messages_search/api.go#L133-L139；来源: modules/messages_search/validate.go#L11-L18；来源: modules/messages_search/validate.go#L88-L99；来源: modules/messages_search/validate.go#L100-L103；来源: modules/messages_search/validate.go#L105-L112；来源: modules/messages_search/validate.go#L114-L122；来源: modules/messages_search/validate.go#L123-L132；来源: modules/messages_search/validate.go#L135-L145；来源: modules/messages_search/validate.go#L147-L154；来源: modules/messages_search/validate.go#L156-L168

### F-01-9 审计与敏感信息脱敏
- 所属故事：US-03、US-04、US-05
- 需求描述：相似检测触发、候选展示、用户选择、继续创建、复用、补充评论、权限拒绝和异常限制等关键动作应有可追溯安全摘要。
- 业务规则：审计摘要应能说明操作者、所在范围、动作、候选数量、用户选择和结果；不得记录明文搜索词、完整私密需求正文、token、cookie、secret、私钥、生产凭证或无权对象详情。
- 边界场景：用户输入疑似凭证、私密客户信息、内部链接或敏感附件时，应提示脱敏或人工确认；疑似敏感内容不得公开写入群消息或 issue 评论。
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L134-L142；来源: modules/messages_search/audit.go#L144-L151；来源: modules/messages_search/audit.go#L167-L174

### F-01-10 交接与运营口径
- 所属故事：US-03、US-05
- 需求描述：当用户最终继续创建新需求或补充到已有需求后，系统应保留相似检测摘要和用户选择，供产品运营负责人和需求管理专员后续判断。
- 业务规则：交接摘要应区分“系统提示相似”“用户选择继续”“用户补充评论”“负责人裁定重复/不重复”；需求管理专员只基于当前真实状态和负责人裁定补 PRD 或返工。
- 边界场景：相似检测失败、候选结果为空、用户跳过提醒、负责人尚未裁定或状态冲突时，应标记待确认，不应伪造闭环结论。
- 来源: modules/bot_api/events.go#L37-L51；来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L134-L142；来源: modules/messages_search/audit.go#L144-L151；来源: modules/messages_search/audit.go#L167-L174

## 5. 状态与提示

- 正在检查相似需求：系统正在基于已填写内容查找可能相似项；如耗时或失败，应允许用户稍后重试或继续创建。
- 未发现明显相似需求：当前未发现可见范围内的明显相似项；用户仍可继续创建。
- 发现可能相似需求：展示可见候选项，并提示“仅供参考，不代表已判定重复”。
- 信息不足：标题或描述不足以判断相似需求，提示用户补充关键背景、目标或差异点。
- 已选择复用：用户选择查看或复用已有需求，系统不创建新的正式需求单。
- 已补充到已有需求：用户选择把补充信息追加到某个有权需求，并看到追加结果或失败原因。
- 确认继续创建：用户已查看相似提醒但仍确认创建新需求；后续由产品运营负责人分诊。
- 无权限或不可见：当前操作者无权查看某些候选、来源或附件；不展示对象详情，也不说明隐藏对象数量。
- 相似检测受限：因频率、内容长度、候选数量、系统繁忙或安全策略限制，系统给出可恢复提示。
- 疑似敏感信息：提示用户脱敏后再继续，必要时交由产品运营负责人或人工确认。

## 6. 验收标准

- AC-01：当用户准备创建新需求且填写了标题和描述时，正式创建前能看到相似需求检查结果或明确的检查失败/跳过原因。
- AC-02：当发现可见相似需求时，用户能看到需求编号、标题摘要、当前状态、负责人/跟进人、最近更新时间和相似原因摘要。
- AC-03：相似提醒文案明确说明“可能相似/疑似重复，仅供判断”，不会把候选自动裁定为 duplicate、wontfix、invalid 或关闭。
- AC-04：用户可以选择复用已有需求、补充评论、继续创建新需求或取消提交，并能看到每个动作的成功、失败或下一步提示。
- AC-05：当用户选择继续创建时，系统保留“已提示相似需求但用户确认继续”的摘要，供后续分诊和 PRD 判断参考。
- AC-06：当相似候选处于无权 Space、无权群、无权 Thread、无权 Bot、私密或已不可见范围时，用户不能看到候选详情，也不能通过提示推断对象是否存在。
- AC-07：当历史需求状态、负责人或评论信息发生变化时，相似提醒展示当前可核验状态；无法确认时标记“待确认”，不伪造最终状态。
- AC-08：当标题过短、描述为空、输入超长、结果过多、相似检测失败或频率受限时，用户看到明确原因和可恢复操作，且不会被误提示为创建成功或评论成功。
- AC-09：当用户认为候选不是重复需求时，可以说明差异点并继续创建；产品运营负责人后续可基于差异点做最终裁定。
- AC-10：相似检测、候选展示、用户选择、权限拒绝和异常限制有可追溯安全摘要，且不记录明文敏感词、完整私密正文、凭证或无权对象详情。
- AC-11：产品说明覆盖触发时机、候选展示字段、用户可选动作、权限边界、误判处理、限流边界、审计脱敏和“最终裁定归产品运营负责人”的口径。
- AC-12：需求管理专员在后续 PRD 或 Review Gate 中能看到相似检测摘要和用户选择，但不据此越权裁定 duplicate 或最终状态。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/prd-drafting`；PRD 交付后应更新为唯一 `status/reviewing`
- area/*：`area/im`、`area/bot-agent`
- V5 only：未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及相似搜索、跨 Space/群/Thread/Bot 可见性、疑似重复裁定边界、限流与审计脱敏，Review 应重点核验。

## 8. 待确认事项

1. [待确认] 相似提醒默认展示候选数量上限建议为 3、5 还是由产品运营负责人按入口配置。
2. [待确认] “负责人/跟进人”在没有明确 assignee 时，是否显示产品运营负责人、最后处理人，还是统一显示“待确认”。
3. [待确认] 用户选择“补充评论”后，是否允许附带截图/文件，还是本期仅支持文字补充。

## 9. 五类风险检查

- 多租户 / Space 隔离：相似候选必须按当前操作者有权 Space、群、Thread、Bot、需求池范围过滤；无权对象不展示详情，也不泄露是否存在。
- 权限 / ownership：复用已有需求、补充评论、继续创建、取消提交和查看候选详情均需遵守当前用户/运营角色权限；系统不替产品运营负责人做最终 duplicate 或状态仲裁。
- 安全 / 外部输入 / 凭证：标题、描述、评论、截图、附件和链接可能含敏感内容；疑似 token、cookie、secret、私钥或生产凭证必须脱敏或人工确认，不进入公开群消息、issue 评论或日志。
- 限流 / 防滥用：相似检测、候选查看更多、补充评论和继续创建存在枚举与刷屏风险；需有频率、数量、长度和异常输入提示边界，保障正常提交流程。
- 审计 / 可追溯：关键动作需记录可追溯安全摘要，包括操作者、范围、动作、候选数量、用户选择和结果；审计不得记录明文敏感词、完整私密正文或无权对象详情。

## 10. What-only 自检摘要

- 技术 How：通过；PRD 仅定义用户可见能力、提示、状态、权限、风险和验收，不写内部实现方式、内部存储方式或部署方案。
- 引用核验：通过；引用均来自只读目标仓 `Mininglamp-OSS/octo-server`，已通过引用核验脚本检查。
- Label 完整性：通过；Issue #19 当前具备 `type/feature`、`priority/P2`、`status/prd-drafting`、`area/im`、`area/bot-agent`。
- 状态真实性：通过；产品运营负责人已将 Issue #19 标记为 `status/prd-drafting`，本 PRD 完成后应流转为唯一 `status/reviewing`，由产品运营负责人 Review。
- 风险提醒 / 待人工确认：有；重点是跨 Space/群/Thread/Bot 可见性、误判不自动裁定、负责人展示口径、候选数量上限、补充评论附件范围、限流和审计脱敏。
