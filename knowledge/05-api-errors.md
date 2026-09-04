# 05 — API 与错误约定

## 知识点：错误码必须先注册，ID 命名受强约束，重复注册会 panic

### 结论

`pkg/i18n/codes.Register` 要求错误码 ID 非空、符合 `err.shared.*` 或 `err.server.*` 命名模式、DefaultMessage 非空、HTTPStatus 在 100-599 范围内；重复 ID 会在注册阶段 panic。

### 证据

- 来源: pkg/i18n/codes/registry.go#L28-L37
- 来源: pkg/i18n/codes/registry.go#L38-L43
- 来源: pkg/i18n/codes/registry.go#L74-L83
- 来源: pkg/i18n/codes/registry.go#L84-L93
- 来源: pkg/i18n/codes/registry.go#L94-L103
- 来源: pkg/i18n/codes/registry.go#L104-L104

### 适用范围

适用于解释错误码分类、启动期错误码校验、为什么不能随意新增未注册错误码。

### 不确定边界

所有业务错误码枚举需继续遍历 `pkg/errcode/*.go`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：错误响应通过 `httperr.ResponseErrorL` / `ResponseErrorLWithStatus` 渲染，兼容期默认 HTTP 400，可选择语义状态码

### 结论

`ResponseErrorL` 调用 `respondL(..., false)`，默认走 legacy 400 兼容；`ResponseErrorLWithStatus` 调用 `respondL(..., true)`，使用错误码注册的 canonical HTTPStatus。响应体中的 semantic status 仍取注册错误码的 HTTPStatus。

### 证据

- 来源: pkg/httperr/respond.go#L13-L22
- 来源: pkg/httperr/respond.go#L23-L31
- 来源: pkg/httperr/respond.go#L53-L62
- 来源: pkg/httperr/respond.go#L63-L72
- 来源: pkg/httperr/respond.go#L73-L81

### 适用范围

适用于 API 错误状态码、老客户端兼容、新接口 REST 语义状态解释。

### 不确定边界

具体每个 endpoint 使用哪种错误渲染方式，需要逐 handler 查 `ResponseErrorL*` 调用。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：错误 details 有白名单，Internal 错误避免泄露内部信息

### 结论

`Code.SafeDetailKeys` 用于限制 details 透传，`Internal=true` 的 5xx 类错误 renderer 应输出占位文案，避免内部 message 泄露给客户端。

### 证据

- 来源: pkg/i18n/codes/registry.go#L45-L54
- 来源: pkg/i18n/codes/registry.go#L55-L64
- 来源: pkg/i18n/codes/registry.go#L65-L67
- 来源: pkg/i18n/codes/shared.go#L96-L106
- 来源: pkg/httperr/respond.go#L73-L80

### 适用范围

适用于安全错误响应、i18n 错误文案和 sensitive detail 防泄漏。

### 不确定边界

renderer 具体输出格式在 `pkg/i18n`，需继续补充。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：错误码索引必须从源码 Code 块解析，不能用相邻行猜测 HTTPStatus

#### 结论

本轮复核发现旧版 `docs/source-audit/error-code-index.md` 中部分 HTTPStatus 与源码实际错位，原因是静态索引提取逻辑没有把 `ID` 与同一 `codes.Code{...}` 块内的 `HTTPStatus` 正确绑定。已按源码重新生成索引：当前错误码总数仍为 `461`，HTTPStatus 以同一 Code 块内字段为准。

#### 证据

