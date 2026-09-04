# Cron / Scheduler Evidence

本页说明需求池定时扫描的证据口径。真实运行日志与状态文件默认保存在本地环境，不提交到 public repo；公开仓只保留脱敏格式说明和验证规则。

## 证明目标

- 定时任务不是人工临时触发。
- 有变化时能识别 issue 状态变化并同步处理。
- 无变化时只记录日志，不做外部刷屏。
- 遇到限流时停止本轮扫描并记录 `rate_limited`。

## 日志字段建议

```json
{
  "run_at": "<iso8601>",
  "source": "scheduler",
  "changed_issues": [],
  "rate_limited": false,
  "notified": false
}
```

## 本地状态字段建议

```json
{
  "last_scan_at": "<iso8601>",
  "last_seen_issue_updated_at": null,
  "rate_limited": false
}
```

## 提交规则

- 真实日志、真实 state、token、cookie、secret、私钥不得提交到 public repo。
- public repo 只保留脱敏样例和流程说明。
- 如需证明最近执行情况，优先提交摘要或截图，不提交原始敏感日志。
