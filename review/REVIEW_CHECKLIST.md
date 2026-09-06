# Review Checklist

## 1. 引用核验

- [ ] 文件路径存在
- [ ] 行号存在
- [ ] 行号内容支持结论
- [ ] 引用格式符合：来源: <相对路径>#L<起>-L<止>
- [ ] 没有把 README 当成唯一实现证据

## 2. PRD What-only 检查

- [ ] 没写 Redis
- [ ] 没写数据库表
- [ ] 没写内部字段名
- [ ] 没写接口返回 200 作为验收标准
- [ ] 没贴代码块
- [ ] 验收标准是用户可感知的

## 3. Label 完整性

- [ ] 有且仅有一个 `type/*`
- [ ] 有且仅有一个 `priority/*`
- [ ] 有且仅有一个 `status/*`
- [ ] 至少一个 `area/*`
- [ ] 不新增流程类、来源类、证据类或风险类 label

## 4. 状态真实性

- [ ] 已修复、没复现、wontfix、duplicate、invalid 没有混用
- [ ] wontfix 有原因
- [ ] blocked 有阻塞原因
- [ ] done 有完成证据

## 5. 群回报合规

- [ ] 有实质变化才发
- [ ] @ 对应人
- [ ] @ 外部审核方
- [ ] 不发送“本次扫描无更新”
- [ ] 不泄露凭证

## Review 结论

- [ ] Approved
- [ ] Changes requested
- [ ] Rejected
- [ ] Human needed

## 6. Evidence Gate

- [ ] Source path exists in `Mininglamp-OSS/octo-server`.
- [ ] Line numbers exist and directly support the conclusion.
- [ ] Single citation span is precise, normally no more than 15 lines.
- [ ] README/docs can support product context, but implementation claims need code/config evidence.

## 7. What-only Gate

PRD content must describe user-visible needs and acceptance criteria only. It must not prescribe Redis, database tables, internal field names, SQL, queues, code blocks, or HTTP status codes as acceptance criteria.