- 来源: pkg/i18n/codes/registry.go#L74-L83
- 来源: pkg/i18n/codes/registry.go#L84-L93
- 来源: pkg/i18n/codes/registry.go#L94-L103
- 来源: pkg/i18n/codes/registry.go#L104-L104
- 来源: pkg/errcode/agent_mail_gateway.go#L9-L18
- 来源: pkg/errcode/agent_mail_gateway.go#L19-L28
- 来源: pkg/errcode/agent_mail_gateway.go#L29-L38
- 来源: pkg/errcode/agent_mail_gateway.go#L39-L42
- 来源: pkg/errcode/app_bot.go#L20-L29
- 来源: pkg/errcode/app_bot.go#L30-L39
- 来源: pkg/errcode/app_bot.go#L40-L49
- 来源: pkg/errcode/app_bot.go#L50-L59
- 来源: pkg/errcode/app_bot.go#L60-L69
- 来源: pkg/errcode/app_bot.go#L70-L79
- 来源: pkg/errcode/app_bot.go#L80-L89
- 来源: pkg/errcode/app_bot.go#L90-L99
- 来源: pkg/errcode/app_bot.go#L100-L100
- 来源: pkg/errcode/bot_api.go#L21-L30
- 来源: pkg/errcode/bot_api.go#L31-L40
- 来源: pkg/errcode/bot_api.go#L41-L50
- 来源: pkg/errcode/bot_api.go#L51-L60
- 来源: pkg/errcode/bot_api.go#L61-L68

#### 适用范围

适用于答辩或排障时引用错误码：应优先看 `pkg/errcode/*.go` 和 `pkg/i18n/codes/*.go`，索引只作为辅助，不能用错位表推断真实状态码。

#### 不确定边界

运行时某 endpoint 是否采用 canonical HTTPStatus，还取决于调用 `ResponseErrorL` 还是 `ResponseErrorLWithStatus`。

### 知识点：API 错误响应体是兼容信封，包含新字段 `error` 与旧字段 `msg/status`

#### 结论

`i18n.ErrorRenderer.Render` 输出统一 JSON：`error.code`、`error.message`、`error.details`、`error.http_status`，同时保留 legacy `msg` 和 `status` 字段。`Content-Language` 会写入响应头，并追加 `Vary: Accept-Language, X-Octo-Lang, Cookie`。

#### 证据

- 来源: pkg/i18n/renderer.go#L27-L36
- 来源: pkg/i18n/renderer.go#L37-L46
- 来源: pkg/i18n/renderer.go#L47-L56
- 来源: pkg/i18n/renderer.go#L57-L65
- 来源: main.go#L197-L205
- 来源: main.go#L253-L257

#### 适用范围

适用于客户端接入：新客户端应读 `error.code` / `error.http_status`；旧客户端仍可读 `msg/status`。

#### 不确定边界

仍使用 `c.ResponseError`、`c.JSON` 或第三方 upstream passthrough 的旧路径，不一定遵循该信封；需逐 endpoint 查调用点。

### 知识点：`ResponseErrorL` 与 `ResponseErrorLWithStatus` 的核心差异只在传输层 HTTP 状态码

#### 结论

`ResponseErrorL` 固定走 legacy transport status 400，但响应体里的 `error.http_status` 仍是错误码注册的 canonical HTTPStatus；`ResponseErrorLWithStatus` 则让 wire status 等于 canonical HTTPStatus。源码注释列出 OIDC bind、Bot bind/unbind、notification pause、bot_mention internal ingress 等新接口使用 WithStatus，其他兼容旧客户端的接口继续固定 400。

#### 证据

- 来源: pkg/httperr/respond.go#L13-L22
- 来源: pkg/httperr/respond.go#L23-L31
- 来源: pkg/httperr/respond.go#L49-L58
- 来源: pkg/httperr/respond.go#L59-L68
- 来源: pkg/httperr/respond.go#L69-L78
- 来源: pkg/httperr/respond.go#L79-L81
- 来源: modules/app_bot/api_i18n.go#L10-L17
- 来源: modules/bot_api/api_i18n.go#L13-L27

#### 适用范围

适用于解释“为什么 HTTP 400 但 body 里是 404/403/500”，以及新旧客户端兼容差异。

#### 不确定边界

