# 跨模块高频问题速查表

本文件不是第十个“新领域”，而是九大知识库的交叉索引。用途是：当用户/考官按真实问题提问时，快速定位它同时牵涉哪些知识域、应先查什么、能否直接答复、是否需要收单或转人工。

## 使用原则

1. 主结构仍以九大知识库为准：认证与身份、鉴权模型、配置、业务模块清单、API 与错误约定、IM 控制面、Bot 与 Agent、存储与外部依赖、构建与发布。
2. 本表只收录“跨域高频问题”，不替代各领域知识库。
3. 对外正式回答必须回到对应领域文档和源码行号；如果只有注释/设计文档，需标注证据等级。
4. 涉及 token、secret、越权、日志泄露、跨空间访问、生产权限，一律先走风险判断，不直接给操作性绕过建议。

## 速查矩阵

| 高频问题 | 主要挂靠领域 | 还会牵涉 | 首查文件/证据 | 分诊建议 |
|---|---|---|---|---|
| Bot 为什么发不了消息 / 收不到消息？ | 7 Bot 与 Agent | 1 认证与身份、2 鉴权模型、5 API 与错误、6 IM 控制面 | `modules/bot_api/`、`modules/group/`、`modules/thread/`、`main.go` | 若涉及 bot token/跨群/跨空间，使用 `priority/P0` 或 `status/blocked` 表达阻塞，并在正文写脱敏风险说明；无法复现则补充 bot uid、channel、时间、错误码 |
| Bot token 怎么来、谁能取？ | 1 认证与身份 | 2 鉴权模型、7 Bot 与 Agent、8 存储 | `modules/bot_provision/bot_api.go` | 涉及 token 展示/泄露直接转人工，不能在群内展示凭证 |
| Bot 代用户读取群/Thread 消息的边界是什么？ | 2 鉴权模型 | 6 IM 控制面、7 Bot 与 Agent | `modules/bot_api/obo_api.go` | 重点判断 grantor 是否有频道读取权；未知 channel type / DB 错误按 fail-closed 理解 |
| Webhook 调不通 / 是否安全？ | 3 配置 | 1 认证与身份、5 API 与错误、8 存储与外部依赖 | `configs/tsdd.yaml`、`modules/incomingwebhook/api.go`、`main.go` | 涉及 webhook secret、URL token、日志泄露时使用 `priority/P0 + status/blocked`，正文只写脱敏风险说明 |
| 卡片按钮点了没反应 / Action 回调失败？ | 5 API 与错误约定 | 2 鉴权模型、6 IM 控制面、7 Bot 与 Agent | `internal/carddispatch/`、`modules/card_template_catalog/`、`modules/message/` | 区分模板发布、发送权限、回调分发、幂等/CAS；缺回调日志则收单补证据 |
| 登录 / OIDC / token 失效怎么判断？ | 1 认证与身份 | 2 鉴权模型、3 配置、8 存储 | `modules/oidc/`、`pkg/auth/`、`main.go` | 涉及管理员降权、退出登录、token 续期时不要只看客户端状态，要看 Redis/session 语义 |
| 文件上传 403 / 预签名 URL 失败？ | 8 存储与外部依赖 | 3 配置、5 API 与错误、2 鉴权模型 | `modules/file/api.go`、`configs/tsdd.yaml` | 先查是否直传、header 是否一致、bucket CORS 是否允许；对象 key 权限问题单独收单 |
| 群 / Thread 权限异常？ | 2 鉴权模型 | 4 业务模块清单、6 IM 控制面、7 Bot 与 Agent | `modules/group/`、`modules/thread/`、`modules/bot_api/obo_api.go` | 先区分群成员关系、Thread 父群关系、Bot 身份、普通用户身份 |
| 配置改了为什么不生效？ | 3 配置 | 8 存储、9 构建发布、5 API 与错误 | `configs/tsdd.yaml`、`main.go` | 区分 YAML、环境变量、system_setting、运行期热调、启动期校验 |
| 部署 / 构建 / octo-deployment 关系？ | 9 构建与发布 | 3 配置、8 外部依赖 | `README.md`、`Dockerfile`、`Dockerfile.ghcr`、`Makefile` | 回答时说明本仓是 server，完整 compose 栈在 octo-deployment |

## 典型问题展开

### 1. Bot token 怎么来、谁能取？

