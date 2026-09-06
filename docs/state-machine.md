# 状态机

本需求池使用轻量处理状态，不设置建单后的“待澄清”状态。信息不足时先在对话中澄清，达到最小建单标准后再创建 issue。

```text
status/todo
  → status/prd-drafting
  → status/reviewing
  → status/accepted
  → status/done
```

异常和关闭流转：

```text
任意状态 → status/blocked → 原状态或 status/accepted/status/done
任意状态 → status/rework → status/prd-drafting/status/reviewing
任意状态 → status/wontfix/status/duplicate/status/invalid
```
