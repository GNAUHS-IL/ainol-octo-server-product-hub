# Citation Verification

本页记录交付前引用校验机制和最近一次校验摘要。完整执行日志保存在本地 `state/`，公开仓库只提交不含敏感信息的摘要。

## 校验脚本

```bash
scripts/verify_citations.py --docs-root . --source-root ../octo-server
```

校验范围：需求池仓库内所有 Markdown 文件中的引用格式：

```text
来源: <相对路径>#L<起>-L<止>
```

校验项：

- 引用路径必须是 `octo-server` 仓库相对路径。
- 引用路径不得使用绝对路径或 `..` 越界。
- 源文件必须存在。
- 起止行号必须为正整数。
- 结束行不得小于起始行。
- 结束行不得超过源文件总行数。

## 最近一次校验摘要

- source root：`../octo-server`
- docs root：`.`
- total：1541
- passed：1541
- failed：0
- status：ok

## 失败处理规则

- 任一引用失败时，不得把对应结论作为确定结论对外发送。
- 需要补查源码并更新真实路径/行号；在 issue 正文或 comment 中记录“源码证据待补查/引用失效”。
- 证据状态由正文、comment、PRD 或 review checklist 承载，不新增证据类 label。
- 修复方式只能是补查源码并更新真实路径/行号；不得编造路径或使用 README 替代实现证据。