- `POST /v1/bot/mint` 是 web session-auth 路径，用于 mint bot OBO，并且 bot token 由 server 生成、留存在 `robot` 表。来源: modules/bot_provision/bot_api.go#L8-L15
- mint 前要求当前登录用户存在；没有登录 UID 会返回认证失败。来源: modules/bot_provision/bot_api.go#L50-L53
- mint 到某个 space 前，会校验调用者确实是目标 space 成员，避免任意登录用户往任意 space 投放 bot。来源: modules/bot_provision/bot_api.go#L70-L79
- `GET /v1/bot/:uid/token` 是 daemon 使用 `Authorization: Bearer uk_<key>` 获取 bot token 的路径，并要求 bot 创建者、bot 状态、space membership 同时满足。来源: modules/bot_provision/bot_api.go#L96-L108

分诊口径：涉及“把 token 发我看一下”“帮我绕过 token”“直接查 bot token”的请求，不能在群内展示凭证，转人工并标记安全风险。

### 2. Bot 代用户读群/Thread 的边界是什么？

- OBO grant 管理路由挂在 `/v1/obo`，使用普通用户 `AuthMiddleware`，不是 bot token 路径。来源: modules/bot_api/obo_api.go#L103-L117
- 创建 scope 前会检查授权人是否有目标频道读取权，未知类型、DB 错误、缺失成员关系都按不可访问处理，避免泄露频道流量。来源: modules/bot_api/obo_api.go#L465-L472
- 群频道要求 grantor 是群成员；Thread/CommunityTopic 继承父群读取 ACL。来源: modules/bot_api/obo_api.go#L705-L713
- 实际判断中，Group 直接查群成员；Thread 会拆出父群号，格式异常 fail-closed。来源: modules/bot_api/obo_api.go#L725-L739；来源: modules/bot_api/obo_api.go#L740-L744

分诊口径：凡是“Bot 能否看某群/某 Thread”的问题，不能只看 bot 是否存在，要同时查 grantor、space、group_member、thread 父群关系。

### 3. Webhook 调不通 / 是否安全？

- 配置支持 webhook HMAC-SHA256 签名密钥，配置后入站 webhook 请求必须携带 `X-Signature-256`。来源: configs/tsdd.yaml#L15-L19
- incoming webhook 有多组限流/大小环境变量，同时 per-webhook rps/burst/max_per_group 已迁移到 system_setting，env 仍作 fallback。来源: modules/incomingwebhook/api.go#L42-L56
- webhook 消息的 FromUID 形如 `iwh_xxx`，不是群成员；撤回权限依赖 message 模块现有兜底逻辑。来源: modules/incomingwebhook/api.go#L67-L73
- 主进程在 server 创建前替换 gin error writer，原因是 incoming-webhook path 中可能包含明文 token，panic/access log 需要脱敏。来源: main.go#L185-L191

分诊口径：webhook 问题优先查签名、token、限流、body 大小、目标群/Thread、日志脱敏；不能要求用户在群里贴完整 webhook URL 或 secret。

### 4. 卡片按钮 / Card Action 没反应怎么办？

- 卡片模板管理面挂在 `/v1/manager/card-templates`，并使用 AuthMiddleware 与 manager 权限中间件。来源: modules/card_template_catalog/api.go#L120-L128
- 模板管理包含 validate、publish、audit、detail、active、rollback、block 等动作。来源: modules/card_template_catalog/api.go#L128-L134
- card dispatch registry 会校验 target、space policy、group policy、依赖组件；非法配置会被 reject。来源: internal/carddispatch/registry.go#L139-L150
- registry 允许的 channel type 包括 person、group、community topic，并校验 card profile。来源: internal/carddispatch/registry.go#L160-L174

分诊口径：卡片问题不能只看前端按钮；要拆成模板是否发布、发送者身份、目标 channel type、group/space policy、回调是否进 dispatch、是否被幂等/CAS 拦截。

### 5. OIDC / token / 会话失效怎么判断？

- OIDC state 有授权到 callback 的有效期，前端短码轮询登录结果的窗口为 5 分钟。来源: modules/oidc/api.go#L33-L40
- authcode 有字符集限制，避免 Redis key 注入或跨 user 覆盖。来源: modules/oidc/api.go#L49-L57
- OIDC logout 需要显式删除当前请求携带的 HTTP token，不能按 uid 粗暴删除所有 token，否则会踢掉其他设备。来源: modules/oidc/api.go#L72-L80
- API 启动时注入自定义 TokenParser，并实时解析用户语言和角色，使管理员降权/删除的生效窗口收敛到缓存 TTL。来源: main.go#L205-L218
- token parser 使用 token validator，并绑定 token cache prefix。来源: main.go#L221-L225

分诊口径：登录类问题要问清是 OIDC state、短码、HTTP token、Redis session、角色缓存、还是 Bearer 兼容问题；不能把所有“登录失效”都归为同一类。

