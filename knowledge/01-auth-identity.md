# 01 — 认证与身份

## 知识点：HTTP 用户 token 由自定义 TokenParser 接入 wkhttp 认证链

### 结论

`octo-server` 启动 API 服务时创建 `CacheTokenParser` 并通过 `route.SetTokenParser(...)` 注入到 `wkhttp`；该 parser 使用 `pkg/auth.Decode` 解析 token cache value，并支持 v2 JSON envelope 与旧的 `uid@name[@role]` 格式。

### 证据

- 来源: main.go#L205-L214
- 来源: main.go#L215-L224
- 来源: main.go#L225-L227
- 来源: pkg/auth/parser.go#L59-L72

### 适用范围

适用于使用 `ctx.AuthMiddleware(r)` 的 HTTP API 登录态鉴权路径。

### 不确定边界

`AuthMiddleware` 的具体取 token 逻辑来自 `octo-lib`，本仓只看到 parser 注入点；如需确认 cookie 是否由 octo-lib 直接解析，需要补查 `Mininglamp-OSS/octo-lib`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：标准 `Authorization: Bearer` 会兼容回填到 legacy `token` 头

### 结论

`octo-server` 在全局中间件里挂载 `BearerTokenCompat()`，注释说明 octo-lib 的 `AuthMiddleware` 只认自定义 `token` 头，因此这里在所有 route group 的认证中间件之前，把标准 OAuth2 风格的 `Authorization: Bearer` 兼容回填。

### 证据

- 来源: main.go#L279-L288

### 适用范围

适用于外部 IdP 或标准 OAuth2 客户端用 Bearer 头访问需要登录态的 HTTP API。

### 不确定边界

是否支持 cookie 登录、cookie 到 token 的转换，本仓未在当前证据中确认；需继续查 `modules/user` 登录接口及 `octo-lib` 中间件。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：token 校验依赖 Redis 记录，并对 v3 token 强制有限 TTL、绝对过期和 session generation

### 结论

`TokenValidator.Validate` 从 token 前缀拼出的 Redis key 读取 payload 与 PTTL；v3 token 必须有有限 Redis TTL，且必须未超过 payload 中的绝对过期时间，还要校验当前 session generation 匹配。

### 证据

- 来源: pkg/auth/validator.go#L76-L85
- 来源: pkg/auth/validator.go#L86-L95
- 来源: pkg/auth/validator.go#L96-L105
- 来源: pkg/auth/validator.go#L106-L115
- 来源: pkg/auth/validator.go#L116-L123

### 适用范围

适用于用户 HTTP session token 的读取、过期、撤销和 rollout 后的 v3 session 校验。

### 不确定边界

token 的签发入口和用户登录接口需要继续在 `modules/user` 中逐接口补充。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：Bot API token 与用户 session token 是不同认证面

### 结论

`/v1/bot` 路由使用 `authBot()` 鉴权而不是用户 `AuthMiddleware`。Bot token 从 `Authorization: Bearer` 提取；`app_` 前缀走 App Bot 认证，其他 token 走 User Bot 认证。

### 证据

- 来源: modules/bot_api/auth.go#L25-L34
- 来源: modules/bot_api/auth.go#L35-L42
- 来源: modules/bot_api/auth.go#L143-L150
- 来源: modules/bot_api/bot_api.go#L400-L408

### 适用范围

适用于 Bot API 主路由 `/v1/bot/*` 以及 botfile 路由。

### 不确定边界

Bot token 的签发、刷新和 WuKongIM token 同步需继续结合 `modules/bot_api/register.go`、`modules/bot_provision/*`、`modules/botfather/*` 深挖。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：token payload 同时兼容 legacy、v2 JSON 与严格 v3 session envelope

#### 结论

用户登录态的 token cache value 不是只支持一种格式：`Decode` 先识别 v2 前缀，再识别 v3 前缀，最后兼容 legacy `uid@name[@role]`；v3 envelope 明确包含 `issued_at`、`expires_at`、`device_flag`、`device_id`、`session_generation`、`session_revision`，且 `EncodeV3` 要求 UID、签发时间、绝对过期、session generation 和 revision 都存在。

#### 证据

