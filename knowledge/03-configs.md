# 03 — 配置

## 知识点：默认配置文件路径是 `configs/tsdd.yaml`，并支持 `TS_` 环境变量覆盖

### 结论

启动时通过 `-config` 参数指定配置文件，默认值是 `configs/tsdd.yaml`；随后设置 viper 环境变量前缀 `TS`，并把配置路径中的 `.` 替换为 `_` 后自动读环境变量。

### 证据

- 来源: main.go#L138-L145

### 适用范围

适用于部署时配置文件与环境变量覆盖策略说明。

### 不确定边界

每个字段具体绑定到哪个 config struct 需继续查 `octo-lib/config`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：配置文件包含 WuKongIM、MySQL、Redis、外网 URL、日志等核心段

### 结论

`configs/tsdd.yaml` 明确列出 `wukongIM`、`db.mysqlAddr`、`db.redisAddr/redisPass/redisTLS`、`external.baseURL/webLoginURL`、`logger` 等配置段。

### 证据

- 来源: configs/tsdd.yaml#L21-L30
- 来源: configs/tsdd.yaml#L31-L40
- 来源: configs/tsdd.yaml#L41-L50

### 适用范围

适用于基础部署、IM 控制面连接、外部访问地址、日志配置说明。

### 不确定边界

哪些字段在启动期强校验，需结合 `config.ConfigureWithViper` 和各模块初始化继续补证据。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：release 模式禁止配置测试短信验证码后门

### 结论

主程序在初始化 config 后调用 `ValidateTestCodeConfig`，注释明确说明 release 模式下禁止配置 `smsCode` 万能验证码后门。

### 证据

- 来源: main.go#L152-L160
- 来源: configs/tsdd.yaml#L52-L61
- 来源: configs/tsdd.yaml#L62-L67

### 适用范围

适用于登录/注册验证码、安全配置检查。

### 不确定边界

`ValidateTestCodeConfig` 的具体判断逻辑需继续查 `modules/base/common`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：文件服务支持 MinIO、Tencent COS、Aliyun OSS、Qiniu、SeaweedFS，但预签名能力不同

### 结论

配置注释给出了浏览器直传预签名能力矩阵：MinIO/Tencent COS/Aliyun OSS 支持 presigned PUT/GET；Qiniu 不支持 presigned PUT 但支持 signed GET；SeaweedFS 两者都不支持。

### 证据

- 来源: configs/tsdd.yaml#L69-L78
- 来源: configs/tsdd.yaml#L79-L88
- 来源: configs/tsdd.yaml#L89-L98
- 来源: configs/tsdd.yaml#L99-L103

### 适用范围

适用于文件上传、浏览器直传、对象存储选型和部署排障。

### 不确定边界

各后端实现细节需继续查 `modules/file/service_*.go`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：`configs/tsdd.yaml` 是基础样例配置，但并非全部运行时配置都来自 YAML

#### 结论

主进程默认读取 `configs/tsdd.yaml`，再用 `TS_` 前缀环境变量覆盖 YAML 字段；但源码中仍有大量功能直接读环境变量，例如 OIDC、消息搜索、子区归档 worker、内部服务 token、语音适配器和运营分析等。因此排查配置时不能只看 `tsdd.yaml`，还要按模块查 `os.Getenv`/`LookupEnv`。

#### 证据

- 来源: main.go#L138-L147
- 来源: main.go#L148-L155
- 来源: modules/oidc/config.go#L129-L138
- 来源: modules/oidc/config.go#L139-L148
- 来源: modules/oidc/config.go#L149-L153
- 来源: modules/messages_search/config.go#L104-L113
- 来源: modules/messages_search/config.go#L114-L123
- 来源: modules/messages_search/config.go#L124-L132
- 来源: modules/thread/archive_config.go#L24-L33
- 来源: modules/thread/archive_config.go#L34-L43
- 来源: modules/thread/archive_config.go#L44-L51
- 来源: modules/internal_resolve/config.go#L23-L32
- 来源: modules/internal_resolve/config.go#L33-L42
- 来源: modules/internal_resolve/config.go#L43-L52
- 来源: modules/internal_resolve/config.go#L53-L62
- 来源: modules/internal_resolve/config.go#L63-L72
- 来源: modules/internal_resolve/config.go#L73-L82
- 来源: modules/internal_resolve/config.go#L83-L83
- 来源: modules/voice_adapter/config.go#L9-L18
- 来源: modules/voice_adapter/config.go#L19-L28
- 来源: modules/voice_adapter/config.go#L29-L38
- 来源: modules/voice_adapter/config.go#L39-L48
- 来源: modules/voice_adapter/config.go#L49-L53
- 来源: modules/opanalytics/config.go#L13-L22
- 来源: modules/opanalytics/config.go#L23-L32
- 来源: modules/opanalytics/config.go#L33-L37

