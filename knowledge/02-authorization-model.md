# 02 — 鉴权模型

## 知识点：系统角色不完全信任 token 快照，而是在 Parse 时可接入实时角色解析

### 结论

主程序注入 `RoleResolver`，注释明确说明此前 admin/superAdmin 角色固化在 token 里，降权要等 token 过期；现在在 Parse 时按 uid 实时解析 DB/cache 中的角色，将降权生效窗口收敛到缓存 TTL。

### 证据

- 来源: main.go#L205-L214
- 来源: main.go#L215-L224
- 来源: main.go#L225-L227
- 来源: pkg/auth/parser.go#L45-L57
- 来源: pkg/auth/parser.go#L104-L113

### 适用范围

适用于依赖 `AuthMiddleware` 后 `CheckLoginRole` / 管理员角色判断的后台或管理接口。

### 不确定边界

RoleService 具体 DB 查询逻辑需继续补 `modules/user` 证据。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：存在比 superAdmin 更窄的管理角色，但该角色不会自动获得全部 admin endpoint 权限

### 结论

`pkg/auth/manager_roles.go` 定义了 `dashboardReader`、`marketAdmin` 等固定角色；注释强调这些角色故意不加入 octo-lib 的 `CheckLoginRole`，避免意外授予所有 admin endpoint 权限。

### 证据

- 来源: pkg/auth/manager_roles.go#L1-L10
- 来源: pkg/auth/manager_roles.go#L11-L20
- 来源: pkg/auth/manager_roles.go#L21-L24

### 适用范围

适用于管理后台的分权说明，尤其是“不是所有 manager role 都等于 superAdmin”。

### 不确定边界

每个具体 admin 路由允许哪些角色，需要继续逐模块检查 handler 中的 `CheckLoginRole*` 和模块自定义 guard。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：Space 管理模块以 `space` 与 `space_manager` 两个模块形态注册，共享同一个 Space 实例

### 结论

`modules/space/1module.go` 通过 `sync.Once` 构造共享 `*Space`，分别注册 `space` 和 `space_manager`；这说明 Space 既有普通 API，也有 manager 侧 API。

### 证据

- 来源: modules/space/1module.go#L17-L26
- 来源: modules/space/1module.go#L27-L36
- 来源: modules/space/1module.go#L37-L46
- 来源: modules/space/1module.go#L47-L52

### 适用范围

适用于解释 org/space 维度权限与空间管理 API 的模块边界。

### 不确定边界

Space 成员角色、owner/admin/member 的具体权限矩阵还需继续查 `modules/space/api*.go` 和 SQL。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：Bot 身份门禁区分 User Bot 与 App Bot，且 App Bot 有 platform/space scope

### 结论

Bot API 鉴权时把身份类型写入上下文：User Bot 来自 robot 表，App Bot 来自 app_bot 表；App Bot 还会写入 scope 与 space_id，用于后续权限判断。

### 证据

- 来源: modules/bot_api/auth.go#L10-L23
- 来源: modules/bot_api/auth.go#L64-L73
- 来源: modules/bot_api/auth.go#L74-L83
- 来源: modules/bot_api/auth.go#L84-L93
- 来源: modules/bot_api/auth.go#L94-L103
- 来源: modules/bot_api/auth.go#L104-L113
- 来源: modules/bot_api/auth.go#L114-L123
- 来源: modules/bot_api/auth.go#L124-L129
- 来源: modules/botidentity/resolver.go#L14-L24

### 适用范围

适用于 bot/agent 身份边界、App Bot 租户范围和 OBO 相关权限判断。

### 不确定边界

App Bot 各路由具体 scope 允许矩阵需继续查 `modules/bot_api/authtree_guard.go` 和相关测试。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：实时系统角色解析以 `user_role:{uid}` 热缓存为第一层，TTL 明确限制为 60 秒

#### 结论

