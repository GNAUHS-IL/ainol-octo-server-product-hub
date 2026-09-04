# [Question] octo-server 的认证入口在哪里？

## 类型

type/question

## 初始 labels

- type/question
- priority/P2
- status/needs-clarification
- area/auth
- source/evaluation
- risk/evidence-missing

## 问题

octo-server 的用户 token、Web 登录 cookie、bot_api 认证分别从哪些入口进入？

## 当前处理

待只读 clone `Mininglamp-OSS/octo-server` 后核验：`main.go`、`pkg/auth/`、`modules/user/`、`modules/bot_api/`。

## 证据

- 待补：来源: <相对路径>#L<起>-L<止>

## 不确定点

当前本地源码 checkout 未完成，不能编造路径和行号。
