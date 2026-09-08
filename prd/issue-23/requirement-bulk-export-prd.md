# PRD：需求单批量导出能力

## 1. 背景与问题

Issue #23 反馈：当一个阶段内创建大量需求单时，后续评审、周报或复盘需要逐个打开查看，手工整理成本较高。用户希望 Octo Server 支持按常用条件筛选后一键导出需求单列表，降低阶段性评审、周报整理和复盘时的汇总成本。

现有源码与文档显示，Octo 已有标准化需求/缺陷信息采集模板、会话内筛选/分页/排序的产品经验、文件导出/下载相关能力、Space 隔离、限流和审计约束。本 PRD 仅定义“需求单批量导出”的用户可见能力、筛选范围、导出内容、权限边界、状态提示和验收标准，不定义内部实现方式。

- Feature 模板要求提交人说明问题动机、期望方案、相关组件和补充上下文，说明需求单材料本身具有结构化整理诉求。来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L32-L45；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L53-L59
- Bug 模板包含描述、复现、期望、实际、版本、组件和严重程度等字段，说明需求/缺陷条目存在多字段汇总和评审场景。来源: .github/ISSUE_TEMPLATE/bug_report.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L29-L42；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L43-L49；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L50-L63；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L64-L74
- 会话搜索能力已对筛选条件、时间范围、排序、页大小和游标边界进行约束，可作为“批量列表能力需有范围边界”的产品证据。来源: modules/messages_search/validate.go#L88-L99；来源: modules/messages_search/validate.go#L100-L104；来源: modules/messages_search/validate.go#L135-L145；来源: modules/messages_search/validate.go#L147-L160；来源: modules/messages_search/validate.go#L214-L224
- 会话搜索路由统一挂鉴权、Space 校验、共享限流、搜索限流和审计，说明涉及列表读取的能力必须纳入权限、限流和可追溯边界。来源: modules/messages_search/api.go#L122-L131；来源: modules/messages_search/api.go#L132-L139；来源: modules/messages_search/api.go#L152-L164
- 会话搜索访问控制要求调用者只能访问自己已经可读的会话，且无权时不泄露对象是否存在。来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L44-L50
- 文件模块支持认证后的文件上传、下载入口和常见文档/数据文件类型；`.xlsx`、`.csv`、`.tsv` 等格式属于当前文件能力允许范围。来源: modules/file/api.go#L83-L90；来源: modules/file/api.go#L91-L99；来源: modules/file/api.go#L985-L990；来源: modules/file/const.go#L179-L191；来源: modules/file/const.go#L197-L204；来源: modules/file/const.go#L205-L214
- Space 隔离规则要求访问用户数据必须执行隔离和 ownership 检查，读写不得跨 Space。来源: .octospec/rules/space-isolation.md#L21-L31；来源: .octospec/rules/space-isolation.md#L34-L37
- 限流规则要求服务端入口具备请求频率边界，不应出现无约束批量读取。来源: .octospec/rules/rate-limit.md#L19-L29
- 审计日志对敏感搜索词使用不可逆摘要而非明文，说明批量导出和筛选记录也应避免记录敏感内容明文。来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L62-L70

## 2. 目标与非目标

### 目标

- 支持有权用户按时间范围、创建人、状态、优先级、标签等常用条件筛选需求单列表。
- 支持对筛选后的需求单列表执行一键导出，用于阶段性评审、周报整理、复盘、线下审阅和流转。
- 导出结果至少包含标题、编号、状态、负责人、创建时间、最近更新时间和摘要，并明确“负责人”字段首版取值规则。
- 导出内容仅包含当前用户有权查看的需求单，不泄露无权限、私密或跨 Space / 群 / Thread / Bot 范围的数据。
- 对导出格式、字段口径、首版数量上限、文件有效期、空结果、超量、失败、敏感内容、限流和审计建立清晰产品口径。

### 非目标

- 不改变现有需求单创建、分诊、PRD、Review、验收和状态闭环流程。
- 不自动生成周报、复盘结论、优先级裁定或最终状态裁定。
- 不替产品运营负责人决定需求是否进入需求池、是否 accepted、duplicate、wontfix、invalid 或 blocked。
- 不定义内部实现方式、研发结构、部署方案或具体技术字段。
- 不导出当前用户无权查看的需求详情、私密评论、不可见附件、原始聊天全文或跨范围对象信息。
- 不在导出文件、通知、评论、日志或审计中明文输出 token、cookie、secret、私钥或生产凭证。

