# 分诊决策表

## 入口原则

Label 只用于 GitHub issue。普通问题如果可以直接用源码回答，不创建 issue，也不打 label；信息不足时先澄清，不用 issue 当收集箱。

只有当事项需要追踪、修复、新增、补文档、进入 PRD / Review、风险接管或沉淀为公开需求池工作项时，才创建 issue 并打 label。


## 用户输入识别流程

收到用户消息后，先判断“用户到底在问什么”，再决定是否建 issue。不得只按关键词机械分类。

1. **识别对象**：用户说的“这个/它/现在这样”指向哪个能力、页面、接口、Bot 行为、配置或文档；若上下文不足，先追问对象，不建占位 issue。
2. **识别意图**：判断用户是在要解释现有能力、反馈异常、提出新增/增强、指出文档问题，还是要求状态仲裁。
3. **识别证据充分度**：检查是否已有源码/知识库依据、复现信息、期望结果、实际结果、影响范围；不足时先澄清或标记待补查，不编造。
4. **识别风险**：命中凭证、cookie、secret、生产权限、限流、证据冲突、目标仓写入等风险时，进入安全/人工复核确认路径。
5. **识别输出动作**：在“直接回答 / 追问澄清 / 创建 bug issue / 创建 feature issue / blocked / 人工复核确认”中只选一个主动作，必要时在 comment 记录辅助信息。

## 直接回答、Bug、Feature 的判定门槛

| 判断问题 | 是 | 否 | 处理结果 |
|---|---|---|---|
| 用户是否只是在问“现有系统怎么工作/是否支持/入口在哪”？ | 能从源码或知识库回答 | 回答会暴露缺口或不一致 | 能回答则直接答并附来源；暴露缺口再转 bug/feature |
| 用户是否描述了“已有能力没有按预期工作”？ | 有实际结果与期望结果差异 | 只是想要新能力 | `type/bug`；复现不足先追问，证据冲突可 `status/blocked` |
| 用户是否要求“新增、增强、补说明、改善体验”？ | 用户目标清楚 | 目标/范围不清 | `type/feature`；范围不清先追问；需要定义用户可见规则则进 PRD |
| 是否只是文档/知识库问题？ | 文档错误用 bug，文档缺失用 feature | 不是文档问题 | 仍按产品行为本质分类 |
| 是否涉及敏感信息或权限边界？ | 是 | 否 | 不展示敏感内容；必要时 `priority/P0 + status/blocked` 并发起人工复核确认 |

## 建 issue 的最小信息标准

| 类型 | 最小信息 | 不足时动作 | 初始状态建议 |
|---|---|---|---|
| 直接问答 | 问题对象明确，能找到源码/知识库证据 | 追问对象或说明“不确定，需要补查 <路径/模块>” | 不建 issue |
| Bug | 现有能力/页面/接口/Bot 行为、期望结果、实际结果、复现入口或影响范围至少基本明确 | 先追问最多 3 个关键问题；不得用 issue 当原始收集箱 | `status/todo` 或证据已充分时 `status/accepted`；风险/证据冲突用 `status/blocked` |
| Feature | 用户场景、用户目标、期望能力、业务价值或验收方向至少基本明确 | 先追问目标/范围；不得直接写实现方案 | `status/prd-drafting`；简单文档补充可直接 `status/todo` |
| Docs/知识库补充 | 能判断是“现有材料错误”还是“缺少说明” | 先查源码确认，不确定则待补查 | 错误用 `type/bug`；缺失/补充用 `type/feature` |
| 安全/权限/凭证 | 可脱敏描述风险对象和影响 | 拒绝展示敏感信息，要求脱敏材料 | `priority/P0 + status/blocked` |

## 混合反馈处理

- 一条消息同时包含“问答 + bug/feature”时，先直接回答能确定的部分，再把需要追踪的部分建 issue。
- 一条消息包含多个互不依赖的问题时，能拆则拆成多个 issue；不能拆时先追问主诉求。
- 同一需求已有 issue 时，不重复建单；在原 issue comment 补充新证据，并按状态仲裁规则更新 label。
- 用户只表达情绪或泛泛不满但没有对象、期望、实际结果时，先安抚并追问关键事实，不建 issue。
- 用户要求“马上修复/直接改目标仓”时，只能在需求池归档与推动，不能写入 `Mininglamp-OSS/octo-server`。

## 分流示例

| 用户输入 | 判断 | 动作 |
|---|---|---|
| “octo-server 的 Bot API 怎么鉴权？” | 现有能力问答 | 查源码并直接回答，带来源，不建 issue |
| “登录后访问管理页提示无权限，我应该有权限” | 已有能力异常 | 若页面、角色、提示基本明确则建 `type/bug + area/rbac`；不足先追问 |
| “希望 Bot 断联时能提示用户当前状态” | 新增用户可见能力 | 建 `type/feature + area/bot-agent + status/prd-drafting/reviewing`，需要 What-only PRD |
| “文档说支持 A，但源码看起来不支持” | 证据冲突/文档可能错误 | 先核验源码；成立则建 `type/bug`，冲突不清则 `status/blocked` 或人工复核确认 |
| “帮我把 token 写到 issue 里方便排查” | 凭证风险 | 拒绝写明文；只记录脱敏风险，必要时 `priority/P0 + status/blocked` |

