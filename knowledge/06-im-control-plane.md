# 06 — IM 控制面

## 知识点：octo-server 连接 WuKongIM 作为控制面，不是完整 IM 内核本身

### 结论

配置文件包含 `wukongIM.apiURL` 与 `managerToken`，表明 octo-server 需要调用 WuKongIM 管理 API；群、用户、消息模块通过 `IMDatasource` 为 IM 侧提供频道信息、订阅者、黑白名单等控制面数据。

### 证据

- 来源: configs/tsdd.yaml#L21-L24
- 来源: modules/group/1module.go#L50-L105
- 来源: modules/user/1module.go#L40-L54

### 适用范围

适用于解释 octo-server 与 WuKongIM 的分工：WuKongIM 负责实时消息内核，octo-server 负责用户/群/频道/Bot/权限等控制面能力。

### 不确定边界

WebSocket 握手的最终实现很可能在 `octo-lib` 或 WuKongIM 侧；本仓当前证据不能单独证明完整握手流程。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：群模块向 IM 提供群频道信息、订阅者、黑名单、白名单

### 结论

`group` 模块注册 `IMDatasource`，当 channelType 是群时，提供 `ChannelInfo`、`Subscribers`、`Blacklist`、`Whitelist`；其中订阅者口径排除黑名单成员，以避免拉黑后仍被 WuKongIM 重载订阅加回。

### 证据

- 来源: modules/group/1module.go#L43-L105
- 来源: modules/group/1module.go#L76-L87

### 适用范围

适用于群消息实时推送、群禁言/黑名单、WuKongIM 订阅数据来源说明。

### 不确定边界

具体 IM HTTP 回调入口需继续查 octo-lib register/IMDatasource 消费方。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：消息模块承担 message / conversation / sidebar，并作为跨模块授权注入点

### 结论

`modules/message/1module.go` 注册 `message`、`conversation`、manager、`conversation_ext_thread_auth`、`sidebar` 等模块；其中会把 ThreadAuthChecker、ThreadEnumerator、ChannelAuthChecker、ActiveMemberFilter 等注入 conversation_ext。

### 证据

- 来源: modules/message/1module.go#L26-L57
- 来源: modules/message/1module.go#L59-L103

### 适用范围

适用于消息、会话、侧边栏、子区 follow 和跨模块授权说明。

### 不确定边界

具体消息收发 API、卡片 action、message search 需继续逐文件补充。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：`/v1/datasource` 是 IM datasource 聚合入口，按模块声明能力分发

#### 结论

`webhook` 模块暴露 `/v1/datasource`，根据 `CMD` 分流到 `getChannelInfo`、`getSubscribers`、`getBlacklist`、`getWhitelist`、`getSystemUIDs`。这些方法遍历 `register.GetModules(ctx)`，只调用声明了相应 `IMDatasourceType*` 能力的模块；模块返回 `ErrDatasourceNotProcess` 时继续交给下一个模块，最终为空则返回空 map 或空列表。

#### 证据

- 来源: modules/webhook/api.go#L150-L156
- 来源: modules/webhook/api_datasource.go#L34-L46
- 来源: modules/webhook/api_datasource.go#L61-L81
- 来源: modules/webhook/api_datasource.go#L90-L111
- 来源: modules/webhook/api_datasource.go#L177-L222

#### 适用范围

适用于回答“WuKongIM 从哪里取频道资料/订阅/黑白名单/系统账号”以及排查 datasource 未命中的问题。

#### 不确定边界

`IMDatasource` 类型定义来自依赖 `github.com/Mininglamp-OSS/octo-lib/pkg/register`，不在本仓源码内；本仓只能核验各业务模块如何注册和消费。

### 知识点：Person DM 黑名单在 datasource 层特殊处理，Bot 好友关系也会影响 DM 可达性

#### 结论

`getSubscribers` 对 Person 频道直接返回空订阅列表；`getBlacklist` 对 fake Person channel 先按 `uid1@uid2` 解析并检查双向黑名单，若存在黑名单关系则把双方返回给 IM。若 DM 一方是 Bot 且另一方不是其好友，也会把非好友用户作为黑名单返回，从 IM 层阻断发送/可达性。

#### 证据

- 来源: modules/webhook/api_datasource.go#L90-L111
- 来源: modules/webhook/api_datasource.go#L121-L157

#### 适用范围

适用于解释 DM 频道为什么没有 subscribers 数据、为什么拉黑或未加 Bot 好友会导致私聊不可达。

#### 不确定边界

DM 的完整好友关系、拉黑、同 Space 门禁还分布在 `modules/user`、`modules/message` 与 `modules/messages_search`，本条只说明 datasource 入口行为。

### 知识点：群拉黑不只写 IM 黑名单，还会主动摘除父群与子区订阅

#### 结论