全站切换到真实 HTTP status 的 Phase 4 未在当前源码中完成；不能承诺所有接口都会返回语义状态码。

### 知识点：错误码注册有命名、唯一性、默认文案和 HTTPStatus 强校验

#### 结论

`codes.Register` 要求 ID 非空、匹配 `err.shared.*` 或 `err.server.*`，DefaultMessage 非空，HTTPStatus 在 100–599；重复 ID 会 panic。`err.shared.*` 是跨模块通用错误，如认证、限流、参数、not_found、internal；业务模块错误放在 `pkg/errcode/*.go` 的 `err.server.<module>.*`。

#### 证据

- 来源: pkg/i18n/codes/registry.go#L28-L37
- 来源: pkg/i18n/codes/registry.go#L38-L43
- 来源: pkg/i18n/codes/registry.go#L74-L83
- 来源: pkg/i18n/codes/registry.go#L84-L93
- 来源: pkg/i18n/codes/registry.go#L94-L103
- 来源: pkg/i18n/codes/registry.go#L104-L104
- 来源: pkg/i18n/codes/shared.go#L5-L14
- 来源: pkg/i18n/codes/shared.go#L15-L20
- 来源: pkg/errcode/server.go#L118-L120

#### 适用范围

适用于新增错误码规范、review checklist、错误码冲突排查。

#### 不确定边界

`err.server.*` 的模块名不一定严格等于目录名，例如 `pkg/errcode/server.go` 内含 thread 错误码。

### 知识点：错误 details 是白名单透传，Internal 错误会清空 details 并隐藏业务文案

#### 结论

`Details.FilterBy` 只保留 `Code.SafeDetailKeys` 中列出的 key，其他 key 会被丢弃并记录 `i18n_unsafe_details_dropped_total{code,key}`。Renderer 再做一层安全网：Internal=true 时直接返回共享内部错误文案，并返回空 details，避免把 token、uid、SQL、raw_err 等敏感信息传给客户端。

#### 证据

- 来源: pkg/i18n/codes/registry.go#L45-L54
- 来源: pkg/i18n/codes/registry.go#L55-L64
- 来源: pkg/i18n/codes/registry.go#L65-L67
- 来源: pkg/i18n/details.go#L10-L23
- 来源: pkg/i18n/details.go#L25-L34
- 来源: pkg/i18n/details.go#L35-L44
- 来源: pkg/i18n/renderer.go#L68-L77
- 来源: pkg/i18n/renderer.go#L78-L87
- 来源: pkg/i18n/renderer.go#L88-L97
- 来源: pkg/i18n/renderer.go#L98-L98
- 来源: pkg/i18n/codes/shared.go#L96-L106

#### 适用范围

适用于安全审查、错误响应脱敏、为什么某些 details 没有出现在响应体。

#### 不确定边界

业务日志仍可能记录底层错误；对外响应不泄露不等于日志无需脱敏，需结合 accesslog / logger 审计。

### 知识点：语言协商链在请求早期完成，用户偏好在读侧延迟合并

#### 结论

API 错误文案走 i18n。默认语言来自 `OCTO_DEFAULT_LANGUAGE`，默认值是 `zh-CN`；运行时只支持 `en-US` 与 `zh-CN`。语言优先级为 trusted `X-Octo-Lang`、URL `lang`、cookie `i18n_lang`、user.language、`Accept-Language`、default。`EarlyMiddleware` 在 auth 前写入初始语言，`LanguageFromContext` 会在 auth 后按优先级读取 `UserInfo.Language` 并合并。

#### 证据