#### 适用范围

适用于解释“为什么配置文件里找不到某开关/某密钥”“环境变量和 YAML 谁生效”。

#### 不确定边界

`octo-lib/config` 中内建 struct 字段与默认值不在本仓，需要补查 `Mininglamp-OSS/octo-lib` 才能列出所有 YAML 字段的最终默认值。

### 知识点：`TS_` 环境变量覆盖的是 Viper 配置路径，点号会变成下划线

#### 结论

启动时 `vp.SetEnvPrefix("TS")`，并把配置 key 中的 `.` 替换为 `_` 后启用 `AutomaticEnv()`。因此 YAML 中 `cache.tokenExpire` 这类路径理论上对应 `TS_CACHE_TOKENEXPIRE` / 具体 Viper key 形态，而不是模块里直接读取的 `DM_*` / `OCTO_*` 环境变量；两类配置通道需要分开理解。

#### 证据

- 来源: main.go#L138-L145
- 来源: main.go#L152-L155

#### 适用范围

适用于部署时区分“Viper/YAML 配置覆盖”和“模块自读环境变量”。

#### 不确定边界

Viper key 的精确命名取决于 `octo-lib/config.ConfigureWithViper` 绑定方式；本仓未包含该实现。

### 知识点：access token TTL 在启动期单独校验，最终写回 `cfg.Cache.TokenExpire`

#### 结论

主程序先调用 `validateTokenExpireConfig(vp)`，校验通过后才构造 `config.Config` 并把结果写回 `cfg.Cache.TokenExpire`。session runtime 创建 Redis session store 时使用 `ctx.GetConfig().Cache.TokenExpire` 作为最大 TTL，启动日志也会打印 `token_ttl`。

#### 证据

- 来源: main.go#L145-L156
- 来源: pkg/auth/runtime.go#L83-L88
- 来源: main.go#L1009-L1014

#### 适用范围

适用于解释 token 过期配置如何进入 session store，以及为什么 token TTL 不是只靠 Redis 默认值。

#### 不确定边界

`validateTokenExpireConfig` 调用的是 `tokenlifecycle.ValidateTokenExpire`，具体允许范围需继续查 `internal/tokenlifecycle`。

### 知识点：HTTP session rollout 主要由 MySQL authority 驱动，环境变量只保留灰度/兼容控制

#### 结论

session runtime 初始会把签发 fence 住，等模块 migration 后调用 `InitializeSessionRollout`；源码注释说明 MySQL singleton 存在后每次启动都读 MySQL，Redis floor 和旧 `OCTO_AUTH_SESSION_MODE` 只在 takeover/过渡场景使用。当前仍读的环境变量包括 `OCTO_AUTH_SESSION_CANARY_AHEAD`、`OCTO_AUTH_SESSION_EXPECT_WRITERS`、`OCTO_AUTH_SESSION_AUTO_ADVANCE`，而 `OCTO_AUTH_SESSION_MODE` 和 `OCTO_AUTH_SESSION_MAX_PER_UID` 已标为 deprecated。

#### 证据

