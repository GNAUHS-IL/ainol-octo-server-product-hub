# 人工接管策略

遇到凭证、权限、限流、证据冲突、连续两次无法分类、业务决策不明确时，转人工接管。

如需要归档到需求池：

- 使用 `priority/P0` 表达高风险或核心阻塞。
- 使用 `status/blocked` 表达当前不能继续推进。
- 使用对应 `area/*` 表达影响的 octo-server 知识库领域；无法判断时用 `area/unknown`。
- 在 issue 正文或 comment 中写脱敏后的“人工接管原因”。

不再使用 `pm/human-needed` 或 `risk/*` label。