- 来源: pkg/i18n/config.go#L10-L19
- 来源: pkg/i18n/config.go#L20-L26
- 来源: pkg/i18n/config.go#L28-L37
- 来源: pkg/i18n/config.go#L38-L47
- 来源: pkg/i18n/config.go#L48-L57
- 来源: pkg/i18n/config.go#L58-L63
- 来源: pkg/i18n/lang.go#L12-L21
- 来源: pkg/i18n/lang.go#L22-L31
- 来源: pkg/i18n/lang.go#L32-L32
- 来源: pkg/i18n/lang.go#L50-L59
- 来源: pkg/i18n/lang.go#L60-L69
- 来源: pkg/i18n/lang.go#L70-L79
- 来源: pkg/i18n/lang.go#L80-L83
- 来源: pkg/i18n/ctx.go#L36-L45
- 来源: pkg/i18n/ctx.go#L46-L55
- 来源: pkg/i18n/ctx.go#L56-L65
- 来源: pkg/i18n/middleware.go#L16-L25
- 来源: pkg/i18n/middleware.go#L26-L35
- 来源: main.go#L197-L205
- 来源: main.go#L231-L240
- 来源: main.go#L241-L250
- 来源: main.go#L251-L257

#### 适用范围

适用于错误文案国际化、为何同一错误码在不同请求语言下显示不同文案。

#### 不确定边界

翻译文件覆盖内容需查 `pkg/i18n/locales/active.*.toml`，本条只说明协商与渲染机制。

### 知识点：shared 错误码覆盖认证、限流、参数、not_found、internal 五类基础错误

#### 结论

基础错误码在 `pkg/i18n/codes/shared.go` 注册：`err.shared.auth.required`、`token_missing`、`token_invalid`、`token_expired`、`forbidden`、`rate.limited`、`param.invalid`、`not_found`、`internal`。其中 `rate.limited` 允许透传 `retry_after`，`param.invalid` 允许透传 `field`，`internal` 标记 Internal=true。

#### 证据

- 来源: pkg/i18n/codes/shared.go#L21-L30
- 来源: pkg/i18n/codes/shared.go#L31-L40
- 来源: pkg/i18n/codes/shared.go#L41-L50
- 来源: pkg/i18n/codes/shared.go#L51-L60
- 来源: pkg/i18n/codes/shared.go#L61-L70
- 来源: pkg/i18n/codes/shared.go#L71-L75
- 来源: pkg/i18n/codes/shared.go#L77-L86
- 来源: pkg/i18n/codes/shared.go#L87-L96
- 来源: pkg/i18n/codes/shared.go#L97-L106

#### 适用范围

适用于各模块共用错误码归类和客户端通用分支。

#### 不确定边界

具体模块可能定义业务专属的 401/403/404/409/429，而不是复用 shared code，需要查 `pkg/errcode/<module>.go`。

### 知识点：用户、群、空间等核心业务错误码按“参数/权限/不存在/冲突/内部”分层

#### 结论

`pkg/errcode/user.go`、`group.go`、`space.go` 等按错误类型分区注册：参数类通常是 400，权限/成员身份类通常是 403，不存在类通常是 404，状态冲突类通常是 409，内部读写/IM/第三方失败为 500/502 且多为 Internal=true。部分安全场景采用反枚举策略，例如 user API key 错误、Space 邀请码错误、OIDC 绑定凭据错误都把多个内部原因折叠成单一对外错误。

#### 证据