## 3. 用户故事

### US-01：产品运营负责人按条件导出阶段需求
- 角色：作为 Octo 产品运营负责人
- 场景：当一个阶段内产生大量需求单，需要做评审、周报或复盘
- 诉求：希望按时间范围、创建人、状态、优先级、标签等条件筛选后一键导出需求单列表
- 价值：以便快速形成可离线审阅和流转的阶段性清单
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: modules/messages_search/validate.go#L88-L99；来源: modules/messages_search/validate.go#L100-L104；来源: modules/messages_search/validate.go#L135-L145；来源: modules/messages_search/validate.go#L147-L160

### US-02：需求管理专员核对 PRD / Review 工作量
- 角色：作为 Octo 需求管理专员
- 场景：当我需要核对一批待 PRD、待 Review、返工或验收的需求
- 诉求：希望导出结果能展示需求编号、标题、状态、负责人、时间和摘要
- 价值：以便减少逐个打开需求单的人工整理成本
- 来源: .github/ISSUE_TEMPLATE/bug_report.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L29-L42；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L43-L49；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L50-L63；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L64-L74

### US-03：有权成员获取可流转的需求列表
- 角色：作为有权参与评审、周报或复盘的团队成员
- 场景：当我需要查看自己权限范围内的一组需求单
- 诉求：希望导出文件只包含我有权查看的需求信息，并能识别筛选条件和导出时间
- 价值：以便安全地进行线下审阅，不误带无权数据
- 来源: .octospec/rules/space-isolation.md#L21-L31；来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L33-L45

### US-04：空结果、超量或失败时得到清晰反馈
- 角色：作为执行批量导出的用户
- 场景：当筛选结果为空、导出数量过大、导出失败或导出能力暂不可用
- 诉求：希望看到明确状态、原因类别和可恢复建议
- 价值：以便调整筛选条件、稍后重试或联系产品运营负责人确认
- 来源: modules/messages_search/validate.go#L147-L160；来源: modules/messages_search/validate.go#L214-L224；来源: .octospec/rules/rate-limit.md#L19-L29

### US-05：运营和审计人员追溯导出动作
- 角色：作为系统运营人员、需求管理专员或主考
- 场景：当批量导出涉及敏感内容、权限争议、失败或滥用风险
- 诉求：希望能看到安全审计摘要，说明谁在什么范围内导出了什么类别的需求列表和处理结果
- 价值：以便事后排查，同时不泄露导出明细中的敏感内容
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L62-L70

## 4. 功能需求

### F-01-1 筛选条件
- 所属故事：US-01、US-02、US-03
- 需求描述：用户应能按时间范围、创建人、状态、优先级、标签等条件筛选需求单列表，并能看到当前筛选条件摘要。
- 业务规则：筛选条件应有明确可选范围和有效性提示；时间范围、状态、优先级、标签等条件应以用户可理解的名称展示。
- 边界场景：条件为空、条件冲突、时间范围无效、筛选结果为空、标签不存在或用户无权查看部分结果时，应展示明确提示。
- 来源: modules/messages_search/validate.go#L88-L99；来源: modules/messages_search/validate.go#L100-L104；来源: modules/messages_search/validate.go#L135-L145；来源: modules/messages_search/validate.go#L147-L160；来源: modules/messages_search/validate.go#L214-L224

### F-01-2 一键导出筛选结果
- 所属故事：US-01、US-02、US-03
- 需求描述：用户应能对当前筛选后的需求单列表执行一键导出，并获得可下载、可转发或可离线审阅的文件。
- 业务规则：导出结果应与用户当前有权查看的筛选结果一致；导出操作应明确导出范围、生成状态和完成结果。
- 边界场景：导出结果为空、导出中断、文件生成失败、下载入口失效、客户端不支持下载或用户权限变化时，应展示真实状态和可恢复建议。
- 来源: modules/file/api.go#L83-L90；来源: modules/file/api.go#L91-L99；来源: modules/file/api.go#L985-L990；来源: modules/file/api.go#L930-L938；来源: modules/file/api.go#L939-L948；来源: modules/file/api.go#L958-L967；来源: modules/file/api.go#L969-L982

