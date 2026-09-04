# 08 — 存储与外部依赖

## 知识点：MySQL 是主要关系型存储，启动时可执行 sql-migrate migration

### 结论

`pkg/db.NewMySQL` 使用 go-sql-driver/mysql 打开连接，设置连接池，Ping 成功后返回 dbr session；当 migration 参数为 true 时调用 `Migration`，后者用 `sql-migrate` 执行 SQL 文件。

### 证据

- 来源: pkg/db/mysql.go#L10-L18
- 来源: pkg/db/mysql.go#L22-L31
- 来源: pkg/db/mysql.go#L32-L38
- 来源: pkg/db/mysql.go#L41-L50

### 适用范围

适用于数据库连接、启动迁移、SQL 目录机制说明。

### 不确定边界

具体哪些模块 SQL 会被收集，需结合 `module.Setup` 和各模块 `SQLDir` 继续补 octo-lib 证据。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：Redis 用于缓存、session、限流等，并统一支持 TLS 配置与指标插桩

### 结论

配置文件提供 Redis 地址、密码、TLS、CA 等字段；`pkg/redis.BuildOptions` 从 config 构造 Redis options，统一处理 TLS，并建议所有裸 `rd.NewClient` 场景通过该函数，避免遗漏 TLS 和指标插桩。

### 证据

- 来源: configs/tsdd.yaml#L26-L34
- 来源: pkg/redis/options.go#L15-L24
- 来源: pkg/redis/options.go#L58-L67
- 来源: pkg/redis/options.go#L68-L77
- 来源: pkg/redis/options.go#L78-L81

### 适用范围

适用于 token session、限流、OIDC 锁、bot registry、health 等 Redis 客户端。

### 不确定边界

各模块 Redis key 命名需继续逐模块补充。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：对象存储支持多后端，但浏览器直传能力不同

### 结论

配置文件列出 `fileService` 支持 `minio`、`aliyunOSS`、`seaweedFS`、`qiniu`，并在注释中给出 MinIO、Tencent COS、Aliyun OSS、Qiniu、SeaweedFS 的 presigned PUT/GET 支持矩阵。

### 证据

- 来源: configs/tsdd.yaml#L88-L97
- 来源: configs/tsdd.yaml#L98-L103
- 来源: configs/tsdd.yaml#L135-L144
- 来源: configs/tsdd.yaml#L145-L154
- 来源: configs/tsdd.yaml#L155-L164
- 来源: configs/tsdd.yaml#L165-L170

### 适用范围

适用于文件上传、下载、预签名 URL、对象存储部署选型。

### 不确定边界

Tencent COS 配置实际字段和 service 实现需继续查 `modules/file/service_cos.go`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：File 模块路由需要登录态认证，并提供上传、预签名上传、下载 URL

### 结论

`modules/file/api.go` 在 `/v1/file` 下挂 `AuthMiddleware`，提供 preview、upload、upload/presigned、upload/credentials、download/url；同文件还把 upload/download URL 暴露给 User API Key tree，并说明租户/对象 key 风险边界。

### 证据

- 来源: modules/file/api.go#L83-L92
- 来源: modules/file/api.go#L93-L99
- 来源: modules/file/api.go#L101-L110
- 来源: modules/file/api.go#L111-L120
- 来源: modules/file/api.go#L121-L130

### 适用范围

适用于文件服务、User API Key 直传下载、对象存储权限说明。

### 不确定边界

上传对象归属与私有桶能力需继续结合 service 和 policy 文件补充。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：启动期会在模块迁移前修正历史 migration 记录，Thread schema 与运行开关解耦

#### 结论

服务启动时在 `module.Setup(ctx)` 前执行两类兼容修正：先重写 legacy migration IDs，避免 `sql-migrate` 在 PlanMigration 阶段遇到“数据库里有但磁盘上没有”的 migration ID 后 panic；再对旧 init-db 已建 Thread 表但 `gorp_migrations` 缺少 thread-* 记录的情况预置 migration 记录，避免 thread 模块 SQLDir 无条件注册后重复执行 `CREATE TABLE thread` 触发 MySQL 1050。

#### 证据

- 来源: main.go#L456-L465
- 来源: main.go#L466-L475
- 来源: main.go#L476-L483
- 来源: pkg/db/mysql.go#L41-L50
- 来源: modules/thread/archive_config.go#L40-L51