- 来源: pkg/auth/runtime.go#L46-L55
- 来源: pkg/auth/runtime.go#L56-L65
- 来源: pkg/auth/runtime.go#L66-L75
- 来源: pkg/auth/runtime.go#L89-L101
- 来源: pkg/auth/runtime.go#L133-L142
- 来源: pkg/auth/runtime.go#L143-L152
- 来源: pkg/auth/runtime.go#L153-L162
- 来源: pkg/auth/runtime.go#L163-L172
- 来源: pkg/auth/runtime.go#L173-L181
- 来源: pkg/auth/session_policy.go#L10-L19
- 来源: pkg/auth/session_policy.go#L20-L29
- 来源: pkg/auth/session_policy.go#L30-L39
- 来源: pkg/auth/session_policy.go#L40-L40
- 来源: pkg/auth/session_policy.go#L66-L75
- 来源: pkg/auth/session_policy.go#L76-L85
- 来源: pkg/auth/session_policy.go#L86-L95
- 来源: pkg/auth/session_policy.go#L96-L105
- 来源: pkg/auth/session_policy.go#L106-L115
- 来源: pkg/auth/session_policy.go#L116-L122

#### 适用范围

适用于解释 session v3 灰度、canary、自动推进和旧环境变量兼容行为。

#### 不确定边界

当前线上 floor、max_per_uid、pause 状态存于运行时 MySQL，不在源码中；需查实际数据库或 rollout 命令输出。

### 知识点：release 模式下 `smsCode` 万能验证码会导致启动失败

#### 结论

`configs/tsdd.yaml` 示例中保留了 `smsCode: "123456"`，但源码明确：测试验证码只在非 release 模式且 SMSCode 非空时启用；启动期 `ValidateTestCodeConfig` 会在 release 模式且 SMSCode 非空时报错，防止万能验证码后门进入生产。

#### 证据

- 来源: configs/tsdd.yaml#L52-L61
- 来源: configs/tsdd.yaml#L62-L67
- 来源: main.go#L152-L160
- 来源: modules/base/common/testcode.go#L10-L24
- 来源: modules/base/common/testcode.go#L41-L49

#### 适用范围

适用于生产部署安全检查、登录/注册验证码排障。

#### 不确定边界

实际部署是否设置 `mode: release` 与是否覆盖 `smsCode`，需要查看运行环境配置。

### 知识点：OIDC 配置不走 `tsdd.yaml`，而是直接读取 `DM_OIDC_*` / `OCTO_OIDC_*` 环境变量

#### 结论

OIDC 模块注释说明当前 `octo-lib` 暂不支持 OIDC 配置块，因此 `LoadConfig` 直接从环境变量加载。`DM_OIDC_ENABLED=false` 时不校验 provider 字段；启用后要求 issuer、client_id、client_secret、redirect_uri 和 `DM_OIDC_RT_ENC_KEY` 等关键项，且 `DM_OIDC_RT_ENC_KEY` 必须 base64 解码后正好 32 字节。

#### 证据

- 来源: modules/oidc/config.go#L129-L138
- 来源: modules/oidc/config.go#L139-L148
- 来源: modules/oidc/config.go#L149-L153
- 来源: modules/oidc/config.go#L155-L164
- 来源: modules/oidc/config.go#L165-L174
- 来源: modules/oidc/config.go#L175-L184
- 来源: modules/oidc/config.go#L185-L194
- 来源: modules/oidc/config.go#L195-L204
- 来源: modules/oidc/config.go#L205-L214
- 来源: modules/oidc/config.go#L215-L224
- 来源: modules/oidc/config.go#L225-L230
- 来源: modules/oidc/config.go#L252-L264

#### 适用范围

适用于 SSO/OIDC 接入、启动失败排查、refresh token 加密密钥检查。

#### 不确定边界

OIDC provider 的上游可用性、Discovery 返回内容和真实回调地址需要运行时联调确认。

### 知识点：OIDC provider kind 有启动期拒绝规则，避免配置“看似可用但实际锁死登录”

#### 结论

`pkg/oidcboot` 把 OIDC 启动拒绝规则抽为 leaf package，供 `modules/oidc.LoadConfig` 和 `modules/common.isOIDCFullyConfigured` 共用，目的是避免两边判断漂移导致 OIDC endpoint 404 但 `login.local_off` 仍生效，从而让 SSO-only 部署无可用登录入口。规则包括 provider kind、OAuth2 base URL、AppID、issuer 长度和 logout URL 形态等。

#### 证据