`RoleService` 是 `CacheTokenParser` 的系统角色真源适配器，查询顺序为 Redis `user_role:{uid}` → DB `user.role` → 空角色；空角色用 `-` 作为 negative marker，避免普通用户每次请求打 DB。`RoleCacheTTL` 固定为 60 秒，角色变更路径应调用 `Invalidate` 删除热缓存，使降权/撤权不必等 TTL。

#### 证据

- 来源: modules/user/role_service.go#L11-L21
- 来源: modules/user/role_service.go#L23-L32
- 来源: modules/user/role_service.go#L33-L42
- 来源: modules/user/role_service.go#L43-L50
- 来源: modules/user/role_service.go#L57-L68
- 来源: modules/user/role_service.go#L70-L79
- 来源: modules/user/role_service.go#L80-L89
- 来源: modules/user/role_service.go#L90-L99
- 来源: modules/user/role_service.go#L100-L109
- 来源: modules/user/role_service.go#L110-L119
- 来源: modules/user/role_service.go#L120-L123

#### 适用范围

适用于管理端 admin / superAdmin / 固定管理角色的实时权限判断说明。

#### 不确定边界

所有历史角色写入点是否都已调用 `Invalidate` 需要继续做全仓 role mutation 索引。

### 知识点：管理端 `/me` 返回能力图谱，固定角色只在特定能力上生效

#### 结论

`/v1/manager/me` 只接受 `IsManagerConsoleRole` 允许的角色，并返回后端计算的 `capabilities`。能力图谱区分 superAdmin 专属、admin∪superAdmin、dashboardReader 只读 dashboard、marketAdmin 市场目录面；注释明确普通管理接口仍走 `CheckLoginRole`，固定角色不会自动获得 admin/superAdmin endpoint 权限。

#### 证据

- 来源: pkg/auth/manager_roles.go#L5-L14
- 来源: pkg/auth/manager_roles.go#L15-L24
- 来源: pkg/auth/manager_roles.go#L63-L72
- 来源: pkg/auth/manager_roles.go#L73-L82
- 来源: pkg/auth/manager_roles.go#L83-L90
- 来源: modules/user/api_manager.go#L171-L180
- 来源: modules/user/api_manager.go#L181-L186
- 来源: modules/user/api_manager.go#L188-L197
- 来源: modules/user/api_manager.go#L198-L207
- 来源: modules/user/api_manager.go#L208-L217
- 来源: modules/user/api_manager.go#L218-L227
- 来源: modules/user/api_manager.go#L228-L237
- 来源: modules/user/api_manager.go#L238-L247

#### 适用范围

适用于回答“为什么前端能看到某菜单但接口仍可能 403”“dashboardReader/marketAdmin 权限范围是什么”。

#### 不确定边界

marketplace 侧 `/api/v1/admin/*` 的真实 enforcement 在 `octo-marketplace`，本仓只提供能力声明和契约说明。

### 知识点：固定管理角色的授予/撤销只能由 superAdmin 执行，并使用 CAS + 缓存失效

#### 结论

`dashboardReader` 和 `marketAdmin` 的授予/撤销路由挂在 `/v1/manager/user/*` 下，先过 `AuthMiddleware` 和 UID 共享限流；实际写角色时要求 `CheckLoginRoleIsSuperAdmin`，拒绝非固定角色，按当前角色做 compare-and-set 更新，更新后调用 `roleService.Invalidate`。缓存失效失败会返回错误，避免角色变更已经提交但热缓存仍保留旧权限。

#### 证据

- 来源: modules/user/api_manager.go#L140-L149
- 来源: modules/user/api_manager.go#L150-L155
- 来源: modules/user/api_manager.go#L877-L886
- 来源: modules/user/api_manager.go#L887-L896
- 来源: modules/user/api_manager.go#L897-L906
- 来源: modules/user/api_manager.go#L907-L916
- 来源: modules/user/api_manager.go#L917-L926
- 来源: modules/user/api_manager.go#L927-L933
- 来源: modules/user/api_manager.go#L961-L970

