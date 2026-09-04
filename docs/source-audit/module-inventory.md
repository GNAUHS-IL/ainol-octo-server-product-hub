# 模块注册与目录全量索引

- Target commit: `49dc9fd97b49c6c9bad9a0abaefb0b48241e9601`
- 判断是否启用模块，以 `internal/modules.go` 的 blank import 为准。
- `modules/` 下有目录但未注册，不等于 API 启用。

## 注册模块

| 模块 | 注册来源 | Go 文件数(非测试) | SQL migration 数 |
|---|---|---:|---:|
| `agentmailgateway` | 来源: internal/modules.go#L24-L24 | 5 | 0 |
| `backup` | 来源: internal/modules.go#L25-L25 | 9 | 2 |
| `base` | 来源: internal/modules.go#L26-L26 | 19 | 6 |
| `robot` | 来源: internal/modules.go#L30-L30 | 15 | 10 |
| `bot_mention` | 来源: internal/modules.go#L32-L32 | 6 | 0 |
| `botfather` | 来源: internal/modules.go#L33-L33 | 22 | 10 |
| `card_template_catalog` | 来源: internal/modules.go#L35-L35 | 14 | 2 |
| `category` | 来源: internal/modules.go#L36-L36 | 8 | 5 |
| `channel` | 来源: internal/modules.go#L37-L37 | 7 | 3 |
| `common` | 来源: internal/modules.go#L38-L38 | 18 | 18 |
| `conversation_ext` | 来源: internal/modules.go#L39-L39 | 7 | 7 |
| `file` | 来源: internal/modules.go#L40-L40 | 15 | 0 |
| `group` | 来源: internal/modules.go#L41-L41 | 22 | 17 |
| `incomingwebhook` | 来源: internal/modules.go#L42-L42 | 21 | 11 |
| `integration` | 来源: internal/modules.go#L43-L43 | 5 | 1 |
| `internal_resolve` | 来源: internal/modules.go#L44-L44 | 4 | 0 |
| `message` | 来源: internal/modules.go#L45-L45 | 43 | 19 |
| `messages_search` | 来源: internal/modules.go#L46-L46 | 37 | 0 |
| `notification` | 来源: internal/modules.go#L47-L47 | 5 | 2 |
| `notify` | 来源: internal/modules.go#L48-L48 | 22 | 3 |
| `oidc` | 来源: internal/modules.go#L49-L49 | 45 | 3 |
| `opanalytics` | 来源: internal/modules.go#L50-L50 | 11 | 3 |
| `openapi` | 来源: internal/modules.go#L51-L51 | 2 | 0 |
| `qrcode` | 来源: internal/modules.go#L52-L52 | 4 | 0 |
| `report` | 来源: internal/modules.go#L53-L53 | 6 | 2 |
| `search` | 来源: internal/modules.go#L58-L58 | 3 | 0 |
| `space` | 来源: internal/modules.go#L59-L59 | 22 | 14 |
| `statistics` | 来源: internal/modules.go#L60-L60 | 3 | 0 |
| `sticker` | 来源: internal/modules.go#L61-L61 | 6 | 3 |
| `thread` | 来源: internal/modules.go#L62-L62 | 7 | 8 |
| `user` | 来源: internal/modules.go#L63-L63 | 63 | 37 |
| `usersecret` | 来源: internal/modules.go#L66-L66 | 8 | 1 |
| `bot_api` | 来源: internal/modules.go#L70-L70 | 37 | 3 |
| `app_bot` | 来源: internal/modules.go#L72-L72 | 5 | 5 |
| `bot_provision` | 来源: internal/modules.go#L74-L74 | 5 | 0 |
| `voice_adapter` | 来源: internal/modules.go#L75-L75 | 4 | 1 |
| `webhook` | 来源: internal/modules.go#L76-L76 | 18 | 3 |
| `workplace` | 来源: internal/modules.go#L77-L77 | 6 | 3 |

## modules/ 目录存在但未在 internal/modules.go 注册

- `botidentity`（目录存在；未在 `internal/modules.go` blank import 注册，需按库/被依赖包理解，不可直接判定为独立启用模块）
- `cardtrust`（目录存在；未在 `internal/modules.go` blank import 注册，需按库/被依赖包理解，不可直接判定为独立启用模块）
- `source`（目录存在；未在 `internal/modules.go` blank import 注册，需按库/被依赖包理解，不可直接判定为独立启用模块）

## V2 逻辑模块补充（2026-09-04）

> 说明：上表按 `internal/modules.go` blank import 统计“被主入口加载的模块包”。实际运行时还要看各包内 `register.AddModule`，因为一个包可以注册多个逻辑模块，且部分模块没有显式 `Name`。

### 多逻辑模块 / 匿名模块

| 包目录 | register.Module 现象 | 证据 |
|---|---|---|
| `modules/user` | 注册 `user`、`friend`、`user_manager` | 来源: modules/user/1module.go#L26-L39；来源: modules/user/1module.go#L104-L185 |
| `modules/message` | 注册 `message`、`conversation`、匿名 manager router、`conversation_ext_thread_auth`、`sidebar` | 来源: modules/message/1module.go#L26-L57；来源: modules/message/1module.go#L68-L112 |
| `modules/space` | 共享同一个 `Space` 实例注册 `space`、`space_manager` | 来源: modules/space/1module.go#L17-L52 |
| `modules/report` | 注册 `report`、`report_manager` | 来源: modules/report/1module.go#L16-L40 |
| `modules/workplace` | 注册 `workplace`、`workplace_manager` | 来源: modules/workplace/1module.go#L16-L33 |
| `modules/common` | 注册 `common` 与匿名 manager router | 来源: modules/common/1module.go#L16-L34 |
| `modules/base` | 注册匿名 app/base router 与 SQLDir | 来源: modules/base/1module.go#L14-L24 |
| `modules/qrcode` | 注册匿名 qrcode router | 来源: modules/qrcode/1module.go#L8-L17 |
| `modules/webhook` | 注册匿名 webhook router，带 SQLDir、Start、Stop | 来源: modules/webhook/1module.go#L13-L28 |

### 条件运行 / 非单纯 HTTP API 模块

| 模块 | 运行特征 | 证据 |
|---|---|---|
| `thread` | `DM_THREAD_ON` 未开启时仅注册 `Name: "thread"` 与 SQLDir；开启后才注册 API、archive worker、IMDatasource | 来源: modules/thread/1module.go#L24-L73 |
| `conversation_ext` | 第一条模块只初始化全局 service/db 并注册 SQLDir/Service；Follow API 是第二条 `conversation_ext_follow` | 来源: modules/conversation_ext/1module.go#L73-L105 |
| `oidc` | 注册 API、SQLDir，并通过 `Start: o.Init` / `Stop: o.Close` 管理生命周期 | 来源: modules/oidc/1module.go#L13-L25 |
| `messages_search` | 无 SQLDir，注册 Shared handler 与 Swagger | 来源: modules/messages_search/1module.go#L13-L24 |
| `voice_adapter` | 从 env 构造配置，缺 `SPEECH_SERVICE_URL` 只告警；注册 API 与 SQLDir | 来源: modules/voice_adapter/1module.go#L14-L31 |

### 启动级编排不在 `modules/*/1module.go`

`main.go` 直接负责部分启动级控制面，例如 session rollout：`main.go:958` 调用 `auth.InitializeSessionRollout(ctx)`，随后绑定 writer lease、启动 reconciler 并打印 runtime 信息。不能把所有运行时能力都归因到 `register.Module`。

- 来源: main.go#L23-L39
- 来源: main.go#L952-L1015