- 来源: pkg/oidcboot/rules.go#L1-L10
- 来源: pkg/oidcboot/rules.go#L11-L20
- 来源: pkg/oidcboot/rules.go#L21-L30
- 来源: pkg/oidcboot/rules.go#L31-L33
- 来源: pkg/oidcboot/rules.go#L45-L54
- 来源: pkg/oidcboot/rules.go#L55-L64
- 来源: pkg/oidcboot/rules.go#L65-L74
- 来源: pkg/oidcboot/rules.go#L75-L84
- 来源: pkg/oidcboot/rules.go#L85-L89
- 来源: pkg/oidcboot/rules.go#L251-L260
- 来源: pkg/oidcboot/rules.go#L261-L270
- 来源: pkg/oidcboot/rules.go#L271-L279
- 来源: pkg/oidcboot/rules.go#L281-L290
- 来源: pkg/oidcboot/rules.go#L291-L300
- 来源: pkg/oidcboot/rules.go#L301-L310
- 来源: pkg/oidcboot/rules.go#L311-L316
- 来源: modules/oidc/config.go#L272-L281
- 来源: modules/oidc/config.go#L282-L291
- 来源: modules/oidc/config.go#L292-L301
- 来源: modules/oidc/config.go#L302-L311
- 来源: modules/oidc/config.go#L312-L321
- 来源: modules/oidc/config.go#L322-L331
- 来源: modules/oidc/config.go#L332-L335

#### 适用范围

适用于排查 SSO-only 登录锁死、provider kind 配错、OAuth2/OIDC 配置混用。

#### 不确定边界

`isOIDCFullyConfigured` 的完整镜像逻辑较长，本轮只引用其共享规则来源；后续可在鉴权/登录专题继续补足。

### 知识点：`system_setting` 是可热更新的运行时配置层，DB 空值回落到 YAML 或代码默认

#### 结论

`SystemSettings` 是进程级共享实例；启动首次加载失败不阻断进程，后台每 60 秒自动 reload。其 lookup 模型是 immutable snapshot，DB 空值表示“未配置”并回落到 YAML 字段或代码默认；加密值在 snapshot 构建时解密，读路径直接读缓存。`systemSettingSchema` 是管理端可写配置的单一真源，新增 setting 不一定需要 schema migration。

#### 证据

- 来源: modules/common/system_settings.go#L25-L34
- 来源: modules/common/system_settings.go#L35-L44
- 来源: modules/common/system_settings.go#L45-L54
- 来源: modules/common/system_settings.go#L55-L60
- 来源: modules/common/system_settings.go#L72-L81
- 来源: modules/common/system_settings.go#L82-L91
- 来源: modules/common/system_settings.go#L92-L100
- 来源: modules/common/system_setting_schema.go#L69-L78
- 来源: modules/common/system_setting_schema.go#L79-L88
- 来源: modules/common/system_setting_schema.go#L89-L98
- 来源: modules/common/system_setting_schema.go#L99-L104

#### 适用范围

适用于解释管理后台“系统设置”为什么能热生效，以及 DB/YAML/default 三层优先级。

#### 不确定边界

具体每个 setting 的 getter fallback 需要按 key 逐个查 `system_settings.go`。

### 知识点：`login.local_off` 有防锁死安全回退，未配置可用第三方登录时不会关闭本地登录

#### 结论

`LocalLoginOff()` 只有在 DB 开关为真且至少一个第三方登录真正可用时才返回 true；第三方登录包括 OIDC、GitHub、Gitee，其中 OIDC 不只看 `DM_OIDC_ENABLED`，还要硬必填环境变量完整且能通过启动规则。这样即使管理员先打开 local_off 但 SSO 未配好，也会回退为本地登录可用，避免锁死。

#### 证据

- 来源: modules/common/system_settings.go#L427-L436
- 来源: modules/common/system_settings.go#L437-L446
- 来源: modules/common/system_settings.go#L447-L449
- 来源: modules/common/system_settings.go#L465-L474
- 来源: modules/common/system_settings.go#L475-L484
- 来源: modules/common/system_settings.go#L485-L489
- 来源: pkg/oidcboot/rules.go#L1-L10
- 来源: pkg/oidcboot/rules.go#L11-L20
- 来源: pkg/oidcboot/rules.go#L21-L30
- 来源: pkg/oidcboot/rules.go#L31-L33