### 6. 文件上传 403 / 预签名 URL 失败怎么排查？

- 文件接口挂在 `/v1/file` 且需要 AuthMiddleware，包含 preview、upload、presigned/credentials、download URL。来源: modules/file/api.go#L83-L96；来源: modules/file/api.go#L97-L98
- 预签名上传路由是 route-guard，服务端生成 object key，并拒绝调用方指定已知 key 的写入能力。来源: modules/file/api.go#L106-L116；来源: modules/file/api.go#L118-L123
- sticker upload 支持独立 IP 限流环境变量。来源: modules/file/api.go#L133-L138
- 配置说明要求浏览器直传时对象存储 bucket 必须允许来自 octo-web origin 的 PUT CORS。来源: configs/tsdd.yaml#L70-L76
- `GET /v1/file/upload-credentials` 返回的 contentType/contentDisposition 必须由浏览器在 PUT 时原样带上，否则签名会不匹配导致 403。来源: configs/tsdd.yaml#L78-L85
- 不支持预签名的后端会返回明确错误，客户端应回退到服务端上传或 unsigned DownloadURL。来源: configs/tsdd.yaml#L100-L103

分诊口径：文件 403 优先查 CORS、签名 header 是否一致、对象存储后端是否支持 presign、是否走旧路径兼容、是否触发上传限流。

### 7. 群 / Thread 权限异常怎么判断？

- 群 API 挂在 `/v1/group` 和 `/v1/groups`，均使用 AuthMiddleware。来源: modules/group/api.go#L90-L100；来源: modules/group/api.go#L101-L106
- Thread 模块监听消息，只有满足 `shouldProcessThreadMessage` 的消息才触发子区解档、计数和预览更新。来源: modules/thread/api.go#L47-L55
- Thread 对系统消息、tip、置顶等场景有专门过滤，避免归档子区被错误解档或 message_count 被错误增加。来源: modules/thread/api.go#L90-L96
- OBO 对 Thread 的读取权限继承父群成员关系。来源: modules/bot_api/obo_api.go#L705-L713

分诊口径：群/Thread 问题优先明确身份是普通用户、Bot、webhook 还是系统；再查父群成员关系、群状态、Thread channel id、消息类型。

### 8. 配置改了为什么不生效？

- webhook secret、WuKongIM API URL、manager token 都在 `configs/tsdd.yaml` 有配置说明。来源: configs/tsdd.yaml#L15-L24
- API 层限流 RPS/Burst 从环境变量读取，并通过 Redis 共享配额。来源: main.go#L293-L305
- CORS 允许源来自 `DM_CORS_ALLOWED_ORIGINS`。来源: main.go#L451-L453

分诊口径：配置类问题先判断它是 YAML 配置、环境变量、system_setting 运行期配置，还是外部依赖配置；不要只说“重启试试”。

### 9. 构建与部署边界怎么答？

- README 的 quickstart 是 `go build -o octo-server .` 后用 `./octo-server --config ./configs/tsdd.yaml` 启动。来源: README.md#L48-L55
- 一键 Docker Compose 栈不在本仓，README 指向 `Mininglamp-OSS/octo-deployment`，包含 server、admin、web、matter、smart-summary、WuKongIM、MySQL、Redis、MinIO、nginx。来源: README.md#L60-L64

分诊口径：本仓回答 server 构建与配置；完整环境、compose、nginx、依赖服务编排要指向 octo-deployment，不能把部署仓职责误归到 octo-server。

## 反向挂靠九大知识库

| 九大领域 | 本速查表补充重点 |
|---|---|
| 1 认证与身份 | Bot token、uk api_key、HTTP token、OIDC state、Bearer 兼容、webhook secret |
| 2 鉴权模型 | space membership、group_member、Thread 继承父群 ACL、card dispatch policy、fail-closed |
| 3 配置 | webhookSecretKey、WuKongIM、CORS、限流 env、对象存储 CORS/header |
| 4 业务模块清单 | bot_api、bot_provision、incomingwebhook、card_template_catalog、file、group、thread、message |
| 5 API 与错误约定 | 401/404/403 的业务含义、existence-leak 姿态、回调失败、上传失败 |
| 6 IM 控制面 | Bot/Webhook/Message/Thread 最终都可能进入消息投递或监听链路 |
| 7 Bot 与 Agent | Bot mint、token、OBO grant/scope、card 能力、群/Thread 消息入口 |
| 8 存储与外部依赖 | Redis session、Redis 限流、MySQL group_member/robot/space_member、对象存储 |
| 9 构建与发布 | 本仓 go build/server；完整 compose 栈在 octo-deployment |
