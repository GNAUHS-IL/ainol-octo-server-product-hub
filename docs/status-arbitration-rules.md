# 状态仲裁规则 V5

## 核心原则

GitHub issue 不是原始收集箱。只有在建单前已经完成最小必要澄清、能形成可管理工作项时，才进入需求池并打 `status/*`。

同一个 issue 同一时间必须且只能有一个 `status/*`。状态变化时，在原 issue 上替换 status label，并用 comment 记录原因；不得为同一需求按不同状态重复建单。

## 状态定义

| status | 含义 | 典型使用 | 不能误报为 |
|---|---|---|---|
| `status/prd-drafting` | 正在整理 PRD / 需求说明 | 需求成立，需要补 What-only PRD | 已接受、已完成 |
| `status/prd-review` | PRD 已提交 Review | 等需求管理专员检查 | 已通过、已完成 |
| `status/rework` | Review 打回，需要返工 | 范围不清、验收标准不可验证、写了 How | 已接受、已完成 |
| `status/accepted` | 已确认接受处理 | Bug 成立或 PRD Review 通过，进入处理队列 | 已完成 |
| `status/blocked` | 当前被阻塞 | 权限、安全、证据冲突、限流、人工确认 | 已完成、wontfix |
| `status/done` | 已完成闭环 | 修复/补充/处理完成，或结论已可核验归档 | wontfix、duplicate、invalid |
| `status/wontfix` | 有效但决定不做 | 不符合产品方向或成本收益不合理 | 已修复、无效 |
| `status/duplicate` | 与已有 issue 重复 | 关联原 issue，以原 issue 为准 | 已完成、无效 |
| `status/invalid` | 无法成立为有效工作项 | 对象错误、事实不成立、不可处理 | wontfix、done |

## 建单前处理

- 信息不足：先在对话中追问，不建 issue。
- 只是普通源码/产品问答：直接回答，不建 issue。
- 问答暴露出文档错误、文档缺失、产品异常或能力缺口时，才转换为 `type/bug` 或 `type/feature` issue。

## 常见流转

```text
Feature: status/prd-drafting → status/prd-review → status/accepted → status/done
Feature rework: status/prd-review → status/rework → status/prd-drafting/prd-review
Bug: status/accepted → status/done
Blocked: 任意状态 → status/blocked → 原状态或 status/accepted/done
Close reasons: 任意状态 → status/wontfix / status/duplicate / status/invalid
```
