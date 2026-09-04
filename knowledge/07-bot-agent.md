# 07 — Bot 与 Agent

## 知识点：Bot API 主路由集中在 `/v1/bot`，覆盖消息、群、Thread、文件、卡片、voice、OBO 等能力

### 结论

`modules/bot_api/bot_api.go` 把 `/v1/bot` 组挂在 `authBot → requireBotIdentity → rateLimit` 后面，注册 sendMessage、typing、readReceipt、events、groups、threads、file、card、voice context、OBO grant 等端点。

### 证据

- 来源: modules/bot_api/bot_api.go#L377-L386
- 来源: modules/bot_api/bot_api.go#L387-L396
- 来源: modules/bot_api/bot_api.go#L397-L406
- 来源: modules/bot_api/bot_api.go#L407-L408
- 来源: modules/bot_api/bot_api.go#L410-L419
- 来源: modules/bot_api/bot_api.go#L420-L429
- 来源: modules/bot_api/bot_api.go#L430-L439
- 来源: modules/bot_api/bot_api.go#L440-L449
- 来源: modules/bot_api/bot_api.go#L450-L459
- 来源: modules/bot_api/bot_api.go#L460-L467

### 适用范围

适用于 Bot API 能力清单、Agent 操作 Octo 的后端入口说明。

### 不确定边界

每个接口的请求/响应字段需继续查对应 handler 和 swagger。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：Bot 注册和心跳是自愈通道，单独从全局限流中剥离并配置专属限流

### 结论

`/v1/bot/register` 和 `/v1/bot/heartbeat` 被注释标注为 issue #696 的自愈通道；注册路径先 per-IP 再 per-token，心跳路径先 per-IP，再 `authBot + requireBotIdentity`，再 per-bot 限流。

### 证据

- 来源: modules/bot_api/bot_api.go#L298-L307
- 来源: modules/bot_api/bot_api.go#L308-L317
- 来源: modules/bot_api/bot_api.go#L318-L327
- 来源: modules/bot_api/bot_api.go#L328-L337
- 来源: modules/bot_api/bot_api.go#L338-L339
- 来源: modules/bot_api/bot_api.go#L341-L350
- 来源: modules/bot_api/bot_api.go#L351-L360
- 来源: modules/bot_api/bot_api.go#L361-L370
- 来源: modules/bot_api/bot_api.go#L371-L375

### 适用范围

适用于解释 Agent/Bot 断联恢复、register/heartbeat 抗风暴设计。

### 不确定边界

register/heartbeat body 字段与 WuKongIM token 刷新细节需继续深挖 `modules/bot_api/register.go`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：BotFather 现在不承载 `/v1/bot/*` 主 API，而负责文档、User Bot 管理、User API Key、Robot Apply、runtime onboarding 等

### 结论

BotFather 的 Route 注释明确 `/v1/bot/*` 已迁移到 `modules/bot_api/`；BotFather 保留文档端点、User Bot 管理、User API Key、Robot Apply、runtime onboarding，同时启动时同步 bot token 到 WuKongIM。

### 证据

- 来源: modules/botfather/api.go#L83-L92
- 来源: modules/botfather/api.go#L93-L102
- 来源: modules/botfather/api.go#L103-L112
- 来源: modules/botfather/api.go#L113-L121

### 适用范围

适用于区分 botfather 与 bot_api 的职责边界。

### 不确定边界

User API Key 的具体认证逻辑需继续查 `modules/botfather/api_user*.go`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：botidentity 是 bot UID 的权威身份解析器，读取 robot 和 app_bot 两张生命周期权威表

### 结论

`botidentity` 包注释说明只读取 `robot` 和 `app_bot` 表，`user.robot` 只是展示元数据而非授权来源；若同一 uid 同时存在于两张活跃表，会返回 ambiguous 错误并要求调用方 fail closed。

### 证据

- 来源: modules/botidentity/resolver.go#L1-L4
- 来源: modules/botidentity/resolver.go#L59-L68
- 来源: modules/botidentity/resolver.go#L69-L76
- 来源: modules/botidentity/resolver.go#L92-L101
- 来源: modules/botidentity/resolver.go#L102-L111
- 来源: modules/botidentity/resolver.go#L112-L120

### 适用范围

适用于 bot 身份边界、User Bot/App Bot 冲突处理、权限 fail-closed 说明。

### 不确定边界

哪些调用方使用 botidentity 需要继续全仓搜索引用。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：Bot API 鉴权按 token 前缀分流 User Bot 与 App Bot，并只接受 Bearer token

#### 结论

