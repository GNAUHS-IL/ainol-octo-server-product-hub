# 04 — 业务模块清单

## 知识点：是否启用模块以 `internal/modules.go` 的 blank import 注册为准，不能只看目录名

### 结论

`internal/modules.go` 通过 blank import 引入模块，Go init 后各模块调用 register 注册。源码注释也明确 Go init 顺序由依赖图决定，SQL migration 执行顺序由文件名时间戳决定，不由 import 顺序决定。

### 证据

- 来源: internal/modules.go#L1-L10
- 来源: internal/modules.go#L11-L18
- 来源: internal/modules.go#L22-L31
- 来源: internal/modules.go#L32-L41
- 来源: internal/modules.go#L42-L51
- 来源: internal/modules.go#L52-L61
- 来源: internal/modules.go#L62-L71
- 来源: internal/modules.go#L72-L78

### 适用范围

适用于回答“modules/ 下有哪些模块真正挂载/启用”。

### 不确定边界

某目录存在但未被 `internal/modules.go` 引入时，不能直接认定启用，需要继续查其他入口是否导入。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：当前主入口注册的业务模块清单

### 结论

当前 `internal/modules.go` 注册了 38 个模块：

```text
24: agentmailgateway
25: backup
26: base
30: robot
32: bot_mention
33: botfather
35: card_template_catalog
36: category
37: channel
38: common
39: conversation_ext
40: file
41: group
42: incomingwebhook
43: integration
44: internal_resolve
45: message
46: messages_search
47: notification
48: notify
49: oidc
50: opanalytics
51: openapi
52: qrcode
53: report
58: search
59: space
60: statistics
61: sticker
62: thread
63: user
66: usersecret
70: bot_api
72: app_bot
74: bot_provision
75: voice_adapter
76: webhook
77: workplace
```

### 证据

- 来源: internal/modules.go#L22-L31
- 来源: internal/modules.go#L32-L41
- 来源: internal/modules.go#L42-L51
- 来源: internal/modules.go#L52-L61
- 来源: internal/modules.go#L62-L71
- 来源: internal/modules.go#L72-L78

### 适用范围

适用于模块清单、需求归属 area 初判、issue 涉及源码路径填写。

### 不确定边界

注册模块中某些模块可能只贡献 swagger、datasource 或后台逻辑，不一定都有 HTTP API。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：模块安装发生在 API 中间件、指标、migration 兼容处理之后

### 结论

`runAPI` 在完成 token parser、日志、限流、指标、migration id rewrite、thread schema record reconcile 后调用 `module.Setup(ctx)` 安装模块。

### 证据

- 来源: main.go#L454-L463
- 来源: main.go#L464-L473
- 来源: main.go#L474-L483

### 适用范围

适用于启动顺序、模块 SQL migration、生效时机分析。

### 不确定边界

`module.Setup` 的内部排序与行为来自 `octo-lib`，如需完全证明需补查 `octo-lib`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：`internal/modules.go` 只说明包级启用；实际逻辑模块数要继续看各目录 `register.AddModule`

#### 结论

`internal/modules.go` 当前 blank import 了 38 个 `modules/*` 包，这是“包被主进程加载”的第一层事实；但一个包可以调用多次 `register.AddModule`，因此运行期逻辑模块多于 38 个。例如 `user` 包注册 `user`、`friend`、`user_manager`；`message` 包注册 `message`、`conversation`、`conversation_ext_thread_auth`、`sidebar`，并还有一个匿名 manager router；`space` 包注册 `space` 与 `space_manager`；`report` 包注册 `report` 与 `report_manager`；`workplace` 包注册 `workplace` 与 `workplace_manager`。

#### 证据

