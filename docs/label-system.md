# Label 体系 V4：issue-first 产品需求池

## 核心原则

Label 只用于已经进入 GitHub 需求池的 issue。普通群聊问答如果能直接用源码回答，不创建 issue，也不打 label。

建 issue 的条件是：该事项需要被追踪、修复、新增、补充、进入 PRD / Review、风险接管或沉淀为公开需求池工作项。

## 维度分工

| 维度 | 负责回答的问题 | 规则 |
|---|---|---|
| `type/*` | 这张 issue 最终要修正什么，还是新增/增强什么 | 必须且只能一个 |
| `priority/*` | 处理顺序和紧急程度 | 必须且只能一个 |
| `status/*` | issue 当前生命周期状态 | 必须且只能一个 |
| `area/*` | 影响的产品/源码/运营领域 | 至少一个；复杂问题可多个 |
| `pm/*` | PRD / Review / 人工接管等产品流程 | 按需添加 |
| `source/*` | issue 来源 | 至少一个 |
| `evidence/*` | 源码证据状态 | 源码相关 issue 必须且只能一个 |
| `risk/*` | 安全、隐私、歧义、凭证等刹车风险 | 按需添加 |

## 主类型：只保留两类

- `type/bug`：需要修正的产品、行为、文档或证据错误。
- `type/feature`：需要新增或增强的产品能力、体验、说明或材料。

不再使用 `type/question`、`type/docs`、`type/prd`、`type/review`：

- 普通问题直接回答，不建 issue。
- 文档错误是 `type/bug + area/docs`。
- 文档补充是 `type/feature + area/docs`。
- PRD / Review 是流程阶段，用 `status/* + pm/*` 表达。

## 入口判断

```text
用户输入
↓
能直接源码回答？ → 直接回答，不建 issue
↓
需要追踪/修复/新增/补文档/PRD/风险接管？ → 创建 issue
↓
按 type / priority / status / area / source / evidence / risk / pm 打 label
```

## 状态规则

`status/*` 是唯一生命周期状态，不允许同一 issue 同时挂多个 `status/*`。

常用流转：

```text
status/inbox → status/triaged
status/triaged → status/needs-clarification
status/triaged → status/prd-drafting → status/prd-review
status/prd-review → status/accepted 或 status/rework
status/accepted → status/done
status/triaged → status/wontfix / status/duplicate / status/invalid
任意状态 → status/blocked（遇到权限、安全、证据冲突、限流等阻塞）
```

## 典型组合

### 产品行为异常

```text
type/bug
priority/P1
status/needs-clarification
area/rbac
source/group
evidence/source-needed
risk/ambiguous
```

### 新能力需求

```text
type/feature
priority/P1
status/prd-drafting
area/bot-agent
source/group
evidence/source-needed
pm/needs-prd
```

### 文档错误

```text
type/bug
priority/P2
status/triaged
area/docs
evidence/source-verified
source/group
```

### 文档补充

```text
type/feature
priority/P2
status/prd-drafting
area/docs
evidence/source-verified
source/group
pm/needs-prd
```

### 凭证/安全风险

```text
type/bug
priority/P0
status/blocked
area/auth
source/group
evidence/source-needed
risk/security
risk/token-leak
pm/human-needed
```

## 强制一致性规则

1. 不建 issue，不打 label。
2. 每个 issue 必须且只能有一个 `type/*`。
3. 每个 issue 必须且只能有一个 `priority/*`。
4. 每个 issue 必须且只能有一个 `status/*`。
5. 源码相关 issue 必须且只能有一个 `evidence/*`。
6. `risk/token-leak` 必须同时有 `priority/P0` 和 `pm/human-needed`。
7. `status/done` 的源码相关 issue 必须有 `evidence/source-verified` 或 `evidence/not-applicable`。