#### 适用范围

适用于升级、旧库兼容、Thread 功能开关与 schema 是否存在之间的关系说明。

#### 不确定边界

`octodb.RewriteLegacyMigrationIDs` / `ReconcileThreadSchemaRecords` 的内部匹配表不在本条展开，需继续查对应 `internal/pkg` 或依赖源码。

### 知识点：认证 session 依赖 Redis Lua 能力，rollout 控制以 MySQL 为权威、Redis 做 writer lease

#### 结论

启动早期会构造 tokenStore 与 sessionRedis，并用 `tokenStore.Probe` 验证认证 session Redis Lua 支持；失败会 panic。session rollout 控制在模块 migration 之后启动，注释明确 MySQL 是 floor/cap 唯一权威，Redis 负责 writer lease 与 run_id 扫描证据；writerRegistry 会先绑定到 tokenStore，使写路径在首次 lease 前 fail-closed。

#### 证据

- 来源: main.go#L214-L218
- 来源: main.go#L949-L958
- 来源: main.go#L959-L968
- 来源: main.go#L969-L978
- 来源: main.go#L979-L986

#### 适用范围

适用于登录态、session 双写/rollout、Redis 故障下为什么写入会收紧而不是静默放开。

#### 不确定边界

rollout 表结构和 lease key 命名在 `pkg/auth` / migration SQL 中，需要在认证专题继续细化。

### 知识点：全局限流使用独立 Redis client，必须统一 TLS 与插桩

#### 结论

全局 per-IP 限流状态存在 Redis，用独立 go-redis client 是因为 lib 的 `redis.Conn` 未暴露 Lua Eval/Script 能力；client 通过 `octoredis.NewInstrumentedClient` 构造，并设置较小连接池，避免多副本大核机器连接数失控。`pkg/redis/options.go` 明确要求 octo-server 内直接使用 `rd.NewClient` 的场景都经 BuildOptions/NewInstrumentedClient，以统一 Redis TLS 与 dependency 指标插桩。

#### 证据

- 来源: main.go#L295-L305
- 来源: pkg/redis/options.go#L15-L24
- 来源: pkg/redis/options.go#L58-L67
- 来源: pkg/redis/options.go#L68-L77
- 来源: pkg/redis/options.go#L78-L81

#### 适用范围

适用于限流、OIDC 锁、health 探针、Bot registry 等裸 Redis client 的配置审查。

#### 不确定边界

各模块 Redis key 空间需逐模块查；本条只确认 client 构造约束。

### 知识点：对象存储由 `fileService` 分派，预签名能力按 backend 接口能力 fail-closed

#### 结论

`modules/file/service.go` 根据 `FileService` 分派到 MinIO、Aliyun OSS、Qiniu、Tencent COS、AWS S3 或 SeaweedFS，并把 backend 作为低基数指标标签。预签名上传/下载不是所有 backend 默认具备的能力：Service 会通过 `PresignedPutter` / `PresignedGetter` 接口断言，backend 不支持时直接返回“不支持预签名上传/下载”的错误，而不是伪造 URL。

#### 证据

- 来源: modules/file/service.go#L58-L67
- 来源: modules/file/service.go#L68-L77
- 来源: modules/file/service.go#L78-L87
- 来源: modules/file/service.go#L88-L97
- 来源: modules/file/service.go#L98-L99
- 来源: modules/file/service.go#L139-L148
- 来源: modules/file/service.go#L149-L158
- 来源: modules/file/service.go#L159-L160

#### 适用范围

适用于对象存储选型、预签名接口灰度、为什么某些部署支持普通上传但不支持浏览器直传。

#### 不确定边界

Aliyun OSS / Qiniu / S3 的具体签名差异需分别查对应 service 文件。

### 知识点：MinIO 预签名 URL 必须用浏览器可访问 public endpoint 签名，且 PUT 签入 Content-Length

#### 结论

MinIO 预签名 client 使用 `publicEndpoint`，注释说明 SigV4 会把 host 纳入签名，签名后再改 host 会导致签名失效；public endpoint 只能是 `scheme://host:port`，不支持反向代理 path prefix。`PresignedPutURL` 要求正向 fileSize，并通过 `PresignHeader` 把 Content-Length、Content-Type、Content-Disposition 写入签名头，避免同一个 URL 被上传任意大小内容。

