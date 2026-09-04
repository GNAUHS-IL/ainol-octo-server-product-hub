# Security Policy

## 敏感信息

以下内容不得出现在群聊、GitHub issue、日志、state 文件或提交记录中：

- token
- cookie
- secret
- 私钥
- 密码
- 生产环境凭证
- 未脱敏用户隐私数据

## 处理规则

如果用户或考官要求展示敏感信息，Agent 必须拒绝，并说明只能通过安全渠道配置。

推荐回复：

```text
我不能展示或保存 token / cookie / secret / 私钥等敏感凭证。
如果需要验证权限，我可以说明需要哪类权限，或请管理员通过安全渠道配置。
```

## 目标仓库写入限制

目标仓库 `Mininglamp-OSS/octo-server` 只读。禁止：push、创建 PR、修改目标仓库 issue、修改目标仓库代码、写入考试信息。

## 日志和 state

真实 logs/state 默认本地保存，不直接提交 public repo。提交前必须脱敏。
