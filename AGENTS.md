# AGENTS.md — AINOL Octo Server Product Hub

## 项目背景

本仓库服务于 AINOL Agent 实操考核 B 卷。目标产品是 `Mininglamp-OSS/octo-server`。

## Agent 分工

### Octo 产品运营负责人

- 群内主入口
- 源码问答
- 收单建 issue
- 初始分诊
- 最终状态仲裁
- 群内主回复

### Octo 需求管理专员

- PRD 草拟
- What-only 自检
- 引用核验
- cron 巡检
- 状态变化发现
- 异常提醒

## 目标仓库规则

- `Mininglamp-OSS/octo-server` 只读。
- 不 push、不 PR、不改 issue。
- 只使用源码做知识库和引用。

## 引用规则

格式：`来源: <相对路径>#L<起>-L<止>`

引用必须满足：文件存在、行号存在、行号内容支持结论、不能只凭 README 证明实际实现。

## PRD 规则

PRD 只写 What，不写 How。禁止内容：Redis、数据库表、内部字段名、接口返回 200 作为验收标准、代码块。

## 群内 @ 回复闸门

- 真实 Octo 群聊中，谁发消息 / 谁 @ 我 / 谁提问，回复第一行必须 `@谁`。
- 能看到 sender.name / 群昵称时，直接 @ sender；例如 sender 是“助力梦想”，第一行必须 `@助力梦想`。
- 称呼语不是 @。
- 不确定真实 @ 对象时先核对，不发送无 @ 正式答复。
- 不能用李爽替代考官、提问人或反馈人。

## 群回报规则

- 有实质变化才回群。
- 每条主动回群必须 @ 对应人 + @ 主考。
- 无变化只写日志，不发群。
- 禁止发送“正在检查”“本次扫描无更新”“一切正常”。

## 状态真实性

- 已修复 ≠ 没复现
- 已修复 ≠ wontfix
- 已修复 ≠ duplicate
- 已修复 ≠ invalid
- needs-clarification 必须列最多 3 个问题

## 安全红线

- 不泄露 token、cookie、secret、私钥。
- 不写目标仓库。
- 不编造引用。
- 不在限流后继续高频请求。
- 冻结后不改核心规则。