### F-01-3 导出字段口径
- 所属故事：US-01、US-02、US-03
- 需求描述：导出结果至少包含标题、编号、状态、负责人、创建时间、最近更新时间和摘要；可根据评审需要展示创建人、优先级、标签、当前处理阶段等可见信息。
- 业务规则：字段名称应稳定、可读、便于周报/复盘引用；摘要应截断到合理长度，并避免带出用户无权查看的正文、评论或附件详情。
- 负责人字段首版口径：优先展示需求单当前明确指定的负责人；若存在多个明确负责人，应以同一单元格可读列出；若需求单尚未明确负责人，则展示“未分配”，不得把创建人、评论人或默认产品运营负责人误写为负责人。
- 边界场景：负责人为空、摘要缺失、标题过长、状态不明确、多个标签冲突或需求已关闭/重开时，应按当前真实状态展示，并使用“未分配”“摘要暂缺”等可理解占位，不把待分配误报为已有负责人。
- 来源: .github/ISSUE_TEMPLATE/feature_request.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/feature_request.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L9-L16；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L17-L24；来源: .github/ISSUE_TEMPLATE/bug_report.yml#L64-L74

### F-01-4 导出格式与文件可用性
- 所属故事：US-01、US-03、US-04
- 需求描述：首版默认导出为 `.xlsx` 表格文件，用于满足评审、周报和复盘中的编辑、筛选、统计和线下流转；首版不要求同时提供纯文本或其他数据格式。导出完成后应提供清晰的下载入口。
- 业务规则：文件名、导出时间、筛选条件摘要、数据范围、导出条数和文件有效期应便于识别；下载入口有效期首版为导出完成后 24 小时，超过有效期时用户应看到“下载入口失效”并可重新发起导出。
- 边界场景：文件名过长、格式不被客户端支持、导出文件过期、下载失败或下载后为空时，应给出用户可理解提示。
- 来源: modules/file/const.go#L179-L191；来源: modules/file/const.go#L197-L204；来源: modules/file/const.go#L205-L214；来源: modules/file/api.go#L985-L990

### F-01-5 权限与可见性过滤
- 所属故事：US-03、US-05
- 需求描述：导出范围必须按当前用户权限过滤，只导出当前用户有权查看的需求单和字段内容。
- 业务规则：跨 Space、跨群、跨 Thread、跨 Bot、私密需求、无权评论、不可见附件或权限已变化的内容不得出现在导出结果中；无权过滤提示不得成为枚举对象是否存在的信道。
- 边界场景：同一筛选条件下不同用户导出结果不同、用户导出过程中权限变化、需求迁移或来源对象失效时，应按当前可见性安全降级。
- 来源: .octospec/rules/space-isolation.md#L21-L31；来源: .octospec/rules/space-isolation.md#L34-L37；来源: modules/messages_search/authz.go#L9-L23；来源: modules/messages_search/authz.go#L33-L45；来源: modules/messages_search/authz.go#L44-L50

### F-01-6 空结果、超量和分页边界
- 所属故事：US-01、US-04
- 需求描述：系统应对空结果、结果数量过多、筛选范围过宽和导出文件过大给出明确反馈。
- 业务规则：首版单次导出上限为 1000 条可见需求单；导出前或导出中应让用户理解结果规模、上限和文件有效期。超出上限时，不应生成不完整且误导用户的文件，应提示用户缩小时间范围、状态、创建人、优先级或标签条件后重新导出。
- 边界场景：无条件导出、极长时间范围、大量需求、重复点击导出、批量导出多个范围时，应限制、排队提示或要求缩小范围。
- 来源: modules/messages_search/validate.go#L147-L160；来源: modules/messages_search/validate.go#L214-L224；来源: .octospec/rules/rate-limit.md#L19-L29

