# [Feature] 补充认证入口与鉴权方式说明

## 类型

用户源码问答已直接回答；该 issue 仅记录问答后暴露出的文档补充工作项。

## 初始 labels

- type/feature
- priority/P2
- status/prd-drafting
- area/docs
- area/auth
- source/evaluation
- evidence/source-verified
- pm/needs-prd

## 背景

用户询问 octo-server 的认证入口与鉴权方式。若源码可以直接回答，群内直接回复，不建 issue；本样例假设问答暴露出 README/使用说明缺少认证入口说明，因此转为文档补充需求。

## 需求

补充用户可理解的认证入口和鉴权方式说明，避免用户必须阅读源码才能完成基本配置。

## 证据

认证逻辑和 token 解析需以源码引用为准，引用格式：`来源: <相对路径>#L<起>-L<止>`。

## 不确定点

需确认文档补充位置：README、docs 目录，或单独的 Bot/API 使用说明。