#### 证据

- 来源: modules/file/service_minio.go#L206-L215
- 来源: modules/file/service_minio.go#L216-L225
- 来源: modules/file/service_minio.go#L226-L235
- 来源: modules/file/service_minio.go#L236-L245
- 来源: modules/file/service_minio.go#L246-L255
- 来源: modules/file/service_minio.go#L256-L263
- 来源: modules/file/service_minio.go#L369-L378
- 来源: modules/file/service_minio.go#L379-L388
- 来源: modules/file/service_minio.go#L389-L398
- 来源: modules/file/service_minio.go#L399-L408
- 来源: modules/file/service_minio.go#L409-L414
- 来源: modules/file/service_minio.go#L417-L426
- 来源: modules/file/service_minio.go#L427-L436
- 来源: modules/file/service_minio.go#L437-L446
- 来源: modules/file/service_minio.go#L447-L450

#### 适用范围

适用于 MinIO 公网/内网 endpoint 配置、直传 URL 403 SignatureDoesNotMatch、上传大小约束排查。

#### 不确定边界

桶策略、public read 与私有桶鉴权在同文件其它段落；本条只覆盖预签名生成关键约束。

### 知识点：COS 预签名会区分 bucket 子域与 CDN alias，CDN 只用于非预签名下载 URL

#### 结论

Tencent COS 的 `PresignedPutURL` 会根据 BucketURL 形状选择签名 client：bucket 子域或空 BucketURL 时按浏览器访问 endpoint 签名；CDN alias 时改用 canonical COS endpoint 签名，因为 CDN 域名没有 SDK path-style `/<bucket>/<key>` 对应路由。注释明确 CDN 只用于非预签名下载 URL，预签名上传/下载直接打 COS canonical endpoint，并同样把 fileSize 签入 Content-Length。

#### 证据

- 来源: modules/file/service_cos.go#L300-L309
- 来源: modules/file/service_cos.go#L310-L319
- 来源: modules/file/service_cos.go#L320-L329
- 来源: modules/file/service_cos.go#L330-L339
- 来源: modules/file/service_cos.go#L340-L349
- 来源: modules/file/service_cos.go#L350-L359
- 来源: modules/file/service_cos.go#L360-L365

#### 适用范围

适用于 COS + CDN 部署、直传 URL host 选择、为什么预签名不走 CDN 的问题解释。

#### 不确定边界

COS `publicEndpoint` 对 BucketURL 的完整解析在同文件前半段，必要时可继续查 `publicEndpoint` 与 `newCanonicalPresignClient`。

### 知识点：system_setting 是 DB 热更新层，初始读取失败普通配置回退 YAML，安全门禁可 fail-closed

#### 结论

`EnsureSystemSettings` 初始 `Load` 失败不阻止服务启动，会启动每 60 秒 auto-reload 自愈；普通 getter 在 snapshot 为空时回退 YAML，而安全门禁（注释举例 ScanLoginEnabled）在首次成功 load 前 fail-closed。`Load` 会读取所有 `system_setting` 行，encrypted 类型若解密失败则跳过该键并回退 YAML，不把密文或坏值发布进快照。

#### 证据

- 来源: modules/common/system_settings.go#L38-L47
- 来源: modules/common/system_settings.go#L48-L57
- 来源: modules/common/system_settings.go#L58-L64
- 来源: modules/common/system_settings.go#L145-L154
- 来源: modules/common/system_settings.go#L155-L164
- 来源: modules/common/system_settings.go#L165-L174
- 来源: modules/common/system_settings.go#L175-L181

#### 适用范围

适用于管理台热配置、多实例配置收敛、SMTP 密码/加密配置、为什么部分安全开关在 DB 异常时收紧。

#### 不确定边界

每个 getter 的具体 fallback 策略不同，必须按具体 key 查 `system_settings.go` 对应方法。

### 知识点：system_setting 覆盖 Agent Mail 展示、文件策略与 SMTP 配置，但不替代底层鉴权/硬边界

#### 结论

schema 中 `mail.enabled` 只控制客户端 Agent Mail 入口展示，不替代 gateway 既有鉴权；文件上传策略支持 `extra_blocked_extensions`、`extra_allowed_extensions` 与 `max_size_kb` 热配置，但内置黑名单不可撤销，大小上限还受部署侧 hard cap 约束；SMTP 支持邮箱、服务器与加密密码等配置项。