#### 适用范围

适用于管理固定角色生命周期、降权即时性和并发角色变更冲突说明。

#### 不确定边界

普通 admin/superAdmin 的创建、删除、会话吊销完整链路需要继续补充 `addAdminUser` / `deleteAdminUsers` 证据。

### 知识点：空间管理后台按 admin 与 superAdmin 分层，高危跨空间操作收紧到 superAdmin

#### 结论

Space manager 路由全部位于 `/v1/manager` 且先经过 `AuthMiddleware`；模块内统一封装 `requireAdmin` 和 `requireSuperAdmin`。只读/低风险管理操作使用 `CheckLoginRole`，而强制解散、封禁/解禁、强制移除成员、修改成员角色等高危跨空间操作使用 `CheckLoginRoleIsSuperAdmin`，并统一返回通用 403 以避免暴露所需角色细节。

#### 证据

- 来源: modules/space/api_manager.go#L78-L87
- 来源: modules/space/api_manager.go#L88-L97
- 来源: modules/space/api_manager.go#L98-L107
- 来源: modules/space/api_manager.go#L108-L113
- 来源: modules/space/api_manager.go#L159-L168
- 来源: modules/space/api_manager.go#L169-L178
- 来源: modules/space/api_manager.go#L179-L180
- 来源: modules/space/api_manager.go#L229-L238
- 来源: modules/space/api_manager.go#L239-L248
- 来源: modules/space/api_manager.go#L249-L258
- 来源: modules/space/api_manager.go#L259-L268
- 来源: modules/space/api_manager.go#L269-L278
- 来源: modules/space/api_manager.go#L279-L288
- 来源: modules/space/api_manager.go#L289-L298
- 来源: modules/space/api_manager.go#L299-L308
- 来源: modules/space/api_manager.go#L309-L318
- 来源: modules/space/api_manager.go#L319-L327

#### 适用范围

适用于解释 Space 管理面权限层级和为什么部分空间操作 admin 可读写、部分必须 superAdmin。

#### 不确定边界

普通用户在自己 Space 内的 owner/admin/member 权限矩阵，需要下一阶段继续深挖 `modules/space/api.go`、`db.go` 与成员角色测试。

### 知识点：API Key 身份验证绑定用户与 Space，并要求 key、用户、Space membership 都处于有效状态

#### 结论

`/v1/auth/verify-api-key` 只接受 `user_api_key` 中 `space_id!=''`、`status=1` 且 `client_id='botfather'` 的 native octo key；随后通过 `space_member`、`space`、`user` 三表校验 key owner 仍是活跃用户且仍属于活跃 Space。带 `?include=context` 时只返回绑定 Space 下 owned bots，查询失败时给空列表让下游授权 fail-closed。

#### 证据

- 来源: modules/user/api.go#L5046-L5055
- 来源: modules/user/api.go#L5056-L5065
- 来源: modules/user/api.go#L5066-L5075
- 来源: modules/user/api.go#L5076-L5085
- 来源: modules/user/api.go#L5088-L5097
- 来源: modules/user/api.go#L5098-L5107
- 来源: modules/user/api.go#L5108-L5116
- 来源: modules/user/api.go#L5123-L5132
- 来源: modules/user/api.go#L5133-L5141

#### 适用范围

适用于 daemon / fleet / matter 使用 `uk_*` API key 做身份翻译与租户边界校验的场景。

#### 不确定边界

API key 的创建、撤销和密钥哈希存储在 botfather 相关文件，需要后续单独补充。

### 知识点：App Bot 鉴权不仅看 token，还看发布状态、scope 与 space_id

#### 结论

Bot API 通过 `Authorization: Bearer` 提取 token，`app_` 前缀走 App Bot，其他走 User Bot。App Bot 优先查共享 registry/cache，miss 时查 DB；DB 命中后仍要求 `status=1` 才能继续，并把 `bot_kind`、`app_bot_scope`、`app_bot_space_id` 写入上下文。scope 为 `space` 时，后续路由可据此做 Space 级授权。

