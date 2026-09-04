# 最终状态仲裁规则

本文件用于产品运营负责人对 issue / PRD / Review / 群内回报做最终状态判断。核心目标：不误报、不夸大、不把未确认状态说成已完成。

## 状态定义

| 状态 | 含义 | 必要证据 | 不能混用 |
|---|---|---|---|
| `status/inbox` | 新输入，尚未判断 | 原始反馈或问题 | 不能当作已受理完成 |
| `status/triaged` | 已完成初步分类 | type、area、priority 至少明确 | 不能表示已修复 |
| `status/needs-clarification` | 信息不足 | 最多 3 个明确问题 | 不能等同 invalid |
| `status/prd-drafting` | 需要写 PRD | 用户场景和目标已基本明确 | 不能写技术 How |
| `status/prd-review` | PRD 待评审 | PRD 草稿、关联 issue | 不能表示开发接受 |
| `status/rework` | Review 打回 | 打回原因和必须修改项 | 不能说成 rejected |
| `status/accepted` | 已接受进入后续处理 | 明确接受依据或负责人确认 | 不能说成 done |
| `status/blocked` | 被外部条件阻塞 | 阻塞项、责任方、下一步 | 不能长期无说明停留 |
| `status/done` | 已完成 | 代码/配置/文档/issue 证据或明确验收 | 不能等同“已回复” |
| `status/wontfix` | 明确不做 | 不做原因、影响说明 | 不能用于没复现 |
| `status/duplicate` | 重复问题 | 指向原 issue / 原反馈 | 不能直接关闭为 done |
| `status/invalid` | 输入无效或不成立 | 无效原因 | 不能用于信息不足 |

## 仲裁红线

1. 没复现 ≠ 已修复。
2. 已解释 ≠ 已完成。
3. 已创建 issue ≠ 已处理。
4. 已接受 PRD ≠ 已开发上线。
5. duplicate 必须指向原 issue。
6. wontfix 必须说明原因，不能用来回避不确定。
7. blocked 必须说明阻塞项，不能只写“等待中”。
8. 涉及凭证、权限、限流、证据冲突，优先 `pm/human-needed`。
9. 没有源码证据时不能发布确定性源码结论。
10. 无实质变化不群发。

## 状态迁移规则

```text
inbox
  → needs-clarification：信息不足
  → triaged：类型/领域/优先级已明确
  → prd-drafting：确认是新需求且需要产品定义
  → human-needed：安全/权限/凭证/外部决策

triaged
  → prd-drafting：需要产品方案
  → accepted：已有明确后续处理路径
  → blocked：依赖外部权限/日志/上游信息
  → duplicate / invalid / wontfix：有充分证据

prd-drafting
  → prd-review：PRD 草稿完成
  → needs-clarification：用户价值或范围不足

prd-review
  → accepted：Review 通过
  → rework：有明确修改项
  → rejected：方向不成立
  → human-needed：安全/权限/业务裁决

accepted
  → done：有完成证据
  → blocked：执行中遇到阻塞
  → rework：验收或 Review 发现问题
```

## 群内状态回报口径

| 内部状态 | 可以对外说 | 禁止说法 |
|---|---|---|
| `needs-clarification` | “还缺少 X/Y/Z 信息，补齐后继续判断” | “已定位” |
| `triaged` | “已完成初步分诊，归为 X 类，涉及 Y 领域” | “已处理完成” |
| `prd-drafting` | “进入需求说明整理，先明确用户可见目标” | “开发会这样实现” |
| `prd-review` | “正在按 What-only 和证据规则评审” | “肯定能做/马上上线” |
| `rework` | “Review 打回，需修改 A/B/C” | “拒绝” |
| `accepted` | “已接受进入后续处理” | “已修复” |
| `blocked` | “当前被 X 阻塞，下一步是 Y” | “没问题” |
| `done` | “已完成，证据是 X” | 无证据宣布完成 |
| `wontfix` | “本项不处理，原因是 X” | “已修复” |
| `duplicate` | “与 #N 重复，后续归并到 #N” | “关闭即可” |
| `invalid` | “该反馈不成立，原因是 X” | “用户错了” |

## Done 判定清单

进入 `status/done` 前至少满足一项：

- 有目标仓或需求池 commit / PR / 文档更新证据；
- 有 issue 评论明确说明验收结果；
- 有源码引用证明问题本来就已支持，并完成对用户答复；
- 有人工负责人明确确认完成。

如果只是“建了 issue”“写了 PRD”“等待 Review”“解释了原因”，不得判定 done。

## Wontfix / Invalid / Duplicate 判定清单

- `wontfix`：必须有产品、技术、安全或范围原因。
- `invalid`：必须能说明反馈事实不成立，或输入不符合项目边界。
- `duplicate`：必须提供原 issue 编号或原反馈链接。

证据不足时只能 `needs-clarification` 或 `blocked`，不能为了闭环硬关。
