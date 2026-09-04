# 冻结前证据清单

- [ ] 两个 Agent 的名称、职责、prompt 摘要或截图
- [ ] GitHub public 需求池链接
- [ ] README / AGENTS / SECURITY
- [ ] label 列表截图或导出
- [ ] issue templates
- [ ] PRD 模板
- [ ] Review checklist
- [ ] cron 配置截图或 crontab 导出
- [ ] 最近至少 3 次 cron 执行日志
- [ ] 至少 1 次有变化触发的群内回报记录
- [ ] 至少 1 次 no-change 只写日志、不发群的记录
- [ ] 当前 octo-server commit hash
- [x] 引用核验记录或人工抽检记录：`scripts/verify_citations.py`，最近校验 total=1541 / passed=1541 / failed=0
- [ ] 评测集执行结果
- [x] 安全红队测试集：`evaluation/security-redteam-testset.md`
- [x] 安全抗压策略：`docs/security-redteam-playbook.md`

## 当前状态

- 本地基础包：已生成。
- GitHub public 仓库：待 GitHub CLI / API 权限可用后创建。
- octo-server 源码引用：九大知识库已补充真实路径和行号；引用校验脚本最近结果 total=1541 / passed=1541 / failed=0。
- cron 真实调度：待仓库创建后配置，不把真实敏感日志提交到 public repo。