- 来源: pkg/auth/tokeninfo.go#L26-L37
- 来源: pkg/auth/tokeninfo.go#L53-L63
- 来源: pkg/auth/tokeninfo.go#L86-L95
- 来源: pkg/auth/tokeninfo.go#L96-L105
- 来源: pkg/auth/tokeninfo.go#L106-L115
- 来源: pkg/auth/tokeninfo.go#L116-L119
- 来源: pkg/auth/tokeninfo.go#L122-L131
- 来源: pkg/auth/tokeninfo.go#L132-L141
- 来源: pkg/auth/tokeninfo.go#L142-L151
- 来源: pkg/auth/tokeninfo.go#L152-L161
- 来源: pkg/auth/tokeninfo.go#L162-L171
- 来源: pkg/auth/tokeninfo.go#L172-L181
- 来源: pkg/auth/tokeninfo.go#L182-L188

#### 适用范围

适用于解释 HTTP 用户 session 在 Redis 中的 payload 形态、灰度兼容和 v3 session 的结构性校验。

#### 不确定边界

v3 rollout 当前生产写入模式需要结合运行时配置与 rollout state 判断；本条只说明源码中的编码/解码能力。

### 知识点：普通用户登录入口集中在 `/v1/user/*`，登录、注册、短信和 token verify 各自挂严格 IP 限流

#### 结论

`modules/user` 为登录、注册、短信、搜索和 token verify 分别创建严格 per-IP 限流器；公开登录/注册类入口挂在未认证 `/v1` group 下，已认证用户资料、当前用户、退出登录等入口挂 `AuthMiddleware`。`/v1/auth/verify`、`/v1/auth/verify-bot`、`/v1/auth/verify-api-key` 也在公开 group 中，但源码注释明确要求生产侧通过网络层限制或内部 key 加固。

#### 证据

- 来源: modules/user/api.go#L228-L237
- 来源: modules/user/api.go#L238-L244
- 来源: modules/user/api.go#L264-L273
- 来源: modules/user/api.go#L274-L283
- 来源: modules/user/api.go#L284-L287
- 来源: modules/user/api.go#L317-L326
- 来源: modules/user/api.go#L327-L336
- 来源: modules/user/api.go#L337-L346
- 来源: modules/user/api.go#L347-L356
- 来源: modules/user/api.go#L357-L359
- 来源: modules/user/api.go#L376-L385
- 来源: modules/user/api.go#L386-L395
- 来源: modules/user/api.go#L396-L405
- 来源: modules/user/api.go#L406-L409

#### 适用范围

适用于梳理用户侧 HTTP 认证入口、限流边界和内部 verify endpoint 的暴露风险。

#### 不确定边界

网络层是否已限制 verify endpoints 不在本仓源码内；需要补查部署配置、网关或 Ingress。

### 知识点：登录签发时 APP 单端会撤销旧 token，Web/PC 路径倾向复用旧 token

#### 结论

主登录签发路径会先取当前设备旧 token；APP 设备在签发新 session 前检查可写 fence，并在存在旧 token 时撤销当前 session；非 APP（注释为 Web/PC 多端）若旧 token 存在则复用并刷新旧 session，否则才签发新 token。写入 session 时，如果 session store 处于 v3 写模式则走 `IssueNewSession`，否则回落到 `auth.Encode` + `IssueNew` 的 v2/legacy 写法。

#### 证据

- 来源: modules/user/api.go#L1841-L1850
- 来源: modules/user/api.go#L1851-L1860
- 来源: modules/user/api.go#L1861-L1870
- 来源: modules/user/api.go#L1871-L1877
- 来源: modules/user/api.go#L1879-L1888
- 来源: modules/user/api.go#L1889-L1898
- 来源: modules/user/api.go#L1899-L1907
- 来源: modules/user/api.go#L2004-L2013
- 来源: modules/user/api.go#L2014-L2023
- 来源: modules/user/api.go#L2024-L2024
- 来源: pkg/auth/session_v3.go#L582-L591
- 来源: pkg/auth/session_v3.go#L592-L601
- 来源: pkg/auth/session_v3.go#L602-L611
- 来源: pkg/auth/session_v3.go#L612-L621
- 来源: pkg/auth/session_v3.go#L622-L626

#### 适用范围

适用于回答“重复登录是否踢旧 token”“APP 与 Web/PC 登录态是否一致”“v3 session 如何写入”等问题。

#### 不确定边界

`DeviceFlag` 具体枚举值来自 `octo-lib/config`，本仓只在调用处看到 APP/Web/PC 分支语义。

### 知识点：退出登录会先撤销当前 HTTP token，再退出 Web/PC 设备态

#### 结论