#### 证据

- 来源: modules/common/system_setting_schema.go#L289-L292
- 来源: modules/common/system_setting_schema.go#L369-L378
- 来源: modules/common/system_setting_schema.go#L379-L384
- 来源: modules/common/system_setting_schema.go#L414-L420

#### 适用范围

适用于“开关开了为何仍不能访问 Agent Mail”“紧急封禁文件扩展名”“SMTP 密码加密存储”等问题。

#### 不确定边界

这些配置的写接口、校验和审计在 manager system setting API 文件中，需另查。

### 知识点：OIDC 完全走环境变量配置，禁用时不校验 provider；启用后严格校验协议、URL、TTL 与安全开关

#### 结论

OIDC 配置由环境变量加载；`DM_OIDC_ENABLED=false` 时直接返回，不校验 provider 字段。启用后读取 provider kind/baseURL/client/redirect/scopes/logout 等配置，并有迁移 alias 兼容。源码特别约束 IDTokenTTL 不能小于等于 0，避免 Redis SET 过期变成永不过期；logout URL 会校验，且 insecure upstream/logout 只能通过显式 env 开关打开。

#### 证据

- 来源: modules/oidc/config.go#L129-L138
- 来源: modules/oidc/config.go#L139-L148
- 来源: modules/oidc/config.go#L149-L158
- 来源: modules/oidc/config.go#L159-L168
- 来源: modules/oidc/config.go#L169-L178
- 来源: modules/oidc/config.go#L179-L188
- 来源: modules/oidc/config.go#L189-L198
- 来源: modules/oidc/config.go#L199-L207
- 来源: modules/oidc/config.go#L236-L248
- 来源: modules/oidc/config.go#L338-L347
- 来源: modules/oidc/config.go#L348-L357
- 来源: modules/oidc/config.go#L358-L360

#### 适用范围

适用于 SSO/OIDC 部署、Redis id_token 缓存 TTL、安全开关、provider kind 配置错误排查。

#### 不确定边界

实际 state/nonce/lock Redis key 与 OIDC callback 流程需继续查 `modules/oidc` 其它文件。

### 知识点：消息搜索依赖 OpenSearch/Elasticsearch 环境变量，DM Space 过滤默认 fail-closed

#### 结论

`messages_search` 从 `OCTO_SEARCH_OS_*`、`OCTO_SEARCH_TIMEOUT`、`OCTO_SEARCH_RPS/BURST`、`OCTO_SEARCH_CURSOR_HMAC` 等环境变量构造搜索配置。`RequireSpaceID` 默认 true：p2p/DM 搜索必须带非空 X-Space-ID 或 space_id，并按 OS DSL 过滤 `spaceId`；缺少 Space 时按 NOT_FOUND 处理。将其关掉是索引回填期逃生开关，注释要求每次 p2p 请求 WARN，避免偏离长期静默存在。

#### 证据

- 来源: modules/messages_search/config.go#L31-L40
- 来源: modules/messages_search/config.go#L41-L50
- 来源: modules/messages_search/config.go#L51-L52
- 来源: modules/messages_search/config.go#L104-L113
- 来源: modules/messages_search/config.go#L114-L123
- 来源: modules/messages_search/config.go#L124-L130
- 来源: modules/messages_search/config.go#L190-L202

#### 适用范围

适用于消息搜索服务依赖、OS 地址/认证、搜索限流、DM 跨 Space 搜索泄漏风险。

#### 不确定边界

索引 mapping、DSL 构造、游标签名与 search route 权限在其它文件中，需按搜索专题继续深挖。

### 知识点：SMS 验证码依赖 Redis 保存验证码与 1 分钟发送频控，release 模式禁止万能测试码

#### 结论

短信发送前先查 Redis `sms_rate_limit:{zone}@{phone}`，命中则拒绝；生成验证码后将验证码写入 Redis 5 分钟，并写入 1 分钟频控 key，再调用 Aliyun/Unisms/Smsbao 等 provider。测试验证码只在非 release 且配置了 `SMSCode` 时启用；启动校验在 release 模式下发现 `smsCode` 会报错，避免万能验证码后门。

#### 证据