`authBot` 从 `Authorization: Bearer ...` 提取 token；`app_` 前缀进入 App Bot 鉴权，否则按 User Bot/legacy token 查 `robot` 表。User Bot 鉴权成功后写入 `robot_id`、`bot_kind=user` 与 robot 模型；App Bot 先查共享 registry/cache，miss 后查 DB，并要求 `status==1` 才能继续，成功后写入 `robot_id`、`bot_kind=app`、`app_bot_scope` 与可选 `app_bot_space_id`。

#### 证据

- 来源: modules/bot_api/auth.go#L25-L34
- 来源: modules/bot_api/auth.go#L35-L40
- 来源: modules/bot_api/auth.go#L46-L55
- 来源: modules/bot_api/auth.go#L56-L61
- 来源: modules/bot_api/auth.go#L64-L73
- 来源: modules/bot_api/auth.go#L74-L83
- 来源: modules/bot_api/auth.go#L84-L93
- 来源: modules/bot_api/auth.go#L94-L103
- 来源: modules/bot_api/auth.go#L104-L113
- 来源: modules/bot_api/auth.go#L114-L123
- 来源: modules/bot_api/auth.go#L124-L129
- 来源: modules/bot_api/auth.go#L143-L149

#### 适用范围

适用于解释 `/v1/bot/*` 为什么只认 Bearer token、User Bot 与 App Bot 的身份上下文差异、App Bot 未发布为什么不能调用 Bot API。

#### 不确定边界

User Bot token 的创建/轮换主要在 BotFather/robot 相关路径；本条只覆盖 Bot API 请求时的鉴权分流。

### 知识点：`requireBotIdentity` 是 Bot API 主组的 fail-closed 身份断言，不把 robotID 冒充为登录 uid

#### 结论

Bot API 主组顺序是 `authBot → requireBotIdentity → rateLimit`。`requireBotIdentity` 只断言 `authBot` 已写入 `robot_id`，缺失则 fail-closed 中止；注释明确不再使用会 `c.Set("uid", robotID)` 的旧写法，避免 handler 通过 `GetLoginUID()` 静默拿到 robotID，从而混淆 Bot 身份与真人登录身份。

#### 证据

- 来源: modules/bot_api/bot_api.go#L377-L386
- 来源: modules/bot_api/bot_api.go#L387-L396
- 来源: modules/bot_api/bot_api.go#L397-L406
- 来源: modules/bot_api/bot_api.go#L407-L408
- 来源: modules/bot_api/ratelimit.go#L176-L185
- 来源: modules/bot_api/ratelimit.go#L186-L195
- 来源: modules/bot_api/ratelimit.go#L196-L203

#### 适用范围

适用于 Bot API 权限边界、限流维度、为什么 bot 请求上下文不能当作真人 uid 使用。

#### 不确定边界

个别 user-token 端点如 `/v1/obo/*` 不在 Bot token 主组内，应单独按用户认证链路判断。

### 知识点：Bot 注册会刷新 WuKongIM token；User Bot 可上报 runtime，App Bot 不支持 runtime 上报

#### 结论

`register` 先抽取 Bot token，再按 `app_` 前缀分流。User Bot 注册会查 robot、调用 `UpdateIMToken` 用 robot 的 BotToken 刷新 WuKongIM token，并可解析可选 runtime/hosting 上报字段；App Bot 注册同样调用 `UpdateIMToken`，但注释明确 App Bot 表没有 runtime 字段，因此忽略 agent runtime 上报，只返回 App Bot 的 uid、display_name、token、scope、space_id 等注册响应。

#### 证据

- 来源: modules/bot_api/register.go#L304-L313
- 来源: modules/bot_api/register.go#L314-L323
- 来源: modules/bot_api/register.go#L324-L333
- 来源: modules/bot_api/register.go#L334-L343
- 来源: modules/bot_api/register.go#L344-L353
- 来源: modules/bot_api/register.go#L354-L363
- 来源: modules/bot_api/register.go#L364-L373
- 来源: modules/bot_api/register.go#L374-L382
- 来源: modules/bot_api/register.go#L437-L446
- 来源: modules/bot_api/register.go#L447-L456
- 来源: modules/bot_api/register.go#L457-L466
- 来源: modules/bot_api/register.go#L467-L476
- 来源: modules/bot_api/register.go#L477-L486
- 来源: modules/bot_api/register.go#L487-L496
- 来源: modules/bot_api/register.go#L497-L506
- 来源: modules/bot_api/register.go#L181-L190
- 来源: modules/bot_api/register.go#L191-L200
- 来源: modules/bot_api/register.go#L201-L210
- 来源: modules/bot_api/register.go#L211-L220
- 来源: modules/bot_api/register.go#L221-L230
- 来源: modules/bot_api/register.go#L231-L231