#### 证据

- 来源: modules/bot_api/auth.go#L10-L19
- 来源: modules/bot_api/auth.go#L20-L29
- 来源: modules/bot_api/auth.go#L30-L39
- 来源: modules/bot_api/auth.go#L40-L42
- 来源: modules/bot_api/auth.go#L64-L73
- 来源: modules/bot_api/auth.go#L74-L83
- 来源: modules/bot_api/auth.go#L84-L93
- 来源: modules/bot_api/auth.go#L94-L103
- 来源: modules/bot_api/auth.go#L104-L113
- 来源: modules/bot_api/auth.go#L114-L123
- 来源: modules/bot_api/auth.go#L124-L129
- 来源: modules/bot_api/auth.go#L143-L150
- 来源: modules/botidentity/resolver.go#L1-L10
- 来源: modules/botidentity/resolver.go#L11-L20
- 来源: modules/botidentity/resolver.go#L21-L30
- 来源: modules/botidentity/resolver.go#L31-L40

#### 适用范围

适用于区分 User Bot、App Bot、平台级 App Bot 与 Space 级 App Bot。

#### 不确定边界

App Bot token 签发和 registry 源数据维护需继续查 `modules/bot_api/register.go` 与 `modules/bot_api/registry*.go`。

### 知识点：Bot authtree 复用路由额外补 App Bot scope guard，Space App Bot 读 DM 也要校验对端仍在绑定 Space

#### 结论

`appBotScopeGuard` 专门保护 bot 树复用路由：带 `group_no` 的群/子区形状路由对 App Bot 一律拒绝；带 `peer_uid` 的 DM 单条读路由，如果是 `scope=space` 的 App Bot，则必须确认对端仍是该 App Bot 绑定 Space 的成员，否则返回 not-found，避免通过好友关系绕过 Space scope 读取历史 DM。

#### 证据

- 来源: modules/bot_api/authtree_guard.go#L17-L26
- 来源: modules/bot_api/authtree_guard.go#L27-L36
- 来源: modules/bot_api/authtree_guard.go#L37-L46
- 来源: modules/bot_api/authtree_guard.go#L47-L56
- 来源: modules/bot_api/authtree_guard.go#L57-L66
- 来源: modules/bot_api/authtree_guard.go#L67-L76
- 来源: modules/bot_api/authtree_guard.go#L77-L86
- 来源: modules/bot_api/authtree_guard.go#L87-L96
- 来源: modules/bot_api/authtree_guard.go#L97-L99

#### 适用范围

适用于回答 App Bot 是否能访问群消息、Space App Bot 是否能跨 Space 读 DM 历史。

#### 不确定边界

发送侧完整权限矩阵还需继续补查 `modules/bot_api/send.go` 与相关 permission tests。

### 知识点：OBO 发送/搜索授权是 grant、scope 与 grantor 当前 channel 读权限的组合判断

#### 结论

`checkOBO` 的授权问题是“bot B 是否允许在某 channel 中代表 grantor G”；它要求 active 且 global_enabled 的 grant 行、显式 scope enabled 或满足 implicit scope 规则，并在热路径重新检查 grantor 当前是否仍可读该 channel。`SearchOBOAllowed` 复用同一套逻辑，把未授权折叠为 `(false, nil)`，让搜索层按不存在处理，基础设施错误则传播以 fail-closed。

#### 证据

