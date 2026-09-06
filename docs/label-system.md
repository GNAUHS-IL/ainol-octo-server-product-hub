# Label 体系 V5：知识库驱动的轻量需求池标签体系

## 1. 设计结论

本需求池最终只保留四组 label：

```text
type/*
priority/*
status/*
area/*
```

不再使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`，也不再使用 `area/docs`、`area/ops`、`area/cross-module`。

这版的目标不是把所有管理信息都塞进 label，而是让 label 只承担四件事：

1. 这是什么性质的事项：`type/*`
2. 应该优先处理到什么程度：`priority/*`
3. 当前处理到哪一步：`status/*`
4. 属于 octo-server 哪块知识库：`area/*`

来源、证据、风险说明、PRD 检查项、Review 记录，都放在 issue 正文、comment、PRD 或 review checklist 中，不作为 label。

## 2. 为什么这样改

### 2.1 符合我的产品运营负责人定位

我的职责是围绕 `Mininglamp-OSS/octo-server` 做产品管家，而不是把需求池做成审计系统。

这个角色最关键的工作是：

- 快速判断反馈属于修正还是新增；
- 按严重程度安排处理顺序；
- 把 issue 推进到 PRD、Review、接受、完成或关闭；
- 将每个 issue 对齐到九大源码知识库，保证后续回答、PRD 和验收都有源码依据。

因此 label 必须服务“分诊、过滤、推进、复盘”，不能承载过多过程字段。

### 2.2 符合 octo-server 的产品特点

`octo-server` 不是单一功能仓库，而是由认证、鉴权、配置、IM、Bot、存储、构建发布等多个领域组成的服务端产品。

所以最重要的分类维度不是“来源是什么”或“有没有证据”，而是：

> 这个反馈影响哪一个 octo-server 知识领域？

这也是为什么 `area/*` 只围绕九大知识库展开，并额外保留 `area/unknown` 作为暂不能判断的兜底。

### 2.3 避免 label 互相重复

旧版问题主要有三类：

| 旧设计 | 问题 | 新处理 |
|---|---|---|
| `pm/*` | 与 `status/*` 重复 | 合并到 `status/*` |
| `source/*` | 来源是元信息，不是分类 | 写入 issue 正文 |
| `evidence/*` | 证据状态更适合 checklist/comment | 写入正文或核验记录 |
| `risk/*` | 与 P0、blocked、正文风险说明重复 | 用 `priority/P0 + status/blocked + 正文说明` 表达 |
| `area/docs` / `area/ops` / `area/cross-module` | 偏离九大知识库或可用多 area 表达 | 删除 |

## 3. 使用边界

Label 只用于已经进入 GitHub 需求池的 issue。

普通群聊问答如果能直接用源码回答：

```text
直接回答，不创建 issue，不打 label。
```

只有当事项需要被追踪、修正、新增、补充、进入 PRD / Review、风险接管或沉淀为公开需求池工作项时，才创建 issue 并打 label。

信息不完整时，先在对话中澄清；不要用 `status/clarifying` 或占位 issue 代替澄清。

## 4. 四组 label

### 4.1 `type/*`：事项类型

每个 issue 必须且只能有一个 `type/*`。

```text
type/bug
type/feature
```

| Label | 含义 | 典型场景 |
|---|---|---|
| `type/bug` | 修正已有能力、产品行为、文档或证据中的错误 | 功能异常、行为不符合现有约定、文档写错、源码引用失效 |
| `type/feature` | 新增或增强产品能力、体验、说明或材料 | 新能力、体验优化、文档补充、知识库补充、PRD 新需求 |

不设置 `type/question`、`type/docs`、`type/prd`、`type/review`：

- Question：能回答就直接回答；需要沉淀时，最终归为修正或新增。
- Docs：文档错误是 `type/bug`；文档补充是 `type/feature`。
- PRD / Review：是处理状态，不是事项类型。

### 4.2 `priority/*`：优先级

每个 issue 必须且只能有一个 `priority/*`。

```text
priority/P0
priority/P1
priority/P2
priority/P3
```

| Label | 含义 |
|---|---|
| `priority/P0` | 安全、凭证、登录不可用、Bot/Agent 断联、交付核心链路阻塞 |
| `priority/P1` | 核心功能异常或重要需求 |
| `priority/P2` | 常规缺陷或普通增强 |
| `priority/P3` | 低优先级建议、体验优化 |

### 4.3 `status/*`：处理状态

每个 issue 必须且只能有一个 `status/*`。

```text
status/todo
status/prd-drafting
status/reviewing
status/rework
status/accepted
status/blocked
status/done
status/wontfix
status/duplicate
status/invalid
```

| Label | 含义 | 不能误报为 |
|---|---|---|
| `status/todo` | 已进入需求池，待处理 | 已接受、已完成 |
| `status/prd-drafting` | PRD 草拟中；需求管理员负责产出 PRD | 已接受、已完成 |
| `status/reviewing` | Review 中；产品运营负责人负责 Review | 已通过、已完成 |
| `status/rework` | Review 打回或内容需返工；需求管理员按意见修改 | 已接受、已完成 |
| `status/accepted` | 已接受处理，但尚未完成 | 已完成 |
| `status/blocked` | 被权限、安全、证据冲突、限流或人工决策阻塞；通常不要求需求管理员介入 | 已完成、wontfix |
| `status/done` | 已完成闭环 | wontfix、duplicate、invalid |
| `status/wontfix` | 有效但决定不处理 | 已修复、无效 |
| `status/duplicate` | 与已有 issue 重复 | 已完成、无效 |
| `status/invalid` | 无法成立为有效工作项 | wontfix、done |

注意：这里叫“处理状态”，不叫“生命周期状态”。

### 4.4 `area/*`：知识库领域

每个 issue 至少有一个 `area/*`；跨领域问题可以打多个 `area/*`。

```text
area/auth
area/rbac
area/config
area/modules
area/api-error
area/im
area/bot-agent
area/storage
area/build-release
area/unknown
```

| Label | 对应知识库 | 含义 |
|---|---|---|
| `area/auth` | `knowledge/01-auth-identity.md` | 认证与身份 |
| `area/rbac` | `knowledge/02-authorization-model.md` | 鉴权模型 / RBAC / ACL |
| `area/config` | `knowledge/03-configs.md` | 配置 |
| `area/modules` | `knowledge/04-modules.md` | 业务模块清单 |
| `area/api-error` | `knowledge/05-api-errors.md` | API 与错误约定 |
| `area/im` | `knowledge/06-im-control-plane.md` | IM 控制面 |
| `area/bot-agent` | `knowledge/07-bot-agent.md` | Bot 与 Agent |
| `area/storage` | `knowledge/08-storage-dependencies.md` | 存储与外部依赖 |
| `area/build-release` | `knowledge/09-build-release.md` | 构建与发布 |
| `area/unknown` | 暂无 | 暂不能判断，需要后续分诊 |

`knowledge/10-cross-module-quickref.md` 是跨模块速查页，不对应单独 label。跨模块问题直接打多个相关 `area/*`。

## 5. 典型组合

### 5.1 已确认的 Bug

```text
type/bug
priority/P1
status/accepted
area/im
```

### 5.2 需要 PRD 的新能力

```text
type/feature
priority/P1
status/prd-drafting
area/bot-agent
```

### 5.3 PRD Review 中

```text
type/feature
priority/P1
status/reviewing
area/bot-agent
```

责任边界：需求管理员提交 PRD 后，由产品运营负责人 Review，不能自写自审。

### 5.4 Review 打回

```text
type/feature
priority/P1
status/rework
area/bot-agent
```

责任边界：需求管理员只负责按 Review 意见修改，是否再次通过由产品运营负责人判断。

### 5.5 安全或凭证阻塞

```text
type/bug
priority/P0
status/blocked
area/auth
```

风险细节写入 issue 正文，例如：

```text
风险说明：涉及疑似凭证/权限/隐私信息，已脱敏，需产品运营负责人或人工复核确认/处理。
```

### 5.6 暂不能判断领域

```text
type/bug
priority/P2
status/todo
area/unknown
```

## 6. 强制一致性规则

1. 不建 issue，不打 label。
2. 信息不足时先澄清，不创建占位 issue。
3. 每个 issue 必须且只能有一个 `type/*`。
4. 每个 issue 必须且只能有一个 `priority/*`。
5. 每个 issue 必须且只能有一个 `status/*`。
6. 每个 issue 至少有一个 `area/*`。
7. 文档错误使用 `type/bug + 对应 area/*`。
8. 文档补充使用 `type/feature + 对应 area/*`。
9. 安全、凭证、权限类阻塞使用 `priority/P0 + status/blocked`，细节写入正文，不使用 `risk/*`。
10. `status/done` 必须有完成证据；源码相关 issue 必须在正文或 comment 中保留源码引用。
11. `status/wontfix`、`status/duplicate`、`status/invalid` 不能对外说成“已修复”。

## 7. 这版是不是“最完美”

不是绝对意义上的最完美，但它是当前考试目标、我的角色定位和 octo-server 产品结构下的最优解。

原因：

1. **足够简单**：只有四组 label，分诊时不会被来源、证据、PM、风险标签打散。
2. **足够贴合产品**：`area/*` 与九大知识库一一对应，便于把反馈落回源码证据和知识库。
3. **足够支撑闭环**：`status/*` 覆盖 PRD、Review、接受、阻塞、完成和关闭原因。
4. **足够安全**：凭证、隐私、权限风险不靠 label 展示细节，而是用 P0、blocked 和脱敏正文处理。
5. **足够可解释**：对考官可以清楚说明：label 负责分类和推进，正文负责来源、证据、风险和审计。

它不追求“把所有信息 label 化”，而是追求考试场景下最稳定、最不容易误用、最容易讲清楚的版本。

如果后续真实运营规模变大，可以再扩展自动化字段或 GitHub Project 字段；但在当前阶段，不建议继续增加 label 维度。