#### 适用范围

适用于 Bot/Agent 断线重连、runtime 自描述、为什么 App Bot 不能通过 register 写入 agent runtime 信息。

#### 不确定边界

runtime 上报字段如何展示或被调度使用，需要继续查 BotFather runtime onboarding 与相关 DB 字段。

### 知识点：Bot API 限流分 business / heartbeat / register 三通道，身份维度不同

#### 结论

Bot API 限流设计把通道拆成 business、heartbeat、register。business 和 heartbeat 以 bot 身份为维度；register 在 `authBot` 之前，尚无 bot 身份，因此用 token 指纹作为限流 key。注册和心跳都从全局 per-IP 桶剥离后仍加了专属 IP 底线，避免共享出网 IP 下某个 bot 风暴拖垮其它 bot 的自愈能力。

#### 证据

- 来源: modules/bot_api/ratelimit.go#L23-L32
- 来源: modules/bot_api/ratelimit.go#L33-L42
- 来源: modules/bot_api/ratelimit.go#L43-L47
- 来源: modules/bot_api/ratelimit.go#L332-L341
- 来源: modules/bot_api/ratelimit.go#L342-L351
- 来源: modules/bot_api/ratelimit.go#L352-L361
- 来源: modules/bot_api/ratelimit.go#L362-L371
- 来源: modules/bot_api/ratelimit.go#L372-L375
- 来源: modules/bot_api/bot_api.go#L298-L307
- 来源: modules/bot_api/bot_api.go#L308-L317
- 来源: modules/bot_api/bot_api.go#L318-L327
- 来源: modules/bot_api/bot_api.go#L328-L337
- 来源: modules/bot_api/bot_api.go#L338-L347
- 来源: modules/bot_api/bot_api.go#L348-L357
- 来源: modules/bot_api/bot_api.go#L358-L367
- 来源: modules/bot_api/bot_api.go#L368-L375

#### 适用范围

适用于解释 Bot API 429、register/heartbeat 为什么不和普通接口共用限流、为什么 register 的维度不是 robotID。

#### 不确定边界

实际 RPS/Burst 来自 system setting/env 注入，需结合运行时配置确认当前阈值。

### 知识点：App Bot 管理面分平台与 Space 两套路由，必须做 route-scope 防 IDOR

#### 结论

App Bot 管理面包含 `/v1/admin/app_bot` 平台路由、`/v1/space/:space_id/app_bot` Space 路由、`/v1/app_bot/available` 发现接口和 `/v1/app_bot/apply` 用户 opt-in 接口。`botInRouteScope` 明确约束：平台路由只能管理 platform-scoped bot，Space 路由只能管理对应 space 的 space-scoped bot，避免平台路由按全局 id 读/转/泄露其它 Space bot token。

#### 证据

- 来源: modules/app_bot/app_bot.go#L116-L125
- 来源: modules/app_bot/app_bot.go#L126-L135
- 来源: modules/app_bot/app_bot.go#L136-L145
- 来源: modules/app_bot/app_bot.go#L146-L152
- 来源: modules/app_bot/app_bot.go#L171-L183

#### 适用范围

适用于 App Bot 管理权限、跨租户 IDOR 风险、平台 bot 与 Space bot 的职责边界。

#### 不确定边界

handler 内部还包含管理员/Space admin 检查；本条只覆盖路由分层和 route-scope 约束。

### 知识点：App Bot 创建时同时写 app_bot、注册 IM token；删除时清 registry、删记录并失效 IM token

#### 结论

创建 App Bot 时生成 `app_` token、构造 bot uid，写入 `app_bot` 表，然后调用 `UpdateIMToken` 注册 IM token；若 IM token 注册失败，会删除 app_bot 记录并用新 token 尝试撤销原 IM token。删除 App Bot 时先确认 route scope，再移出本地 registry，删除 DB 记录，并调用 `UpdateIMToken` 用新 token 覆盖旧 token，使原 bot token 立即失效。

#### 证据