- 来源: modules/bot_api/obo_check.go#L20-L29
- 来源: modules/bot_api/obo_check.go#L30-L39
- 来源: modules/bot_api/obo_check.go#L40-L49
- 来源: modules/bot_api/obo_check.go#L50-L59
- 来源: modules/bot_api/obo_check.go#L60-L67
- 来源: modules/bot_api/obo_check.go#L77-L87
- 来源: modules/bot_api/obo_check.go#L90-L99
- 来源: modules/bot_api/obo_check.go#L100-L109
- 来源: modules/bot_api/obo_check.go#L110-L119
- 来源: modules/bot_api/obo_check.go#L120-L127
- 来源: modules/bot_api/obo_check.go#L188-L197
- 来源: modules/bot_api/obo_check.go#L198-L207
- 来源: modules/bot_api/obo_check.go#L208-L217
- 来源: modules/bot_api/obo_check.go#L218-L227
- 来源: modules/bot_api/obo_check.go#L228-L237
- 来源: modules/bot_api/obo_check.go#L238-L239

#### 适用范围

适用于 Persona Clone / as-user(OBO) send 与 search 的授权解释。

#### 不确定边界

grant/scope 的创建、撤销 API 和数据库约束需继续查 `obo_api.go`、`obo_db.go` 与 SQL migration。

### 知识点：RBAC 与频道 ACL 是两层授权，不存在一个全局“万能 RBAC”替代所有资源门禁

#### 结论

管理端角色是固定角色/能力图谱模型：`admin`、`superAdmin`、`dashboardReader`、`marketAdmin` 等角色只在声明的能力面生效，窄角色不会自动获得全部 admin endpoint 权限。频道和会话访问则由资源 ACL 负责，例如 OBO 会在热路径检查 grant、scope 与授权人当前 channel 读权限；Thread/群消息等能力还会结合群成员、父群关系、App Bot scope guard 判断。考试回答“谁能做什么”时必须先区分管理面 RBAC、Space/频道 ACL、Bot/App Bot scope、OBO grant 四层。

#### 证据

- 来源: pkg/auth/manager_roles.go#L5-L17
- 来源: pkg/auth/manager_roles.go#L63-L70
- 来源: pkg/auth/manager_roles.go#L72-L80
- 来源: pkg/auth/manager_roles.go#L83-L90
- 来源: modules/bot_api/obo_check.go#L20-L29
- 来源: modules/bot_api/obo_check.go#L30-L39
- 来源: modules/bot_api/obo_check.go#L40-L49
- 来源: modules/bot_api/obo_check.go#L188-L197
- 来源: modules/bot_api/authtree_guard.go#L17-L26
- 来源: modules/bot_api/authtree_guard.go#L27-L36
- 来源: modules/bot_api/authtree_guard.go#L77-L86
- 来源: modules/bot_api/authtree_guard.go#L87-L99

#### 适用范围

适用于回答 org/RBAC、频道 ACL、bot/agent 身份门禁、OBO 代用户操作边界。

#### 不确定边界

如果考官追问其它服务（如 marketplace）最终是否接受某角色，需要到对应服务仓库核验；octo-server 只能确认自身能力图谱与 token verify 输出。

### 知识点：Project 成员、Group admission 与 AI Team 都新增了资源级授权边界

#### 结论

Project 不是单纯 Space 列表能力：`/v1/projects/:project_id/*` 先经 `projectMiddleware` 解析项目成员角色，项目成员缓存会把 `removing=1` 的席位视为非成员；群绑定 Project 后，所有可写入 group_member 的路径必须经过统一 admission gate，条件是 active Space member 且如果绑定 project，则也是 active project member，系统 bot 另有豁免。AI Team 的 agent/session 操作要求人和 bot 都在同一个 Space，且 bot 必须归该用户所有、状态有效；AI session container 的保护不受 `DM_AI_TEAM_ON` 关闭影响，避免回滚时放开已创建私有容器。

#### 证据