群黑名单接口在拉黑分支先调用 `setGroupBlacklist`，该 helper 对应 `IMBlacklistAdd`；随后逐个用户调用 `removeUserFromGroupThreads` 摘除子区订阅，并对父群调用 `IMRemoveSubscriber`。解除拉黑分支会调用 `IMBlacklistRemove`，并对未禁言成员恢复父群 `IMAddSubscriber`，再调用 `addUsersToGroupThreads` 恢复子区订阅。代码注释明确说明：仅靠 IM blacklist 只能挡“发送”，不能挡“接收”。

#### 证据

- 来源: modules/group/api.go#L3764-L3784
- 来源: modules/group/api.go#L3802-L3816
- 来源: modules/group/api.go#L4078-L4098

#### 适用范围

适用于群黑名单、越权读、实时消息订阅异常、拉黑/解除拉黑后是否还能收到群或子区消息的排查。

#### 不确定边界

`removeUserFromGroupThreads` / `addUsersToGroupThreads` 的内部实现、失败补偿与重试策略可在群成员专题继续展开；本条只确认黑名单主流程已触发父群和子区订阅调整。

### 知识点：父群 IM 订阅数据源只返回活跃成员，避免黑名单用户被缓存重加

#### 结论

群 service 提供 `GetSubscribableMemberUIDs`，注释明确其语义是 `status=normal AND is_deleted=0`，专用于父群/子区 IM Subscribers 数据源，目的是排除黑名单成员，避免 WuKongIM 重载订阅时把黑名单用户加回订阅列表。

#### 证据

- 来源: modules/group/service.go#L561-L580
- 来源: modules/group/1module.go#L76-L90

#### 适用范围

适用于解释“数据库里用户仍是群成员但不应收到实时消息”的场景：订阅口径是活跃成员，不是所有未删除或历史成员。

#### 不确定边界

具体 SQL 条件在 `modules/group/db.go`，本条基于 service 注释和 datasource 调用链确认业务语义。

### 知识点：Thread 运行由 `DM_THREAD_ON` 控制，但 schema 迁移始终注册

#### 结论

`thread` 模块初始化时读取 `DM_THREAD_ON`，只有值为 `true` 或 `1` 时才启用 API surface 与 archive worker；否则只返回带 `SQLDir` 的模块。注释说明这样做是为了让开启/关闭 Thread 功能的部署具备一致 DB layout，避免后续切换开关时出现表已存在或缺表问题。

#### 证据

- 来源: modules/thread/1module.go#L24-L43
- 来源: modules/thread/api.go#L179-L205
- 来源: modules/message/api_message_get.go#L20-L27

#### 适用范围

适用于回答“为什么 thread 表存在但接口不可用”“为什么群消息下的 thread message 路由受开关控制”。

#### 不确定边界

部署环境实际是否开启，需要查看运行时环境变量；源码只能确认开关规则。

### 知识点：Thread 频道 datasource 继承父群成员、黑名单、禁言与解散状态

#### 结论

Thread 只处理 `ChannelTypeCommunityTopic`，且要求 channelID 能解析、thread 存在；返回能力包括 ChannelInfo、Subscribers、Blacklist、Whitelist。ChannelInfo 会把已删除 thread 标记为 `ban=1`，并查询父群：父群解散时给 thread 频道返回 `disband=1`。Subscribers 复用父群 `GetSubscribableMemberUIDs`，Blacklist 继承父群黑名单，Whitelist 在父群禁言时返回父群管理员列表。

#### 证据

- 来源: modules/thread/1module.go#L73-L96
- 来源: modules/thread/1module.go#L115-L170
- 来源: modules/thread/1module.go#L175-L197

#### 适用范围

适用于子区消息发送/接收权限、父群解散对子区影响、父群禁言对子区白名单继承的排查。

#### 不确定边界

“归档子区允许发消息，发消息后自动解档”的完整逻辑不在 datasource 片段内，需要继续查 `modules/thread/service.go` 和消息发送路径。

### 知识点：历史消息同步对群、子区、DM 分别有应用层读权限过滤

#### 结论

`/v1/message/channel/sync` 对群频道先校验调用者是群成员，不是成员时返回空消息；对子区频道解析父群并校验调用者是父群活跃成员，解析失败或非活跃成员同样返回空消息。真正拉取历史由 `IMSyncChannelMessage` 完成。Person DM 是跨 Space 共享物理频道，拉取后会按 `SpaceMiddleware` 写入的已校验 spaceID 和 `personSpaceAllows` 做消息级过滤。

#### 证据

- 来源: modules/message/api.go#L1442-L1507
- 来源: modules/message/api.go#L1550-L1567
- 来源: modules/message/api.go#L353-L387

#### 适用范围

适用于历史消息越权读、子区被拉黑成员读取、DM 跨 Space 消息泄漏排查。

#### 不确定边界

群频道此处使用 `ExistMember`，子区使用 `ExistMemberActive`；二者差异是源码事实，具体产品策略是否要统一需产品/安全评审决定。