- 来源: modules/app_bot/app_bot.go#L330-L339
- 来源: modules/app_bot/app_bot.go#L340-L349
- 来源: modules/app_bot/app_bot.go#L350-L359
- 来源: modules/app_bot/app_bot.go#L360-L369
- 来源: modules/app_bot/app_bot.go#L370-L379
- 来源: modules/app_bot/app_bot.go#L380-L389
- 来源: modules/app_bot/app_bot.go#L390-L399
- 来源: modules/app_bot/app_bot.go#L400-L409
- 来源: modules/app_bot/app_bot.go#L410-L419
- 来源: modules/app_bot/app_bot.go#L420-L429
- 来源: modules/app_bot/app_bot.go#L430-L439
- 来源: modules/app_bot/app_bot.go#L440-L440
- 来源: modules/app_bot/app_bot.go#L664-L673
- 来源: modules/app_bot/app_bot.go#L674-L683
- 来源: modules/app_bot/app_bot.go#L684-L693
- 来源: modules/app_bot/app_bot.go#L694-L703
- 来源: modules/app_bot/app_bot.go#L704-L705
- 来源: modules/app_bot/app_bot.go#L253-L262
- 来源: modules/app_bot/app_bot.go#L263-L272
- 来源: modules/app_bot/app_bot.go#L273-L282
- 来源: modules/app_bot/app_bot.go#L283-L290

#### 适用范围

适用于 App Bot token 生命周期、删除/撤销后的请求为什么应失败、registry 与 DB/IM token 的一致性解释。

#### 不确定边界

token rotate、publish/unpublish 的完整一致性流程在同文件后续 handler，可按需要单独深挖。

### 知识点：OBO 管理面是 user-token 路由，send hot path 复用 grant/scope/live-access 四层检查

#### 结论

OBO REST 挂在 `/v1/obo`，使用普通用户认证，不是 Bot token 主组。创建 grant 时 grantor 取自登录用户，且 grantee_bot_uid 必须解析为调用者拥有的 user bot。Bot 以 grantor 身份发送时，`checkOBO` 统一检查：存在 active grant、scope row 允许或 global_enabled 隐式允许、grantor 当前仍有频道读权限；失败统一返回 `ErrOBONotAuthorized`，避免探测 grant/scope 是否存在。

#### 证据

- 来源: modules/bot_api/obo_api.go#L100-L109
- 来源: modules/bot_api/obo_api.go#L110-L117
- 来源: modules/bot_api/obo_api.go#L187-L196
- 来源: modules/bot_api/obo_api.go#L197-L206
- 来源: modules/bot_api/obo_api.go#L207-L216
- 来源: modules/bot_api/obo_api.go#L217-L226
- 来源: modules/bot_api/obo_api.go#L227-L236
- 来源: modules/bot_api/obo_api.go#L237-L246
- 来源: modules/bot_api/obo_api.go#L247-L250
- 来源: modules/bot_api/obo_check.go#L20-L29
- 来源: modules/bot_api/obo_check.go#L30-L39
- 来源: modules/bot_api/obo_check.go#L40-L49
- 来源: modules/bot_api/obo_check.go#L50-L59
- 来源: modules/bot_api/obo_check.go#L60-L67
- 来源: modules/bot_api/obo_check.go#L78-L87
- 来源: modules/bot_api/obo_check.go#L88-L97
- 来源: modules/bot_api/obo_check.go#L98-L107
- 来源: modules/bot_api/obo_check.go#L108-L117
- 来源: modules/bot_api/obo_check.go#L118-L127
- 来源: modules/bot_api/obo_check.go#L128-L132

#### 适用范围

适用于 OBO persona、机器人代发、scope 授权、用户离群/取消好友后代发应失效的判断。

#### 不确定边界

OBO fanout、搜索、DM friend gate 的细节分布在 `obo_fanout.go`、`obo_friend_gate.go`、`search_route.go`，本条只覆盖 REST 管理与发送授权核心。

### 知识点：Bot Mention 是内部入口，靠 internal token、feature gate、idempotency claim 和 bot 存在性保护

#### 结论

`bot_mention` 只暴露 `/v1/internal/bot-mentions`，使用内部 token 常量时间比较鉴权。create 流程会规范化请求、按 botUID + idempotencyKey 建 claim key 和 fingerprint，先查已有 claim；feature gate 不允许时返回 accepted=false、reason=disabled；bot 不存在时返回 not_found；并通过 Begin/Commit/Release claim 处理 in-progress、replay、conflict 等幂等状态。

#### 证据