- 来源: internal/modules.go#L22-L31
- 来源: internal/modules.go#L32-L41
- 来源: internal/modules.go#L42-L51
- 来源: internal/modules.go#L52-L61
- 来源: internal/modules.go#L62-L71
- 来源: internal/modules.go#L72-L78
- 来源: modules/user/1module.go#L26-L39
- 来源: modules/user/1module.go#L104-L113
- 来源: modules/user/1module.go#L114-L123
- 来源: modules/user/1module.go#L124-L133
- 来源: modules/user/1module.go#L134-L143
- 来源: modules/user/1module.go#L144-L153
- 来源: modules/user/1module.go#L154-L163
- 来源: modules/user/1module.go#L164-L173
- 来源: modules/user/1module.go#L174-L183
- 来源: modules/user/1module.go#L184-L185
- 来源: modules/message/1module.go#L26-L35
- 来源: modules/message/1module.go#L36-L45
- 来源: modules/message/1module.go#L46-L55
- 来源: modules/message/1module.go#L56-L57
- 来源: modules/message/1module.go#L68-L77
- 来源: modules/message/1module.go#L78-L87
- 来源: modules/message/1module.go#L88-L97
- 来源: modules/message/1module.go#L98-L107
- 来源: modules/message/1module.go#L108-L112
- 来源: modules/space/1module.go#L17-L26
- 来源: modules/space/1module.go#L27-L36
- 来源: modules/space/1module.go#L37-L46
- 来源: modules/space/1module.go#L47-L52
- 来源: modules/report/1module.go#L16-L25
- 来源: modules/report/1module.go#L26-L35
- 来源: modules/report/1module.go#L36-L40
- 来源: modules/workplace/1module.go#L16-L25
- 来源: modules/workplace/1module.go#L26-L33

#### 适用范围

适用于回答“模块清单到底按目录、包 import，还是按 register.Module 计算”。考试答辩建议区分：**38 个被主入口加载的模块包**，以及**更多 register.Module 逻辑单元**。

#### 不确定边界

`register.Module` 的最终安装、排序和匿名模块显示名称由 `octo-lib/pkg/register` / `octo-lib/module` 决定，本仓只能证明模块包调用了 `register.AddModule`。

### 知识点：模块安装前存在数据库 migration 兼容处理，安装失败会阻断 API 启动

#### 结论

`runAPI` 在 `module.Setup(ctx)` 之前先执行 legacy migration id rewrite 和 thread schema record reconcile。注释说明这两步是为避免旧数据库中的 `gorp_migrations` 记录与新 SQL 文件名不一致，或 snapshot 已建 thread 表但缺少 thread migration 记录，导致 sql-migrate panic。之后才进入“模块安装”；如果 `module.Setup(ctx)` 返回错误，主进程会 panic。

#### 证据

- 来源: main.go#L454-L463
- 来源: main.go#L464-L473
- 来源: main.go#L474-L483

#### 适用范围

适用于启动失败、migration 失败、thread 表重复创建、模块为何未挂载等排障。

#### 不确定边界

`module.Setup` 内部如何合并 SQL、Start、Route、Swagger 和 Datasource，需要补查 `octo-lib`。

### 知识点：并非所有被 import 的包都会提供 HTTP API；有些只贡献 SQL、Service、Datasource 或后台 Start/Stop

#### 结论

模块能力由 `register.Module` 字段组合决定，不是只有“有目录=有 API”。典型例子：`conversation_ext` 的第一条注册只有 SQLDir 和 Service，后续 `conversation_ext_follow` 才提供 Follow API；`thread` 在 `DM_THREAD_ON` 未开启时只注册 SQLDir，不挂 API 与 archive worker；`webhook` 除 API 与 SQLDir 外还注册 Start/Stop；`oidc` 注册 API、SQLDir、Start、Stop；`messages_search` 没有 SQLDir，只注册 API/Swagger 并复用 Shared handler。

#### 证据

- 来源: modules/conversation_ext/1module.go#L73-L82
- 来源: modules/conversation_ext/1module.go#L83-L92
- 来源: modules/conversation_ext/1module.go#L93-L102
- 来源: modules/conversation_ext/1module.go#L103-L105
- 来源: modules/thread/1module.go#L24-L33
- 来源: modules/thread/1module.go#L34-L43
- 来源: modules/thread/1module.go#L44-L53
- 来源: modules/thread/1module.go#L54-L63
- 来源: modules/thread/1module.go#L64-L73
- 来源: modules/webhook/1module.go#L13-L22
- 来源: modules/webhook/1module.go#L23-L28
- 来源: modules/oidc/1module.go#L13-L25
- 来源: modules/messages_search/1module.go#L13-L24

#### 适用范围

适用于判断模块是 API 模块、后台 worker、迁移模块、服务注入模块还是组合模块。

#### 不确定边界

某些匿名 register.Module 的名称可能由框架默认处理；本仓不能断言最终日志里显示的模块名。