- 来源: modules/project/api.go#L185-L193
- 来源: modules/project/api.go#L195-L200
- 来源: modules/project/middleware.go#L147-L158
- 来源: modules/group/admission.go#L142-L149
- 来源: modules/group/admission.go#L150-L157
- 来源: modules/group/admission.go#L175-L179
- 来源: modules/ai_team/service.go#L37-L47
- 来源: modules/ai_team/service.go#L57-L66
- 来源: modules/ai_team/service.go#L67-L73
- 来源: pkg/aiteam/aiteam.go#L20-L26
- 来源: pkg/aiteam/aiteam.go#L38-L45

#### 适用范围

适用于回答 Project 群、项目成员、AI Team 私有会话容器、Space 成员移除/项目成员移除后的权限边界。

#### 不确定边界

群 admission 的所有入口清单在 `modules/group/admission.go` 中维护；如果未来新增写 group_member 的路径，必须看 guard test 是否覆盖。

## V3 增量补强（2026-09-09，目标仓 98d20920）

### 知识点：项目群列表的访问控制是“只返回调用者自己的项目群”，不是额外角色门禁

#### 结论

`GET /v1/projects/:project_id/groups` 挂在 `AuthMiddleware → SharedUIDRateLimiter → projectMiddleware` 后；handler 注释明确该接口返回调用者在该项目内“自己的 live groups”，不再额外做项目角色门禁。原因是返回集合本身由调用者群成员关系限定，Space admin 未加入项目时正确结果是空列表，而不是 403，以免把“是否项目成员”变成额外可观察信息。

#### 证据

- 来源: modules/project/api.go#L186-L198
- 来源: modules/project/api_group.go#L8-L20
- 来源: modules/project/api_group.go#L22-L24
- 来源: modules/project/api_group.go#L54-L67

#### 适用范围

适用于解释 Project 不是新的读安全边界、项目维度只是过滤维度，以及项目群列表为什么不按 Space admin 额外放宽。

### 知识点：全员群保护只拦 HTTP 人工操作，服务层级联与系统维护路径保持可用

#### 结论

项目全员群的成员集合必须等于项目活跃成员集合。为避免人工群操作破坏该不变量，HTTP handler 层会拒绝解散、退出、移除成员、群主转让、黑名单五类动作；但保护不下沉到服务层，因为项目级联、Space 移除级联、bot 删除和全员群 owner 同步都要复用服务层原语维持 I2/I4。

#### 证据

- 来源: modules/group/all_member_group_guard.go#L53-L67
- 来源: modules/group/all_member_group_guard.go#L74-L88
- 来源: pkg/errcode/group.go#L71-L80
- 来源: pkg/errcode/group.go#L82-L88
- 来源: pkg/errcode/group.go#L99-L107

#### 适用范围

适用于回答“为什么全员群不能手动踢人/退群/转让/拉黑，但系统级联还能改群成员”。


### 知识点：Project 协作角色是“展示/分工标签”，写入权限与成员有效性仍由项目角色和 Space seat 决定

#### 结论

协作角色接口新增在 `/v1/projects/:project_id` 下：列表要求调用者可看项目成员；创建、重命名、删除自定义协作角色只允许项目 owner；给成员替换协作角色要求调用者具备成员管理权限。绑定目标必须是该项目 active 且未 removing 的真人成员，bot 目标会被拒绝；协作角色本身不承载项目权限，项目权限仍由 owner/admin/common 角色控制。

#### 证据

- 来源: modules/project/api.go#L211-L215
- 来源: modules/project/api_collaboration_role.go#L23-L34
- 来源: modules/project/api_collaboration_role.go#L47-L60
- 来源: modules/project/api_collaboration_role.go#L154-L167
- 来源: modules/project/service_collaboration_role.go#L345-L359
- 来源: modules/project/service_collaboration_role.go#L366-L379
- 来源: modules/project/service_collaboration_role.go#L366-L379

#### 适用范围

适用于回答“协作角色能不能授权”“谁能维护协作角色”“能否给机器人打协作角色标签”。
#### 最后验证

- Commit: c16f8c1858596011faa7e2dcdbc14677fa479871
- Time: 2026-09-09T15:35:00+08:00