- 来源: modules/bot_mention/api.go#L70-L79
- 来源: modules/bot_mention/api.go#L80-L89
- 来源: modules/bot_mention/api.go#L90-L90
- 来源: modules/bot_mention/api.go#L106-L115
- 来源: modules/bot_mention/api.go#L116-L125
- 来源: modules/bot_mention/api.go#L126-L135
- 来源: modules/bot_mention/api.go#L136-L136
- 来源: modules/bot_mention/api.go#L148-L157
- 来源: modules/bot_mention/api.go#L158-L167
- 来源: modules/bot_mention/api.go#L168-L177
- 来源: modules/bot_mention/api.go#L178-L187
- 来源: modules/bot_mention/api.go#L188-L197
- 来源: modules/bot_mention/api.go#L198-L207
- 来源: modules/bot_mention/api.go#L208-L217
- 来源: modules/bot_mention/api.go#L218-L226
- 来源: modules/bot_mention/api_i18n.go#L13-L22
- 来源: modules/bot_mention/api_i18n.go#L23-L32
- 来源: modules/bot_mention/api_i18n.go#L33-L40

#### 适用范围

适用于 docs/comment mention → Bot 事件桥、幂等重试、internal ingress 鉴权和错误状态解释。

#### 不确定边界

claim store 的 Redis key/TTL 与事件队列细节需要继续查 `modules/bot_mention/*claim*` 和 `modules/robot`。

### 知识点：Agent Mail Gateway 是用户+Space 认证后的受限代理，用短期 assertion 调上游 mail WebAPI

#### 结论

Agent Mail gateway 挂在 `/v1/mail-gateway/*path`，进入代理前必须通过普通用户认证、UID 限流和 SpaceMiddleware；proxy 要求 login uid 与 validated spaceID 均存在，gateway 配置有效，HTTP method 允许，path 必须落在 mail WebAPI 范围内。代理请求会用签名 assertion 作为上游 Bearer token，并重写 `X-Octo-Mailbox-ID`；响应强制 `Cache-Control: private, no-store`，并按 token、Space、mailbox 设置 `Vary`，避免私有邮件跨用户/Space 缓存复用。

#### 证据

- 来源: modules/agentmailgateway/gateway.go#L186-L195
- 来源: modules/agentmailgateway/gateway.go#L196-L205
- 来源: modules/agentmailgateway/gateway.go#L206-L215
- 来源: modules/agentmailgateway/gateway.go#L216-L225
- 来源: modules/agentmailgateway/gateway.go#L226-L228
- 来源: modules/agentmailgateway/gateway.go#L302-L311
- 来源: modules/agentmailgateway/gateway.go#L312-L321
- 来源: modules/agentmailgateway/gateway.go#L322-L331
- 来源: modules/agentmailgateway/gateway.go#L332-L341
- 来源: modules/agentmailgateway/gateway.go#L342-L351
- 来源: modules/agentmailgateway/gateway.go#L352-L352
- 来源: modules/agentmailgateway/gateway.go#L410-L419
- 来源: modules/agentmailgateway/gateway.go#L420-L429
- 来源: modules/agentmailgateway/gateway.go#L430-L439
- 来源: modules/agentmailgateway/gateway.go#L440-L449
- 来源: modules/agentmailgateway/gateway.go#L450-L457

#### 适用范围

适用于 Agent Mail 浏览器代理、为什么必须带 Space、为什么只代理 mail WebAPI、缓存安全边界。

#### 不确定边界

上游 octo-mail 的具体 API/错误体不是 `octo-server` 定义；这里只能确认本仓 gateway 边界。

### 知识点：Agent Mail Gateway 会按 uid + spaceID 做一次性/缓存化 provisioning

#### 结论

`ensureProvisioned` 以 `uid + "\x00" + spaceID` 为 key，命中 LRU cache 则跳过；miss 时用 singleflight 防并发重复 provisioning，并带超时调用 `provisionIdentity`。真实 provisioning 会构造包含 uid、space_id、email、display_name 的请求体，用 gateway secret 对请求签名，再以 Bearer assertion 调上游 provisioning API。

#### 证据

- 来源: modules/agentmailgateway/provisioning.go#L21-L30
- 来源: modules/agentmailgateway/provisioning.go#L31-L40
- 来源: modules/agentmailgateway/provisioning.go#L41-L50
- 来源: modules/agentmailgateway/provisioning.go#L51-L56
- 来源: modules/agentmailgateway/provisioning.go#L62-L71
- 来源: modules/agentmailgateway/provisioning.go#L72-L81
- 来源: modules/agentmailgateway/provisioning.go#L82-L91
- 来源: modules/agentmailgateway/provisioning.go#L92-L101
- 来源: modules/agentmailgateway/provisioning.go#L102-L111
- 来源: modules/agentmailgateway/provisioning.go#L112-L118

#### 适用范围

适用于解释首次打开 Agent Mail 为什么可能触发上游身份创建、为什么同一用户不同 Space 独立缓存。

#### 不确定边界

provisioning 上游是否创建 mailbox、返回什么实体由 octo-mail 决定，不属于本仓源码定义范围。