### F-01-7 敏感内容脱敏
- 所属故事：US-03、US-05
- 需求描述：当标题、摘要、评论摘要、附件名或其他导出内容包含疑似敏感信息时，系统应优先脱敏、截断或提示人工确认。
- 业务规则：疑似 token、cookie、secret、私钥、生产凭证、客户隐私、内部敏感链接或私密消息全文不得被导出到无权范围、群通知或审计明文中。
- 边界场景：系统无法判断敏感级别、敏感内容出现在附件或图片中、导出对象包含多来源材料时，应安全降级，不硬推完整导出。
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L62-L70

### F-01-8 导出状态与提示
- 所属故事：US-01、US-04
- 需求描述：导出过程应展示可理解的状态，包括待导出、导出中、导出完成、无结果、部分导出、导出失败、下载失效、权限变化和频率受限。
- 业务规则：状态提示应与真实结果一致，不把失败、部分导出、权限过滤或空结果误报为成功；失败时提供下一步建议。
- 边界场景：导出过程中需求状态变化、部分需求不可见、文件生成后过期、网络异常、用户重复发起导出时，应展示真实状态。
- 来源: modules/file/api.go#L985-L990；来源: modules/messages_search/api.go#L152-L164

### F-01-9 限流与防滥用
- 所属故事：US-04、US-05
- 需求描述：批量导出、重复下载、宽范围筛选和高频操作应有频率、数量和范围约束，并对用户展示安全提示。
- 业务规则：该能力不得被用于批量抓取无关需求、枚举无权对象、绕过 Space / 群 / Thread 权限或造成服务压力。
- 边界场景：同一用户短时间高频导出、多用户同时导出、超大范围导出、疑似爬取或异常失败重试时，应降噪、拒绝或提示稍后重试。
- 来源: .octospec/rules/rate-limit.md#L19-L29；来源: modules/messages_search/api.go#L122-L131；来源: modules/messages_search/api.go#L132-L139；来源: modules/messages_search/validate.go#L214-L224

### F-01-10 审计与追溯摘要
- 所属故事：US-05
- 需求描述：筛选、导出、下载、权限过滤、失败和频控结果应保留可追溯安全摘要。
- 业务规则：审计摘要应说明操作者、导出范围、筛选条件类别、结果数量区间、处理结果和发生时间；不得记录明文敏感内容、完整摘要正文或无权对象详情。
- 边界场景：权限争议、导出失败、部分成功、疑似滥用、敏感内容脱敏或用户申诉时，应能基于安全摘要进行排查。
- 来源: modules/messages_search/audit.go#L12-L24；来源: modules/messages_search/audit.go#L30-L40；来源: modules/messages_search/audit.go#L62-L70

## 5. 状态与提示

- 可导出：当前筛选条件有效，且存在用户有权查看的需求单。
- 无可导出结果：当前筛选条件下没有可见需求单，建议调整时间、状态、创建人或标签。
- 导出中：系统正在生成导出文件，请稍后查看结果。
- 导出完成：导出文件已生成，可在导出完成后 24 小时内下载。
- 部分导出：部分需求或字段因权限、状态变化、失效或敏感内容规则被过滤。
- 导出失败：导出未完成，提示失败原因类别和可恢复建议。
- 下载入口失效：导出文件已超过 24 小时有效期、被清理或不可访问，建议重新导出。
- 权限不足：当前用户无权导出或查看部分需求，不展示无权对象详情。
- 结果过多：筛选结果超过首版单次 1000 条导出上限，建议缩小时间范围、创建人、状态、优先级或标签。
- 操作过于频繁：当前导出或下载触发频率限制，请稍后重试。
- 疑似敏感内容：导出内容已脱敏、截断或需人工确认后补充。

## 6. 验收标准