- 来源: modules/base/common/service_sms.go#L44-L53
- 来源: modules/base/common/service_sms.go#L54-L63
- 来源: modules/base/common/service_sms.go#L64-L73
- 来源: modules/base/common/service_sms.go#L74-L83
- 来源: modules/base/common/service_sms.go#L84-L93
- 来源: modules/base/common/service_sms.go#L94-L103
- 来源: modules/base/common/service_sms.go#L104-L105
- 来源: modules/base/common/testcode.go#L10-L19
- 来源: modules/base/common/testcode.go#L20-L29
- 来源: modules/base/common/testcode.go#L30-L39
- 来源: modules/base/common/testcode.go#L40-L48

#### 适用范围

适用于短信验证码、频率限制、测试码安全、生产配置审计。

#### 不确定边界

各短信 provider 的凭证字段和错误处理分布在 `service_aliyun.go`、`service_unisms.go`、`service_smsbao.go`。

### 知识点：Thread archive 与 Voice Adapter 是纯 env 驱动的外部/后台依赖配置，非法值回默认

#### 结论

Thread 自动归档 worker 通过 `DM_THREAD_AUTO_ARCHIVE_*` 环境变量配置 enabled、归档天数、tick 间隔、批量大小与批间 sleep；非法或越界值回退默认值，batch size 超上限会截断，避免大事务。Voice Adapter 通过 `SPEECH_SERVICE_URL`、`SPEECH_API_KEY`、`SPEECH_TIMEOUT`、`SPEECH_MAX_BODY_SIZE` 等环境变量配置语音服务，timeout/max body 非法或非正时回默认。

#### 证据

- 来源: modules/thread/archive_config.go#L10-L19
- 来源: modules/thread/archive_config.go#L20-L29
- 来源: modules/thread/archive_config.go#L30-L39
- 来源: modules/thread/archive_config.go#L40-L49
- 来源: modules/thread/archive_config.go#L50-L51
- 来源: modules/thread/archive_config.go#L54-L63
- 来源: modules/thread/archive_config.go#L64-L73
- 来源: modules/thread/archive_config.go#L74-L83
- 来源: modules/thread/archive_config.go#L84-L93
- 来源: modules/thread/archive_config.go#L94-L103
- 来源: modules/thread/archive_config.go#L104-L111
- 来源: modules/voice_adapter/config.go#L9-L18
- 来源: modules/voice_adapter/config.go#L19-L28
- 来源: modules/voice_adapter/config.go#L29-L38
- 来源: modules/voice_adapter/config.go#L39-L48
- 来源: modules/voice_adapter/config.go#L49-L54

#### 适用范围

适用于后台归档任务、语音转写/反馈外部服务、运维参数错误时的回退行为说明。

#### 不确定边界

archive worker 具体 UPDATE 条件、voice 请求签名/错误处理需分别查 worker 与 speech client 实现。

### 知识点：Agent Mail Gateway 配置缺失时禁用，URL/secret 必须成对且 secret 至少 32 字节

#### 结论

Agent Mail Gateway 从 `OCTO_MAIL_GATEWAY_URL`、`OCTO_MAIL_GATEWAY_SECRET`、`OCTO_MAIL_GATEWAY_TIMEOUT` 读取配置；URL 和 secret 都为空时返回 not configured 并禁用，只有一个为空时报配置错误；secret 少于 32 字节、URL 非 http(s) origin 或带 user/query/fragment 都会报错。timeout 必须大于 0 且不超过 2 分钟。

#### 证据

- 来源: modules/agentmailgateway/gateway.go#L32-L45
- 来源: modules/agentmailgateway/gateway.go#L131-L140
- 来源: modules/agentmailgateway/gateway.go#L141-L150
- 来源: modules/agentmailgateway/gateway.go#L151-L158
- 来源: modules/agentmailgateway/gateway.go#L198-L207
- 来源: modules/agentmailgateway/gateway.go#L208-L217
- 来源: modules/agentmailgateway/gateway.go#L218-L227
- 来源: modules/agentmailgateway/gateway.go#L228-L228

#### 适用范围

适用于 Agent Mail 部署、网关不可用、secret/URL 安全校验和上游代理边界。

#### 不确定边界

octo-mail 上游自身的存储、账号和邮件 API 不属于 `octo-server` 源码定义范围。