### 知识点：`thread` 是条件运行模块，但 schema migration 总是注册

#### 结论

`thread` 模块读取 `DM_THREAD_ON`。当值不是 `true` 或 `1` 时，它仍返回 `Name: "thread"` 与 SQLDir，让数据库 schema 保持一致，但 API 和 archive worker 不启动；开启后才创建 API、group service、archive worker，并注册 Start/Stop、SetupAPI、Swagger、SQLDir 和 IMDatasource。

#### 证据

- 来源: modules/thread/1module.go#L24-L33
- 来源: modules/thread/1module.go#L34-L43
- 来源: modules/thread/1module.go#L45-L54
- 来源: modules/thread/1module.go#L55-L64
- 来源: modules/thread/1module.go#L65-L73

#### 适用范围

适用于回答“为什么 thread 表存在但接口/worker 不工作”“DM_THREAD_ON 改变什么”。

#### 不确定边界

`DM_THREAD_ON` 运行时变更不会自动重新安装模块；需重启进程才能改变 API/worker 是否挂载。

### 知识点：IM 控制面依赖多个模块提供 `IMDatasource`，不是集中在一个模块

#### 结论

`user`、`group`、`thread` 等模块都向 `register.Module` 提供 IMDatasource。`user` 提供系统 UID 与个人频道数据源；`group` 为群频道提供 ChannelInfo、Subscribers、Blacklist、Whitelist；`thread` 为社区话题频道提供 ChannelInfo、Subscribers、Blacklist、Whitelist，并在父群解散时向子区 ChannelInfo 写入 `disband=1` 以拦截发送。

#### 证据

- 来源: modules/user/1module.go#L40-L49
- 来源: modules/user/1module.go#L50-L59
- 来源: modules/user/1module.go#L60-L69
- 来源: modules/user/1module.go#L70-L79
- 来源: modules/user/1module.go#L80-L89
- 来源: modules/user/1module.go#L90-L99
- 来源: modules/user/1module.go#L100-L100
- 来源: modules/group/1module.go#L50-L59
- 来源: modules/group/1module.go#L60-L69
- 来源: modules/group/1module.go#L70-L79
- 来源: modules/group/1module.go#L80-L89
- 来源: modules/group/1module.go#L90-L99
- 来源: modules/group/1module.go#L100-L105
- 来源: modules/thread/1module.go#L73-L82
- 来源: modules/thread/1module.go#L83-L92
- 来源: modules/thread/1module.go#L93-L102
- 来源: modules/thread/1module.go#L103-L112
- 来源: modules/thread/1module.go#L113-L122
- 来源: modules/thread/1module.go#L123-L132
- 来源: modules/thread/1module.go#L133-L140
- 来源: modules/thread/1module.go#L141-L150
- 来源: modules/thread/1module.go#L151-L160
- 来源: modules/thread/1module.go#L161-L170
- 来源: modules/thread/1module.go#L171-L180

#### 适用范围

适用于 WuKongIM 订阅、黑名单、白名单、频道信息、发送拦截等问题的初始定位。

#### 不确定边界

WuKongIM 侧如何消费 IMDatasource、缓存多久、错误如何降级，需要补查 octo-lib 与 WuKongIM 集成代码。

### 知识点：跨模块依赖大量通过“反向注册/注入”解除 import cycle

#### 结论

部分跨模块能力不是直接 import 调用，而是在模块初始化时把 checker/provider 注册给对方。例如 `group` 注册群成员检查、共同群检查、Space 成员移除清理等能力给 `user` 或 Space 清理链路；`message` 模块初始化 `conversation_ext` 全局服务后注入 ThreadAuthChecker、ThreadEnumerator、ChannelAuthChecker、ActiveMemberFilter 和 DefaultFollowedGroupGuard，用于 FollowThread/FollowChannel 的权限与物化逻辑。

#### 证据

- 来源: modules/group/1module.go#L22-L31
- 来源: modules/group/1module.go#L32-L41
- 来源: modules/group/1module.go#L42-L43
- 来源: modules/message/1module.go#L59-L68
- 来源: modules/message/1module.go#L69-L78
- 来源: modules/message/1module.go#L79-L88
- 来源: modules/message/1module.go#L89-L98
- 来源: modules/message/1module.go#L99-L103
- 来源: modules/message/1module.go#L134-L143
- 来源: modules/message/1module.go#L144-L153
- 来源: modules/message/1module.go#L154-L163
- 来源: modules/message/1module.go#L164-L173
- 来源: modules/message/1module.go#L174-L180