#### 适用范围

适用于 SSO-only 切换、登录入口隐藏、误配置恢复策略说明。

#### 不确定边界

GitHub/Gitee OAuth 上游是否可用不由该本地检查保证，只校验 client_id/client_secret 存在。

### 知识点：管理端邮箱 MFA 是 `system_setting` 开关，但登录门禁要求 SMTP 真正预检成功

#### 结论

`login.manager_email_mfa_on` 是 system_setting schema 中的管理端邮箱二次验证开关；安全敏感路径不能只看布尔视图，而要看 `ManagerEmailMFAState` 和 `ManagerEmailMFAReady`。MFA 开启时要求 snapshot 可用、有效 SMTP 配置和针对当前配置的真实 SMTP preflight 成功；snapshot 未初始化或非法值会进入 unavailable，登录门禁 fail-closed。

#### 证据

- 来源: modules/common/system_setting_schema.go#L115-L123
- 来源: modules/common/system_settings.go#L977-L986
- 来源: modules/common/system_settings.go#L987-L996
- 来源: modules/common/system_settings.go#L997-L1004
- 来源: modules/common/system_settings.go#L1006-L1015
- 来源: modules/common/system_settings.go#L1016-L1025
- 来源: modules/common/system_settings.go#L1026-L1035
- 来源: modules/common/system_settings.go#L1036-L1039
- 来源: modules/common/system_settings.go#L1125-L1135

#### 适用范围

适用于解释管理端 MFA 配置、为什么开关打开后仍可能拒绝登录、SMTP 配置如何被验证。

#### 不确定边界

SMTP 具体字段来自 support email 相关 getter，本轮未逐项列全。

### 知识点：对象存储后端由 `fileService` 选择，预签名能力通过接口能力判断而非硬编码路由假设

#### 结论

文件服务根据 `ctx.GetConfig().FileService` 分派到 MinIO、Aliyun OSS、Qiniu、Tencent COS、AWS S3 或 SeaweedFS；`PresignedPutURL` / `PresignedGetURL` 会先判断底层服务是否实现对应接口，不支持时返回“当前文件服务不支持预签名上传/下载”。MinIO 预签名必须使用浏览器实际访问的 `DownloadURL` 作为签名 endpoint，且拒绝带路径前缀的 public URL。

#### 证据

- 来源: configs/tsdd.yaml#L69-L78
- 来源: configs/tsdd.yaml#L79-L88
- 来源: configs/tsdd.yaml#L89-L98
- 来源: configs/tsdd.yaml#L99-L103
- 来源: modules/file/service.go#L58-L67
- 来源: modules/file/service.go#L68-L77
- 来源: modules/file/service.go#L78-L87
- 来源: modules/file/service.go#L88-L97
- 来源: modules/file/service.go#L98-L99
- 来源: modules/file/service.go#L139-L148
- 来源: modules/file/service.go#L149-L158
- 来源: modules/file/service.go#L159-L160
- 来源: modules/file/service_minio.go#L190-L199
- 来源: modules/file/service_minio.go#L200-L209
- 来源: modules/file/service_minio.go#L210-L217
- 来源: modules/file/service_minio.go#L242-L251
- 来源: modules/file/service_minio.go#L252-L261
- 来源: modules/file/service_minio.go#L262-L271
- 来源: modules/file/service_minio.go#L272-L281
- 来源: modules/file/service_minio.go#L282-L291
- 来源: modules/file/service_minio.go#L292-L301
- 来源: modules/file/service_minio.go#L302-L311

#### 适用范围

适用于文件服务部署选型、浏览器直传、预签名 403 排障。

#### 不确定边界

Tencent COS、AWS S3、Qiniu、SeaweedFS 的全部签名/下载实现细节需在存储专题继续展开。

### 知识点：消息搜索配置完全走 `OCTO_SEARCH_*` 环境变量，并带若干 fail-closed/kill-switch 开关

#### 结论