### 知识点：单条 DM 消息直读补齐了 fakeChannelID、P2P 门禁和 Space 隔离

#### 结论

`/v1/messages/person/:peer_uid/:message_id` 会拒绝空 peer、自己给自己、含 `@` 的 peer_uid 和非法 message_id；随后执行 P2P 访问检查，要求 same-space 或好友关系满足且双向 blacklist 不命中。读取时用 `GetFakeChannelIDWith(peerUID, loginUID)` 派生物理频道；如果请求声明了 Space，则再按消息 payload 的 `space_id` 与 `personSpaceAllows` 判断，不通过时用 not_found 归并防枚举。

#### 证据

- 来源: modules/message/api.go#L392-L403
- 来源: modules/message/api_message_get.go#L197-L238
- 来源: modules/message/api_message_get.go#L243-L275

#### 适用范围

适用于回答“为什么 DM 同步能看到/直读看不到”“为什么不存在和无权限都是 not_found”“为什么 peer_uid 不能包含 @”。

#### 不确定边界

`checkPersonDMAccess` 的完整四层门禁需要结合 `modules/message/api_message_get.go` 后续实现和 `modules/messages_search/authz.go` 继续核验。

### 知识点：Follow/Sidebar 是 IM 之外的会话可见性控制层，使用 SpaceMiddleware 和注入式授权

#### 结论

`conversation_ext` 的 `/v1/follow/*` 路由全部挂 `AuthMiddleware` 与 `SpaceMiddleware`，覆盖 DM 关注/取消、群取消/重新关注、Thread 关注/取消、排序。服务层定义 `ThreadAuthChecker`、`ChannelAuthChecker`、`DefaultFollowedGroupGuard`、`ActiveMemberFilter` 四类窄接口，由 `message` 模块注入实现，用来避免 conversation_ext 直接 import group/thread，同时把成员资格、Space 可见性、默认关注和活跃成员过滤纳入写路径。

#### 证据

- 来源: modules/conversation_ext/1module.go#L57-L70
- 来源: modules/conversation_ext/service.go#L51-L79
- 来源: modules/conversation_ext/service.go#L97-L115
- 来源: modules/message/1module.go#L73-L103

#### 适用范围

适用于 sidebar/follow 漏出不可见群或子区、跨 Space group_setting 残留、循环依赖设计解释。

#### 不确定边界

`sidebar` 读侧聚合和排序细节在 `modules/message/api_sidebar.go`，本条只覆盖 follow 写侧与注入授权。

### 知识点：FollowChannel 和 OnThreadCreated 都按活跃父群成员过滤子区 ext 物化

#### 结论

FollowChannel 在写 `auto_follow_threads=1` 和清除 `group_unfollowed` 前先调用 `AuthorizeChannelFollow` 校验成员与 Space 可见性；随后子区 ext 物化会用 `ActiveMemberFilter` 过滤，避免被拉黑成员重新拿到既有子区元数据。新建 Thread 时，`thread.Service.CreateThread` 在客户端可观察消息发送前调用 `conversation_ext.OnThreadCreated` 做 fanout；`OnThreadCreated` 先查询所有对父群开启 `auto_follow_threads=1` 的目标，再按活跃父群成员过滤，避免被拉黑用户收到新子区 ext 行或创建通知。

#### 证据

- 来源: modules/conversation_ext/service.go#L414-L455
- 来源: modules/thread/service.go#L324-L365
- 来源: modules/conversation_ext/service.go#L653-L700

#### 适用范围

适用于解释子区为何出现在/不出现在侧边栏、拉黑后子区元数据泄漏防护、Thread 创建后的 fanout 时序。

#### 不确定边界

`OnThreadCreated` 失败是 best-effort，不回滚 Thread 创建；缺失行可能由后续 FollowChannel/refollow 补齐，不能把 fanout 失败描述为创建失败。

### 知识点：FollowThread 必须通过 thread 授权，避免任意合法 channelID 写入不可见子区 ext 行

#### 结论

`FollowThread` 会解析 threadChannelID 为 groupNo/shortID，并在写 DB 前调用注入的 `ThreadAuthChecker.AuthorizeThreadFollow`。接口注释说明，如果没有该检查，任意语法合法的 channelID 都可能写入 ext 行并在后续 sidebar 中暴露不可见 thread；授权失败返回 `ErrThreadForbidden`，handler 转成 403。

#### 证据

- 来源: modules/conversation_ext/service.go#L940-L978
- 来源: modules/conversation_ext/api.go#L235-L260
- 来源: modules/message/1module.go#L134-L179

#### 适用范围

适用于子区关注接口、sidebar 元数据越权、Thread channelID 合法但不可见的排查。

#### 不确定边界

`AuthorizeThreadFollow` 内部还复用父群 Space 可见性规则；更细的 internal/external/legacy Space 判定已在 `knowledge/02-authorization-model.md` 中覆盖。
