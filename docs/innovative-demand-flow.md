# 创新需求流转方案：Evidence-to-PRD Gate

## 1. 设计目标

本流程不是照搬 `octo-server` 目标仓的 GitHub issue / spec 机制，而是在目标仓已有 Bug / Feature / Spec / Review 结构上，增加一层适合产品管家 Agent 的判断机制：

> 先做证据归因，再决定是否进入 PRD。

核心创新点是 **Evidence-to-PRD Gate**：

```text
用户反馈 / 群内问题
↓
源码证据卡 Evidence Card
↓
需求闸门 Decision Gate
↓
直接回答 / 建 Bug / 建 Feature / 补 PRD / Review / 仲裁
```

这样可以避免两个极端：

1. 任何问题都建 issue，导致需求池膨胀。
2. 任何 issue 都补 PRD，导致需求管理员被低价值事项淹没。

## 2. 角色分工

### 产品运营负责人，也就是我

负责：

- 群内主入口；
- 源码可核验问答；
- 是否建 issue 的初判；
- `type/*`、`priority/*`、`status/*`、`area/*` 初始分诊；
- PRD Review；
- 最终状态仲裁；
- 群内主回复。

### Octo 需求管理员

负责：

- 在 `status/prd-drafting` 下草拟 What-only PRD；
- 在 `status/rework` 下按 Review 意见修改 PRD；
- 整理用户场景、用户目标、范围边界、验收标准；
- 整理源码引用材料；
- 巡检 issue 状态变化并提醒。

不负责：

- 不 Review 自己写的 PRD；
- 不做最终状态仲裁；
- 不常规处理 `status/blocked`；
- 不替产品运营负责人发最终群内口径。

## 3. Evidence Card：先证据归因

每个需要追踪的反馈，在建 issue 或进入 PRD 前，先形成一张轻量 Evidence Card。

Evidence Card 不作为 label，而是写入 issue 正文或 comment。

模板：

```text
## Evidence Card

### 用户原始意图
用户实际想解决什么问题？

### 当前可见现象
用户看到什么、不能完成什么？

### 源码 / 知识库归因
- area/*：
- 已查路径：
- 关键引用：来源: <相对路径>#L<起>-L<止>

### 归因判断
- existing-behavior：已有行为，可直接回答或修正偏差
- behavior-gap：现有行为缺口，需要新增/增强
- rule-undefined：产品规则未定义，需要 PRD
- evidence-missing：证据不足，先补查
- unsafe-or-blocked：安全、权限、限流或人工决策阻塞

### PRD Gate 初判
- need-prd：yes / no / unsure
- 原因：
```

## 4. PRD Gate：不是所有 issue 都 PRD

PRD Gate 用一个核心问题判断：

> 这个事项是否需要定义或改变用户可见能力、规则、流程或验收标准？

### 4.1 直接回答，不建 issue

适用：

- 用户问已有能力；
- 源码能直接回答；
- 不需要追踪修正或新增。

动作：

```text
直接回答 + 源码引用
```

### 4.2 建 Bug，不补 PRD

适用：

- 已有行为异常；
- 文档写错；
- 引用失效；
- 配置名、路径、错误码、模块索引等明确错误；
- 预期行为可以由源码、现有文档或既有规则证明。

动作：

```text
type/bug
status/todo 或 status/accepted
对应 area/*
```

### 4.3 建 Feature，但不一定补 PRD

适用：

- 补充已有事实；
- 完善知识库；
- 补已有能力说明；
- 不改变用户可见能力或规则。

动作：

```text
type/feature
status/todo 或 status/accepted
对应 area/*
```

### 4.4 建 Feature，并补 PRD

适用：

- 新增用户可见能力；
- 改变用户操作流程；
- 改变用户可见提示、状态、通知或恢复路径；
- 需要定义产品规则；
- 涉及目标仓 PR 模板所说的 load-bearing behavior；
- 需要明确场景、边界、验收标准后才能处理。

动作：

```text
type/feature
status/prd-drafting
对应 area/*
```

然后由需求管理员写 PRD。

### 4.5 不确定，不硬判

适用：

- 用户目标不清；
- 源码证据不足；
- 现象和源码冲突；
- 需要外部权限、日志或人工决策。

动作：

```text
未建 issue：先追问或补查
已建 issue：status/todo 或 status/blocked
```

不能默认丢给需求管理员补 PRD。

## 5. 四类创新流转

### Flow A：Answer-only

```text
群内问题
↓
源码定位
↓
直接回答 + 来源引用
↓
不建 issue
```

价值：避免把知识问答污染成需求池噪音。

### Flow B：Bug-fast-track

```text
反馈异常
↓
Evidence Card 证明已有规则 / 源码预期
↓
type/bug + status/accepted
↓
处理完成后 status/done
```

价值：明确 bug 不被 PRD 拖慢。

### Flow C：Feature-with-PRD

```text
新增能力 / 产品规则缺口
↓
Evidence Card 证明现有能力不足
↓
type/feature + status/prd-drafting
↓
需求管理员写 PRD
↓
status/reviewing
↓
产品运营负责人 Review
↓
status/accepted 或 status/rework
```

价值：PRD 只服务真正需要产品定义的事项。

### Flow D：Blocked-safe-stop

```text
权限 / 安全 / 凭证 / 限流 / 证据冲突
↓
status/blocked
↓
脱敏说明 + 人工接管原因
↓
等待恢复 / 补证据 / 关闭仲裁
```

价值：blocked 是安全刹车，不是需求管理员待办池。

## 6. 为什么这是创新而不是照抄目标仓

目标仓提供的是基础结构：

- Bug Report；
- Feature Request；
- PR Linked Spec；
- `.octospec` 规则体系；
- review 约束。

本需求池新增的是产品管家层面的判断机制：

1. **Evidence Card**：先把用户反馈和源码证据对齐。
2. **PRD Gate**：不是建 issue 就补 PRD，而是判断是否需要定义用户可见规则。
3. **双人分离 Review**：需求管理员写，我 Review，避免自写自审。
4. **Bug-fast-track**：明确 bug 不进入 PRD，避免流程拖慢。
5. **Blocked-safe-stop**：安全、权限、限流、证据冲突不丢给需求管理员。
6. **Answer-only 静默分支**：源码问答不污染需求池。

这套机制既尊重目标仓的 Bug / Feature / Spec 结构，又形成了考试场景下可解释、可演示、可落地的创新流程。

## 7. 对外答辩口径

可以这样解释：

> 我没有把目标仓流程原样照搬，而是在目标仓已有 Bug / Feature / Spec / Review 基础上，设计了一层 Evidence-to-PRD Gate。  
> 每条反馈先做源码证据归因，再判断是直接回答、Bug 快速通道、Feature 需求、PRD 需求还是安全阻塞。  
> 这样既保证源码可核验，又避免所有 issue 都补 PRD；需求管理员只负责 PRD 草拟和返工，我负责 Review 和最终状态仲裁。

## 8. 最小执行规则

1. 普通问答：直接回答，不建 issue。
2. 明确 bug：建 bug，不默认 PRD。
3. 新能力 / 新规则 / 用户体验变化：建 feature，进入 PRD Gate。
4. PRD 由需求管理员写，我 Review。
5. blocked 不作为需求管理员默认介入状态。
6. 所有源码相关结论必须保留真实引用。
7. 无变化不发群。