- 来源: pkg/errcode/user.go#L21-L30
- 来源: pkg/errcode/user.go#L31-L40
- 来源: pkg/errcode/user.go#L41-L50
- 来源: pkg/errcode/user.go#L51-L60
- 来源: pkg/errcode/user.go#L61-L70
- 来源: pkg/errcode/user.go#L71-L80
- 来源: pkg/errcode/user.go#L81-L90
- 来源: pkg/errcode/user.go#L91-L92
- 来源: pkg/errcode/user.go#L94-L103
- 来源: pkg/errcode/user.go#L104-L113
- 来源: pkg/errcode/user.go#L114-L123
- 来源: pkg/errcode/user.go#L124-L133
- 来源: pkg/errcode/user.go#L134-L143
- 来源: pkg/errcode/user.go#L144-L153
- 来源: pkg/errcode/user.go#L154-L156
- 来源: pkg/errcode/user.go#L206-L215
- 来源: pkg/errcode/user.go#L216-L225
- 来源: pkg/errcode/user.go#L226-L235
- 来源: pkg/errcode/user.go#L236-L245
- 来源: pkg/errcode/user.go#L246-L255
- 来源: pkg/errcode/user.go#L256-L265
- 来源: pkg/errcode/user.go#L266-L275
- 来源: pkg/errcode/user.go#L276-L285
- 来源: pkg/errcode/user.go#L286-L295
- 来源: pkg/errcode/user.go#L296-L305
- 来源: pkg/errcode/user.go#L306-L309
- 来源: pkg/errcode/group.go#L15-L24
- 来源: pkg/errcode/group.go#L25-L34
- 来源: pkg/errcode/group.go#L35-L44
- 来源: pkg/errcode/group.go#L45-L54
- 来源: pkg/errcode/group.go#L55-L63
- 来源: pkg/errcode/group.go#L64-L73
- 来源: pkg/errcode/group.go#L74-L83
- 来源: pkg/errcode/group.go#L84-L93
- 来源: pkg/errcode/group.go#L94-L103
- 来源: pkg/errcode/group.go#L104-L113
- 来源: pkg/errcode/group.go#L114-L123
- 来源: pkg/errcode/group.go#L124-L133
- 来源: pkg/errcode/group.go#L134-L143
- 来源: pkg/errcode/group.go#L144-L153
- 来源: pkg/errcode/group.go#L154-L163
- 来源: pkg/errcode/group.go#L164-L173
- 来源: pkg/errcode/group.go#L174-L183
- 来源: pkg/errcode/group.go#L185-L194
- 来源: pkg/errcode/group.go#L195-L204
- 来源: pkg/errcode/group.go#L205-L214
- 来源: pkg/errcode/group.go#L215-L224
- 来源: pkg/errcode/group.go#L225-L234
- 来源: pkg/errcode/group.go#L235-L244
- 来源: pkg/errcode/group.go#L245-L247
- 来源: pkg/errcode/space.go#L15-L24
- 来源: pkg/errcode/space.go#L25-L34
- 来源: pkg/errcode/space.go#L35-L44
- 来源: pkg/errcode/space.go#L45-L54
- 来源: pkg/errcode/space.go#L55-L64
- 来源: pkg/errcode/space.go#L65-L74
- 来源: pkg/errcode/space.go#L75-L84
- 来源: pkg/errcode/space.go#L85-L94
- 来源: pkg/errcode/space.go#L95-L104
- 来源: pkg/errcode/space.go#L105-L107
- 来源: pkg/errcode/space.go#L109-L118
- 来源: pkg/errcode/space.go#L119-L128
- 来源: pkg/errcode/space.go#L129-L138
- 来源: pkg/errcode/space.go#L139-L148
- 来源: pkg/errcode/space.go#L149-L158
- 来源: pkg/errcode/space.go#L159-L168
- 来源: pkg/errcode/space.go#L169-L178
- 来源: pkg/errcode/space.go#L179-L188
- 来源: pkg/errcode/space.go#L189-L198
- 来源: pkg/errcode/space.go#L199-L207

#### 适用范围

适用于归档用户反馈时判断是参数错误、权限错误、资源不存在、状态冲突还是服务端故障。

#### 不确定边界

某个 handler 是否已完成 i18n 迁移，需要查具体 `api_i18n.go` 和 handler 调用；不能只看错误码已注册。

### 知识点：Bot API 错误面保留真实 401/403/404/409/413/502，且 bot 认证采用单一码反枚举

#### 结论

