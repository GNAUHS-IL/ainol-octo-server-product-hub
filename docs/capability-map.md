# octo-server 能力地图

本页按产品能力而不是源码目录组织，便于把用户反馈快速映射到知识库、源码索引和 issue label。

## 能力总览

| 产品能力 | 典型问题 | 主要模块/路径 | 建议 area label | 证据 |
|---|---|---|---|---|
| 用户身份与个人资料 | 登录态、当前用户、资料修改、设备 token、授权登录 | `modules/user`、`pkg/auth` | `area/auth` | 来源: modules/user/api.go#L319-L324 |
| 用户检索与批量查询 | 按 UID 查询、批量查询、搜索用户 | `modules/user` | `area/auth` | 来源: modules/user/api.go#L270-L280；来源: modules/user/api.go#L284-L285 |
| 组织/空间 | 空间创建、成员管理、角色、邀请 | `modules/space` | `area/rbac` | 来源: modules/space/api.go#L83-L97 |
| 群组 | 建群、群成员、群设置、群资料 | `modules/group` | `area/im`、`area/rbac` | 来源: modules/group/api.go#L94-L96；来源: modules/group/api.go#L105-L113 |
| 消息 | 消息同步、撤回、删除、已读、typing、敏感词同步 | `modules/message` | `area/im` | 来源: modules/message/api.go#L365-L377 |
| 话题/Thread | thread 查看、更新、成员、归档、Markdown | `modules/thread` | `area/im` | 来源: modules/thread/api.go#L185-L196 |
| Bot API | Bot 注册、心跳、发消息、事件、群/用户解析 | `modules/bot_api` | `area/bot-agent` | 来源: modules/bot_api/bot_api.go#L331-L331；来源: modules/bot_api/bot_api.go#L365-L365；来源: modules/bot_api/bot_api.go#L410-L417；来源: modules/bot_api/bot_api.go#L422-L424 |
| App Bot 管理 | Bot 详情、更新、删除、token、发布/取消发布 | `modules/app_bot` | `area/bot-agent` | 来源: modules/app_bot/app_bot.go#L123-L129；来源: modules/app_bot/app_bot.go#L137-L140 |
| 文件与对象存储 | 文件预览、上传、预签名上传、下载 URL | `modules/file`、`configs/tsdd.yaml` | `area/storage` | 来源: modules/file/api.go#L89-L98；来源: configs/tsdd.yaml#L135-L145；来源: configs/tsdd.yaml#L146-L158；来源: configs/tsdd.yaml#L159-L170 |
| 搜索 | 全局消息/文件/群搜索、附近消息、媒体搜索 | `modules/messages_search` | `area/api-error`、`area/im` | 来源: modules/messages_search/search_all.go#L25-L25；来源: modules/messages_search/search_global_messages.go#L28-L28；来源: modules/messages_search/search_files.go#L59-L59；来源: modules/messages_search/search_around.go#L27-L27 |
| 通知 | 通知发送、批量通知、卡片变更、通知暂停 | `modules/notify`、`modules/notification` | `area/modules` | 来源: modules/notify/api.go#L210-L212；来源: modules/notification/api.go#L34-L36 |
| Webhook / Datasource | 入站 webhook、datasource、消息通知、GitHub webhook | `modules/webhook`、`modules/incomingwebhook` | `area/api-error`、`area/modules` | 来源: modules/webhook/api.go#L150-L158；来源: modules/incomingwebhook/api.go#L292-L298 |
| 第三方登录/OIDC | OIDC authorize/callback/exchange/logout、账号绑定 | `modules/oidc` | `area/auth`、`area/storage` | 来源: modules/oidc/api.go#L399-L400；来源: modules/oidc/api.go#L421-L425；来源: modules/oidc/api_bind.go#L95-L96 |
| 管理与运维 | 备份配置、触发、历史、状态 | `modules/backup` | `area/storage`、`area/build-release` | 来源: modules/backup/api_manager.go#L49-L60 |
| 工作台 | Banner、应用排序、常用记录、应用分类 | `modules/workplace` | `area/modules` | 来源: modules/workplace/api.go#L35-L44；来源: modules/workplace/api_manager.go#L41-L42 |
| 开放平台 | access token、userinfo、authcode | `modules/openapi` | `area/auth` | 来源: modules/openapi/api.go#L63-L70 |
| 构建与发布 | Go build、Docker 镜像、CI、部署入口 | `Dockerfile`、`Makefile`、`.github/workflows` | `area/build-release` | 来源: Dockerfile#L11-L20；来源: Dockerfile#L26-L32；来源: Makefile#L15-L24；来源: .github/workflows/ci.yml#L7-L15 |

## 使用方式

1. 先按用户反馈判断产品能力。
2. 用“建议 area label”给 issue 打领域标签。
3. 到对应 `knowledge/*.md` 查结论。
4. 需要完整路由或错误码时，再查 `docs/source-audit/*-index.md`。
5. 若本表与源码证据冲突，以目标仓当前源码为准。