#### 适用范围

适用于分析“代码里没看到直接依赖为什么功能能串起来”、循环依赖规避和权限校验入口定位。

#### 不确定边界

注入对象的完整接口契约与调用点需分别查 `modules/user`、`modules/space`、`modules/conversation_ext`。

### 知识点：Bot 相关并不是单一模块，而是多模块组合

#### 结论

Bot 相关功能分散在多个注册包：`robot` 是传统机器人资料/基础能力；`botfather` 提供 Bot 管理面；`bot_api` 提供 `/v1/bot` 类 Bot API 与 SQL；`app_bot` 提供 App Bot API 与 SQL；`bot_provision` 是跨服务 JWT issuer/bot endpoint；`bot_mention` 处理 docs comment mention 的 internal token ingress；`botidentity` 目录虽存在，但未在 `internal/modules.go` blank import 注册为独立模块，而是被 `main.go` 和其它包作为库依赖使用。

#### 证据

- 来源: internal/modules.go#L28-L33
- 来源: internal/modules.go#L67-L75
- 来源: modules/robot/1module.go#L16-L28
- 来源: modules/botfather/1module.go#L16-L26
- 来源: modules/bot_api/1module.go#L13-L22
- 来源: modules/app_bot/1module.go#L13-L22
- 来源: modules/bot_provision/1module.go#L8-L16
- 来源: modules/bot_mention/1module.go#L8-L14
- 来源: main.go#L29-L34

#### 适用范围

适用于 Bot 需求归档、issue label 初判、源码问答中区分 robot/botfather/bot_api/app_bot/bot_provision/bot_mention。

#### 不确定边界

每个 Bot 子模块的路由、token、权限、OBO 能力需在 `07-bot-agent.md` 继续深挖。

### 知识点：`modules/` 下存在库型目录，不能按目录名误判为独立启用模块

#### 结论

当前 `docs/source-audit/module-inventory.md` 已记录 `botidentity`、`cardtrust`、`source` 目录存在但未被 `internal/modules.go` blank import。源码也显示 `main.go` 直接 import `modules/botidentity` 作为身份 resolver 依赖，而不是由 `internal/modules.go` 注册为模块。因此答复“模块是否启用”时必须以 `internal/modules.go` 与 `register.AddModule` 证据为准。

#### 证据

- 来源: internal/modules.go#L22-L31
- 来源: internal/modules.go#L32-L41
- 来源: internal/modules.go#L42-L51
- 来源: internal/modules.go#L52-L61
- 来源: internal/modules.go#L62-L71
- 来源: internal/modules.go#L72-L78
- 来源: main.go#L29-L34

#### 适用范围

适用于避免把库包、共享 helper、测试辅助目录误归类为 API 模块。

#### 不确定边界

库型目录可能被注册模块间接使用；未 blank import 只说明它不是主入口独立注册模块，不说明完全未参与运行。

### 知识点：session rollout 和 card dispatch 等启动级编排在 `main.go`，不属于 `modules/*` 注册模块

#### 结论

`main.go` 直接 import 并编排 `internal/cardactiondispatch`、`internal/carddispatch`、`pkg/auth`、`modules/internal_resolve`、`modules/notify` 等。特别是 `startSessionRolloutControl` 在 `main.go:958` 调用 `auth.InitializeSessionRollout(ctx)`，再绑定 writer lease、启动 reconciler、打印 session runtime 信息。这类启动级控制面不能只从 `modules/*/1module.go` 找。

#### 证据

- 来源: main.go#L23-L32
- 来源: main.go#L33-L39
- 来源: main.go#L952-L961
- 来源: main.go#L962-L971
- 来源: main.go#L972-L981
- 来源: main.go#L982-L991
- 来源: main.go#L992-L1001
- 来源: main.go#L1002-L1011
- 来源: main.go#L1012-L1015

#### 适用范围

适用于鉴权运行态、卡片分发、内部 token 排重、启动期 side effect 的归属判断。

#### 不确定边界

card action dispatch 的 routes registry 与 worker 细节需在 Bot/卡片专题继续展开。