`pkg/errcode/bot_api.go` 注释明确：Bot API 面向外部 adapters/integrations，许多调用方按真实 HTTP status 分支，因此迁移后通过 `ResponseErrorLWithStatus` 保留真实状态码。`ErrBotAPIAuthFailed` 是 bot-token auth middleware 与 legacy register endpoint 的单一反枚举 401：缺 Authorization、token 无效/未知、未鉴权 OBO 等都折叠到同一码；基础设施失败另用 `ErrBotAPIAuthCheckFailed` 500。

#### 证据

- 来源: pkg/errcode/bot_api.go#L9-L20
- 来源: pkg/errcode/bot_api.go#L278-L290
- 来源: pkg/errcode/bot_api.go#L347-L357
- 来源: modules/bot_api/api_i18n.go#L87-L96
- 来源: modules/bot_api/api_i18n.go#L97-L106
- 来源: modules/bot_api/api_i18n.go#L107-L113
- 来源: modules/bot_api/bot_api.go#L298-L307
- 来源: modules/bot_api/bot_api.go#L308-L317
- 来源: modules/bot_api/bot_api.go#L318-L327
- 来源: modules/bot_api/bot_api.go#L328-L337
- 来源: modules/bot_api/bot_api.go#L338-L339
- 来源: modules/bot_api/bot_api.go#L400-L409
- 来源: modules/bot_api/bot_api.go#L410-L419
- 来源: modules/bot_api/bot_api.go#L420-L429
- 来源: modules/bot_api/bot_api.go#L430-L439
- 来源: modules/bot_api/bot_api.go#L440-L449
- 来源: modules/bot_api/bot_api.go#L450-L459
- 来源: modules/bot_api/bot_api.go#L460-L467

#### 适用范围

适用于外部 Bot 适配器接入、401/500 可重试性判断、OBO 与 bot token 鉴权失败说明。

#### 不确定边界

Bot API 中仍有 legacy wire-400 业务拒绝路径，需按具体调用 `ResponseErrorL` / `ResponseErrorLWithStatus` 判断。

### 知识点：Bot API 限流错误统一使用 shared 429，并带标准限流响应头

#### 结论

Bot API per-bot 限流层使用三类通道：business、heartbeat、register。限流结果为 Denied 时设置 `X-RateLimit-Limit`、`X-RateLimit-Remaining`、`X-RateLimit-Scope`，并在拒绝时设置 `Retry-After`；响应复用 `err.shared.rate.limited`，通过 `ResponseErrorLWithStatus` 返回真实 429，并在 details 中透传 `retry_after`。Dry-run 与 bypass 不下发限流头。

#### 证据

- 来源: modules/bot_api/ratelimit.go#L21-L30
- 来源: modules/bot_api/ratelimit.go#L31-L40
- 来源: modules/bot_api/ratelimit.go#L41-L48
- 来源: modules/bot_api/ratelimit.go#L49-L58
- 来源: modules/bot_api/ratelimit.go#L59-L68
- 来源: modules/bot_api/ratelimit.go#L69-L70
- 来源: pkg/ratelimit/limiter.go#L60-L69
- 来源: pkg/ratelimit/limiter.go#L70-L79
- 来源: pkg/ratelimit/limiter.go#L80-L89
- 来源: pkg/ratelimit/limiter.go#L90-L99
- 来源: pkg/ratelimit/limiter.go#L100-L109
- 来源: pkg/ratelimit/limiter.go#L110-L119
- 来源: pkg/ratelimit/limiter.go#L120-L120
- 来源: modules/bot_api/ratelimit.go#L390-L399
- 来源: modules/bot_api/ratelimit.go#L400-L409
- 来源: modules/bot_api/ratelimit.go#L410-L419
- 来源: modules/bot_api/ratelimit.go#L420-L429
- 来源: modules/bot_api/ratelimit.go#L430-L439
- 来源: modules/bot_api/ratelimit.go#L440-L448
- 来源: pkg/i18n/codes/shared.go#L67-L75

#### 适用范围

