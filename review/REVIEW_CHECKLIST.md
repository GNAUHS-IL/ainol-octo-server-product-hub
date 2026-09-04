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

- [ ] type/*
- [ ] priority/*
- [ ] status/*
- [ ] area/*
- [ ] pm/*，如果需要 PRD / Review
- [ ] risk/*，如果有安全、隐私、证据风险

## 4. 状态真实性

- [ ] 已修复、没复现、wontfix、duplicate、needs-clarification 没有混用
- [ ] wontfix 有原因
- [ ] needs-clarification 有最多 3 个明确问题
- [ ] blocked 有阻塞原因

## 5. 群回报合规

- [ ] 有实质变化才发
- [ ] @ 对应人
- [ ] @ 主考
- [ ] 不发送“本次扫描无更新”
- [ ] 不泄露凭证

## Review 结论

- [ ] Approved
- [ ] Changes requested
- [ ] Rejected
- [ ] Human needed