- AC-01：当有权用户设置时间范围、创建人、状态、优先级、标签等筛选条件时，能看到筛选条件摘要和匹配的可见需求单范围。
- AC-02：当筛选结果不为空且不超过首版单次 1000 条可见需求单时，用户能一键导出 `.xlsx` 需求单列表，并获得可下载文件。
- AC-03：导出结果至少包含标题、编号、状态、负责人、创建时间、最近更新时间和摘要，字段名称清晰可读；负责人优先展示需求单当前明确指定的负责人，多个负责人可读列出，无明确负责人时展示“未分配”。
- AC-04：导出结果只包含当前用户有权查看的需求单和字段内容；无权、私密、跨 Space / 群 / Thread / Bot 的内容不出现在导出文件中。
- AC-05：当筛选结果为空时，用户看到“无可导出结果”及调整筛选条件的建议。
- AC-06：当导出范围超过首版单次 1000 条上限、频率过高或重复触发时，用户看到限制原因和缩小范围或稍后重试的建议，不收到误导性的部分完整文件。
- AC-07：当导出中发生权限变化、需求状态变化、文件生成失败或下载入口超过 24 小时有效期失效时，用户看到真实状态，不误报为完整成功。
- AC-08：当标题、摘要、附件名或其他导出内容包含疑似 token、cookie、secret、私钥、生产凭证、客户隐私或内部敏感链接时，导出结果、通知和审计仅展示脱敏摘要或人工确认提示。
- AC-09：当不同角色使用相同筛选条件导出时，结果按各自当前权限过滤，不通过数量、失败原因或缺失提示泄露无权对象详情。
- AC-10：运营或需求管理人员能基于安全摘要追溯筛选、导出、下载、权限过滤、失败和频控结果；审计不记录明文敏感内容或无权对象详情。
- AC-11：产品说明覆盖筛选条件、导出字段、`.xlsx` 首版格式、负责人取值、1000 条单次上限、24 小时文件有效期、权限过滤、空结果、超量、失败、脱敏、限流和审计口径。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P2`
- status/*：当前为 `status/rework`；本轮按 Review 意见返工、远端提交、评论回填和引用核验通过后应更新为唯一 `status/reviewing`
- area/*：`area/unknown`（当前需求池暂无更精确的“需求单导出/报表”领域标签；保留现状，建议产品运营负责人 Review 时确认是否需要新增或调整领域）
- V5 only：未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：未发现必须建议 `priority/P0 + status/blocked` 的阻塞级凭证或安全风险；但本需求涉及批量读取、导出文件、权限过滤、敏感内容、限流和审计，Review 应重点核验。

## 8. 待确认事项

- 无阻塞待确认事项。
- 本轮 Review 打回的 3 个口径已在 PRD 中明确：首版默认 `.xlsx`；负责人优先展示需求单当前明确指定的负责人，无明确负责人展示“未分配”；首版单次导出上限为 1000 条可见需求单，下载入口有效期为导出完成后 24 小时。

## 9. 五类风险检查

- 多租户 / Space 隔离：导出结果必须按当前用户的 Space / 群 / Thread / Bot 权限过滤；跨范围或无权需求不得出现在文件、数量提示或失败详情中。
- 权限 / ownership：只有有权查看相应需求列表的用户才能导出；权限变化后导出、下载和再次打开文件都应按真实可见性安全处理。
- 安全 / 外部输入 / 凭证：标题、摘要、评论摘要、附件名和导出文件可能含敏感信息；疑似 token、cookie、secret、私钥、生产凭证、客户隐私或内部敏感链接必须脱敏、截断或人工确认。
- 限流 / 防滥用：筛选、导出和下载需要频率、数量、范围和文件大小边界；首版单次导出上限为 1000 条可见需求单，避免批量抓取、枚举无权对象或对服务造成压力。
- 审计 / 可追溯：关键动作需记录安全摘要，包括操作者、导出范围、筛选条件类别、结果数量区间、处理结果和发生时间；审计不得记录明文敏感内容、完整导出内容或无权对象详情。

## 10. What-only 自检摘要

- 技术 How：无。本文只定义用户可见能力、范围、状态、权限、安全、限流、审计和验收口径；未写内部落地方案、研发结构、部署方式或具体技术字段。
- 引用核验：通过；全部引用均使用 `来源: <相对路径>#L<起>-L<止>` 格式，并已通过脚本核验。
- Label 完整性：通过；当前远端包含 `type/feature`、`priority/P2`、`status/rework`、`area/unknown`，本轮返工完成后应推进为唯一 `status/reviewing`。
- 状态真实性：当前 issue 为 `status/rework`；本轮 PRD 返工、评论回填和核验通过后应更新为唯一 `status/reviewing`。
- 风险提醒 / 待人工确认：无阻塞级风险；已补齐首版导出格式、负责人字段、导出范围上限和文件有效期口径，建议 Review 继续重点关注批量导出权限过滤、无权对象防枚举、敏感内容脱敏、限流和审计。