适用于解释 429、Retry-After、X-RateLimit-*、dry-run 观测期为什么客户端看不到限流头。

#### 不确定边界

全局 per-IP 与 UID 限流实现主要在 octo-lib，本仓只包装/调用部分 helper；要完全证明其响应体需补查 octo-lib。

### 知识点：`/v1/bot/register` 与 `/v1/bot/heartbeat` 被移出全局 per-IP 桶，但有自己的底线限流

#### 结论

`main.go` 明确把 `/v1/bot/heartbeat` 和 `/v1/bot/register` 加入全局限流豁免列表，原因是它们是 Bot 掉线自愈通道，不能被同 IP 其它 bot 的业务流量饿死。但源码同时要求豁免不等于无限制：register 使用鉴权前 per-IP strict bucket，再 per-token 指纹限流；heartbeat 使用鉴权前 per-IP strict bucket，再 authBot/identity，再 per-bot heartbeat 限流。

#### 证据

- 来源: main.go#L69-L78
- 来源: main.go#L79-L88
- 来源: main.go#L89-L96
- 来源: modules/bot_api/bot_api.go#L298-L307
- 来源: modules/bot_api/bot_api.go#L308-L317
- 来源: modules/bot_api/bot_api.go#L318-L327
- 来源: modules/bot_api/bot_api.go#L328-L337
- 来源: modules/bot_api/bot_api.go#L338-L339
- 来源: modules/bot_api/bot_api.go#L341-L350
- 来源: modules/bot_api/bot_api.go#L351-L360
- 来源: modules/bot_api/bot_api.go#L361-L370
- 来源: modules/bot_api/bot_api.go#L371-L375
- 来源: modules/bot_api/ratelimit.go#L72-L81
- 来源: modules/bot_api/ratelimit.go#L82-L91
- 来源: modules/bot_api/ratelimit.go#L92-L101
- 来源: modules/bot_api/ratelimit.go#L102-L111
- 来源: modules/bot_api/ratelimit.go#L112-L121
- 来源: modules/bot_api/ratelimit.go#L122-L131
- 来源: modules/bot_api/ratelimit.go#L132-L141
- 来源: modules/bot_api/ratelimit.go#L142-L147
- 来源: modules/bot_api/ratelimit.go#L167-L174

#### 适用范围

适用于解释 Bot 断联自愈、429 来源、为什么 register/heartbeat 看似不走全局限流但仍有防护。

#### 不确定边界

扩展 HTTP 方法与 CORS OPTIONS 的残留行为在源码注释中说明仍由更上游能力决定，本仓本轮未改动。

### 知识点：内部 API 错误倾向使用真实状态码和反枚举形状

#### 结论

`internal_resolve` 的 `/v1/internal/user/resolve-bot-owner` 要求先过 per-endpoint IP strict limit，再用 `X-Internal-Token` 常量时间比较；token 失败返回 shared token_invalid 401，body/uid 失败返回 shared param.invalid 400，查询失败或 botidentity 歧义返回 shared internal 500。未知 uid 不返回 404，而是成功返回 `robot=0`，避免向低权限内部调用方泄露用户存在性。

#### 证据

- 来源: modules/internal_resolve/api.go#L122-L131
- 来源: modules/internal_resolve/api.go#L132-L141
- 来源: modules/internal_resolve/api.go#L142-L151
- 来源: modules/internal_resolve/api.go#L152-L157
- 来源: modules/internal_resolve/api.go#L159-L172
- 来源: modules/internal_resolve/api.go#L196-L205
- 来源: modules/internal_resolve/api.go#L206-L215
- 来源: modules/internal_resolve/api.go#L215-L224
- 来源: modules/internal_resolve/api.go#L225-L234
- 来源: modules/internal_resolve/api.go#L235-L244
- 来源: modules/internal_resolve/api.go#L245-L254
- 来源: modules/internal_resolve/api.go#L255-L260
- 来源: modules/internal_resolve/api_i18n.go#L10-L19
- 来源: modules/internal_resolve/api_i18n.go#L20-L29
- 来源: modules/internal_resolve/api_i18n.go#L30-L36