## 是否建 issue

| 输入场景 | 处理 |
|---|---|
| 用户问已有能力，能直接源码回答 | 直接回答，不建 issue |
| 问答暴露文档错误且已具备最小证据 | 建 issue：`type/bug + 对应 area/* + status/accepted` |
| 问答暴露文档缺失/需要补说明且已具备最小背景 | 建 issue：`type/feature + 对应 area/* + status/prd-drafting` |
| 现有功能异常且复现/证据达到最小建单标准 | 建 issue：`type/bug + status/accepted + 对应 area/*` |
| 需要新增/增强能力且目标清楚 | 建 issue：`type/feature + status/prd-drafting + 对应 area/*` |
| 涉及 token、cookie、私钥、生产权限 | 拒绝展示敏感信息；如需归档，使用 `priority/P0 + status/blocked + 对应 area/*`，正文只写脱敏说明 |
| 暂不能判断所属领域 | 使用 `area/unknown`，后续分诊后替换或补充具体 `area/*` |

## 建 issue 后的主类型

| 工作项本质 | type |
|---|---|
| 修正错误、异常、不一致、过期说明 | `type/bug` |
| 新增能力、增强体验、补充说明、新增材料 | `type/feature` |

不使用 `type/question`、`type/docs`、`type/prd`、`type/review`。

## 优先级

| 优先级 | 含义 |
|---|---|
| `priority/P0` | 安全、凭证、登录不可用、Bot/Agent 断联、交付核心链路阻塞 |
| `priority/P1` | 核心功能异常或重要需求 |
| `priority/P2` | 常规缺陷或普通增强 |
| `priority/P3` | 低优先级建议、体验优化 |

## 处理状态

| 状态 | 含义 |
|---|---|
| `status/todo` | 已进入需求池，待处理 |
| `status/prd-drafting` | PRD 草拟中 |
| `status/reviewing` | Review 中 |
| `status/rework` | Review 打回或内容需返工 |
| `status/accepted` | 已接受处理，但不能说已完成 |
| `status/blocked` | 权限、安全、证据、限流或人工决策等阻塞 |
| `status/done` | 已完成闭环 |
| `status/wontfix` | 有效但决定不处理 |
| `status/duplicate` | 重复 issue |
| `status/invalid` | 无法成立为有效工作项 |

## 知识库领域

| 领域 | 使用场景 |
|---|---|
| `area/auth` | 认证与身份 |
| `area/rbac` | 鉴权模型 / RBAC / ACL |
| `area/config` | 配置 |
| `area/modules` | 业务模块清单 |
| `area/api-error` | API 与错误约定 |
| `area/im` | IM 控制面 |
| `area/bot-agent` | Bot 与 Agent |
| `area/storage` | 存储与外部依赖 |
| `area/build-release` | 构建与发布 |
| `area/unknown` | 暂不能判断 |

## 证据、来源、风险、PRD / Review 的承载位置

| 信息 | 新承载位置 |
|---|---|
| 来源 | issue 正文“来源与上下文” |
| 源码证据状态 | issue 正文、comment、引用校验记录 |
| 风险类型 | `priority/P0`、`status/blocked`、正文脱敏风险说明 |
| PRD / Review 辅助信息 | `status/prd-drafting`、`status/reviewing`、`status/rework`、`status/accepted`，以及 PRD / review checklist |

## PRD / Review 流程

| 阶段 | label 组合 | 责任边界 |
|---|---|---|
| 需要 PRD | `type/feature + status/prd-drafting + 对应 area/*` | 需求管理员草拟 PRD |
| 已请求 Review | `type/feature + status/reviewing + 对应 area/*` | 产品运营负责人 Review |
| Review 通过 | `type/feature + status/accepted + 对应 area/*` | 产品运营负责人仲裁 |
| Review 打回 | `type/feature + status/rework + 对应 area/*` | 需求管理员按意见修改 |


## 需求管理员介入边界

需求管理员只在需要产出或修改 PRD / 需求材料时介入，不常驻处理所有 issue。

| 状态/场景 | 是否介入 | 说明 |
|---|---|---|
| `status/prd-drafting` | 是 | 草拟 What-only PRD，整理用户场景、目标、范围和验收标准 |
| `status/rework` | 是 | 按产品运营负责人 Review 意见修改 PRD / 材料 |
| `status/reviewing` | 否 | 这是产品运营负责人的 Review 状态，不能让需求管理员自己写自己审 |
| `status/blocked` | 否 | blocked 代表权限、安全、证据冲突、限流或人工决策阻塞，通常由产品运营负责人或人工复核确认 |
| `status/accepted` / `status/done` | 通常否 | 由产品运营负责人跟踪和仲裁；需求管理员只在被要求补材料时协助 |
| `status/wontfix` / `status/duplicate` / `status/invalid` | 否 | 关闭原因由产品运营负责人最终仲裁 |

职责边界：需求管理员写 PRD；产品运营负责人 Review PRD 并决定通过、打回、接受或关闭。