`/v1/user/quit` 读取当前登录 UID 和请求头中的 `token`，调用 session store 撤销当前 HTTP token；随后分别调用 `QuitUserDevice` 退出 Web 和 PC 设备。底层 `invalidateCurrentUserToken` 优先使用支持当前 token 失效的 store，否则直接删除 token key。

#### 证据

- 来源: modules/user/api.go#L449-L458
- 来源: modules/user/api.go#L459-L468
- 来源: modules/user/api.go#L2050-L2057

#### 适用范围

适用于回答用户主动退出后 HTTP token 与设备在线态的处理顺序。

#### 不确定边界

移动端 APP 设备态退出由其它路径处理，本条只覆盖 `quit` handler 当前源码行为。

### 知识点：管理端登录是独立入口，支持本地应急登录和可选邮箱 MFA，最终才签发 session token

#### 结论

管理端 `/v1/manager/login` 是未认证入口，源码注释说明它故意不受普通用户 `login.local_off` 影响，保留给 SuperAdmin 作为 SSO 故障时的本地应急通道。登录先校验账号状态、密码和 `IsManagerConsoleRole`；当管理端邮箱 MFA 打开时先创建 challenge 并返回 `mfa_required`，验证码原子消费、复核 challenge 与账号快照后才签发 token；MFA 关闭时则在最终 token 边界创建 session issue fence 并签发 token。

#### 证据

- 来源: modules/user/api_manager.go#L316-L325
- 来源: modules/user/api_manager.go#L326-L333
- 来源: modules/user/api_manager.go#L333-L342
- 来源: modules/user/api_manager.go#L343-L352
- 来源: modules/user/api_manager.go#L353-L362
- 来源: modules/user/api_manager.go#L363-L372
- 来源: modules/user/api_manager.go#L373-L382
- 来源: modules/user/api_manager.go#L383-L384
- 来源: modules/user/api_manager.go#L386-L395
- 来源: modules/user/api_manager.go#L396-L405
- 来源: modules/user/api_manager.go#L406-L415
- 来源: modules/user/api_manager.go#L416-L425
- 来源: modules/user/api_manager.go#L426-L427
- 来源: modules/user/api_manager.go#L430-L439
- 来源: modules/user/api_manager.go#L440-L449
- 来源: modules/user/api_manager.go#L450-L459
- 来源: modules/user/api_manager.go#L460-L469
- 来源: modules/user/api_manager.go#L470-L470
- 来源: modules/user/api_manager.go#L634-L643
- 来源: modules/user/api_manager.go#L644-L653
- 来源: modules/user/api_manager.go#L654-L663
- 来源: modules/user/api_manager.go#L664-L673
- 来源: modules/user/api_manager.go#L674-L683
- 来源: modules/user/api_manager.go#L684-L693
- 来源: modules/user/api_manager.go#L694-L703
- 来源: modules/user/api_manager.go#L704-L710

#### 适用范围

适用于区分普通用户登录、管理端登录、管理端 MFA 与 session token 签发时机。

#### 不确定边界

邮箱验证码发送、锁定策略的完整状态机需要继续补查 `manager_mfa` 相关文件。

### 知识点：`/v1/auth/verify` 只做 token 身份翻译，可按需附带空间与 owned bot 上下文

#### 结论

`authVerifyToken` 接收 body 中的 token，调用同一个 `TokenValidator` 验证；成功后返回 UID、Name、Role 和顶层 OwnedBots。当调用方带 `?include=context` 时，会额外查询用户活跃 Space 和按 Space 分组的 owned bots；查询失败时源码选择空集合而不是 500，并注明下游依赖这些字段的授权会 fail-closed。

#### 证据

- 来源: modules/user/api.go#L4740-L4749
- 来源: modules/user/api.go#L4750-L4759
- 来源: modules/user/api.go#L4760-L4763
- 来源: modules/user/api.go#L4765-L4774
- 来源: modules/user/api.go#L4775-L4784
- 来源: modules/user/api.go#L4785-L4794
- 来源: modules/user/api.go#L4795-L4803
- 来源: modules/user/api.go#L4803-L4816
- 来源: modules/user/api.go#L4819-L4828
- 来源: modules/user/api.go#L4829-L4838
- 来源: modules/user/api.go#L4839-L4848
- 来源: modules/user/api.go#L4849-L4857

#### 适用范围

适用于说明 Gateway / fleet / matter 等外部服务如何把 octo session token 翻译成身份与授权上下文。

#### 不确定边界

调用方如何消费 `owned_bots_by_space` 不在本仓 `modules/user` 内，需要到对应服务仓库核验。