#### 适用范围

适用于内部服务鉴权、drive resolve-bot-owner 调用、存在性泄露风险判断。

#### 不确定边界

`X-Internal-Token` 的配置校验与 token 碰撞排查见 `03-configs.md`，不在本条重复展开。

### 知识点：Bot mention internal ingress 用状态码区分幂等、冲突、禁用和重放

#### 结论

`/v1/internal/bot-mentions` 通过 `X-Internal-Token` 鉴权；无效 token 返回 shared token_invalid 401，非法请求返回 shared param.invalid 400，bot 不存在返回 shared not_found 404，幂等处理中返回 bot_mention 专属 409，存储/队列失败返回 Internal=true 的 500。功能 gate 禁用不是错误信封，而是 200 业务响应 `{accepted:false, reason:"disabled"}`；幂等 replay 成功也返回 200 并带 `replay:true`。

#### 证据

- 来源: modules/bot_mention/api.go#L70-L79
- 来源: modules/bot_mention/api.go#L80-L89
- 来源: modules/bot_mention/api.go#L91-L100
- 来源: modules/bot_mention/api.go#L101-L110
- 来源: modules/bot_mention/api.go#L111-L120
- 来源: modules/bot_mention/api.go#L121-L130
- 来源: modules/bot_mention/api.go#L131-L140
- 来源: modules/bot_mention/api.go#L141-L145
- 来源: modules/bot_mention/api.go#L148-L157
- 来源: modules/bot_mention/api.go#L158-L167
- 来源: modules/bot_mention/api.go#L168-L177
- 来源: modules/bot_mention/api.go#L178-L180
- 来源: modules/bot_mention/api_i18n.go#L13-L22
- 来源: modules/bot_mention/api_i18n.go#L23-L32
- 来源: modules/bot_mention/api_i18n.go#L33-L40
- 来源: pkg/errcode/bot_mention.go#L9-L18
- 来源: pkg/errcode/bot_mention.go#L19-L25

#### 适用范围

适用于 docs comment mention → Bot 事件桥接排障，以及区分真正错误和 feature gate disabled。

#### 不确定边界

`respondBotMentionClaimOutcome` 的完整状态机与 Redis claim 细节需在 Bot/事件专题继续补充。

### 知识点：Agent Mail gateway 强制本地错误走 i18n envelope，但 upstream 响应可透明透传

#### 结论

`agentmailgateway` 本地错误统一走 `respondGatewayError`，即 `ResponseErrorLWithStatus`；对应测试禁止在 `gateway.go` 中使用 legacy `ResponseError`、`ResponseErrorf`、`AbortWithStatusJSON`、`AbortWithStatus` 或 `c.JSON` 生成本地错误。但测试注释也说明透明代理路径会保留 upstream status/body。

#### 证据

- 来源: modules/agentmailgateway/api_i18n.go#L1-L10
- 来源: modules/agentmailgateway/api_i18n_test.go#L9-L18
- 来源: modules/agentmailgateway/api_i18n_test.go#L19-L28
- 来源: modules/agentmailgateway/api_i18n_test.go#L29-L37
- 来源: pkg/errcode/agent_mail_gateway.go#L9-L18
- 来源: pkg/errcode/agent_mail_gateway.go#L19-L28
- 来源: pkg/errcode/agent_mail_gateway.go#L29-L38
- 来源: pkg/errcode/agent_mail_gateway.go#L39-L42

#### 适用范围

适用于区分 gateway 本地错误与上游业务错误透传，不应把 upstream body 误判为 octo-server 错误信封缺失。

#### 不确定边界

Agent Mail upstream 的错误码/响应体不属于 `octo-server` 源码定义范围。