`messages_search` 直接从环境变量加载 OpenSearch 地址、账号密码、read alias、超时、限流、cursor HMAC、头像 base URL、Space 过滤和停用词处理。`RequireSpaceID` 默认 true，P2P 搜索缺少 Space 时 fail-closed；`OCTO_SEARCH_STOPWORD_STRIP_ENABLED=false` 是停用词预处理的运维 kill switch。

#### 证据

- 来源: modules/messages_search/config.go#L10-L19
- 来源: modules/messages_search/config.go#L20-L29
- 来源: modules/messages_search/config.go#L30-L39
- 来源: modules/messages_search/config.go#L40-L49
- 来源: modules/messages_search/config.go#L50-L59
- 来源: modules/messages_search/config.go#L60-L69
- 来源: modules/messages_search/config.go#L70-L72
- 来源: modules/messages_search/config.go#L104-L113
- 来源: modules/messages_search/config.go#L114-L123
- 来源: modules/messages_search/config.go#L124-L132

#### 适用范围

适用于搜索功能部署、OpenSearch 凭证、Space 隔离和搜索降级开关排查。

#### 不确定边界

OpenSearch 索引结构和 DSL 拼接需在 API/存储或消息搜索专题继续补证据。

### 知识点：内部服务 token 配置要求最少 32 字节且禁止与相邻能力 token 复用

#### 结论

`OCTO_DRIVE_INTERNAL_TOKEN` 用于 drive-facing internal resolve endpoint；源码要求 token 非空、长度至少 32 字节，并且不得与 `NOTIFY_INTERNAL_TOKEN`、`OCTO_DOCS_NOTIFY_TOKEN`、`OCTO_DOCS_BOT_MENTION_TOKEN` 相同。注释说明不同内部消费者使用不同 token 是为了支持单独轮换并缩小泄露爆炸半径。

#### 证据

- 来源: modules/internal_resolve/config.go#L7-L16
- 来源: modules/internal_resolve/config.go#L17-L22
- 来源: modules/internal_resolve/config.go#L23-L32
- 来源: modules/internal_resolve/config.go#L33-L42
- 来源: modules/internal_resolve/config.go#L43-L52
- 来源: modules/internal_resolve/config.go#L53-L54
- 来源: modules/internal_resolve/config.go#L85-L94
- 来源: modules/internal_resolve/config.go#L95-L104
- 来源: modules/internal_resolve/config.go#L105-L114
- 来源: modules/internal_resolve/config.go#L115-L117

#### 适用范围

适用于内部服务鉴权、token 轮换、凭证碰撞风险说明。

#### 不确定边界

动态 card action route token/callback secret 的全局排重在 `main.go` 装配处，本轮未展开到卡片路由配置。

### 知识点：子区自动归档既有 system_setting 策略层，也有 env 运行参数层

#### 结论

`system_setting` 中的 `thread.auto_archive_enabled` 和 `thread.auto_archive_days` 是策略层，DB 为单一真源，env 是 fallback；`modules/thread/archive_config.go` 里的 `DM_THREAD_AUTO_ARCHIVE_INTERVAL`、`DM_THREAD_AUTO_ARCHIVE_BATCH_SIZE`、`DM_THREAD_AUTO_ARCHIVE_BATCH_SLEEP` 是 worker 运行参数，非法或越界值回退默认值，batch size 上限为 5000，避免单次 UPDATE 变成长事务。

#### 证据

- 来源: modules/common/system_setting_schema.go#L47-L56
- 来源: modules/common/system_setting_schema.go#L57-L66
- 来源: modules/common/system_setting_schema.go#L67-L67
- 来源: modules/common/system_setting_schema.go#L152-L165
- 来源: modules/thread/archive_config.go#L10-L22
- 来源: modules/thread/archive_config.go#L24-L33
- 来源: modules/thread/archive_config.go#L34-L43
- 来源: modules/thread/archive_config.go#L44-L51
- 来源: modules/thread/archive_config.go#L104-L110

#### 适用范围

适用于解释子区归档“是否归档/多久算陈旧”和“worker 多久跑/批量多大”两类配置边界。

#### 不确定边界

归档 worker 的实际启动点和每次 tick 的 SQL 行为需在 IM/Thread 控制面专题继续补充。
