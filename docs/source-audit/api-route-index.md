# API 路由索引（静态扫描）

- Target commit: `49dc9fd97b49c6c9bad9a0abaefb0b48241e9601`
- Route count: 625
- 说明：本索引用 Go 源码静态扫描生成，已排除 `_test.go`。复杂动态路由仍以对应源码行为准。

## agentmailgateway

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `Any` | `/*path` | 来源: modules/agentmailgateway/gateway.go#L195-L195 | group RouterGroup |

## app_bot

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `Any` | `recover` | 来源: modules/app_bot/app_bot.go#L107-L107 | group zap |
| `GET` | `/v1/admin/app_bot/:id` | 来源: modules/app_bot/app_bot.go#L123-L123 | group adminAPI declared L119 |
| `PUT` | `/v1/admin/app_bot/:id` | 来源: modules/app_bot/app_bot.go#L124-L124 | group adminAPI declared L119 |
| `DELETE` | `/v1/admin/app_bot/:id` | 来源: modules/app_bot/app_bot.go#L125-L125 | group adminAPI declared L119 |
| `POST` | `/v1/admin/app_bot/:id/token` | 来源: modules/app_bot/app_bot.go#L126-L126 | group adminAPI declared L119 |
| `POST` | `/v1/admin/app_bot/:id/token/reveal` | 来源: modules/app_bot/app_bot.go#L127-L127 | group adminAPI declared L119 |
| `POST` | `/v1/admin/app_bot/:id/publish` | 来源: modules/app_bot/app_bot.go#L128-L128 | group adminAPI declared L119 |
| `POST` | `/v1/admin/app_bot/:id/unpublish` | 来源: modules/app_bot/app_bot.go#L129-L129 | group adminAPI declared L119 |
| `GET` | `/v1/space/:space_id/app_bot/:id` | 来源: modules/app_bot/app_bot.go#L137-L137 | group spaceAPI declared L133 |
| `PUT` | `/v1/space/:space_id/app_bot/:id` | 来源: modules/app_bot/app_bot.go#L138-L138 | group spaceAPI declared L133 |
| `DELETE` | `/v1/space/:space_id/app_bot/:id` | 来源: modules/app_bot/app_bot.go#L139-L139 | group spaceAPI declared L133 |
| `POST` | `/v1/space/:space_id/app_bot/:id/token` | 来源: modules/app_bot/app_bot.go#L140-L140 | group spaceAPI declared L133 |
| `POST` | `/v1/space/:space_id/app_bot/:id/token/reveal` | 来源: modules/app_bot/app_bot.go#L141-L141 | group spaceAPI declared L133 |
| `POST` | `/v1/space/:space_id/app_bot/:id/publish` | 来源: modules/app_bot/app_bot.go#L142-L142 | group spaceAPI declared L133 |
| `POST` | `/v1/space/:space_id/app_bot/:id/unpublish` | 来源: modules/app_bot/app_bot.go#L143-L143 | group spaceAPI declared L133 |
| `GET` | `/v1/app_bot/available` | 来源: modules/app_bot/app_bot.go#L147-L147 | group r |
| `POST` | `/v1/app_bot/apply` | 来源: modules/app_bot/app_bot.go#L152-L152 | group applyAPI declared L150 |
| `Any` | `error` | 来源: modules/app_bot/app_bot.go#L397-L397 | group zap |
| `Any` | `error` | 来源: modules/app_bot/app_bot.go#L763-L763 | group zap |

## backup

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/manager/backup/config` | 来源: modules/backup/api_manager.go#L49-L49 | group auth declared L46 |
| `PUT` | `/v1/manager/backup/config` | 来源: modules/backup/api_manager.go#L50-L50 | group auth declared L46 |
| `POST` | `/v1/manager/backup/config/test` | 来源: modules/backup/api_manager.go#L51-L51 | group auth declared L46 |
| `POST` | `/v1/manager/backup/trigger` | 来源: modules/backup/api_manager.go#L54-L54 | group auth declared L46 |
| `GET` | `/v1/manager/backup/history` | 来源: modules/backup/api_manager.go#L55-L55 | group auth declared L46 |
| `DELETE` | `/v1/manager/backup/history/:id` | 来源: modules/backup/api_manager.go#L56-L56 | group auth declared L46 |
| `GET` | `/v1/manager/backup/history/:id/download` | 来源: modules/backup/api_manager.go#L57-L57 | group auth declared L46 |
| `GET` | `/v1/manager/backup/status` | 来源: modules/backup/api_manager.go#L60-L60 | group auth declared L46 |

## base

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/apps/:app_id` | 来源: modules/base/app/api.go#L22-L22 | group r |

## bot_api

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `Any` | `/v1/bot/register` | 来源: modules/bot_api/bot_api.go#L331-L331 | group r |
| `Any` | `/v1/bot/heartbeat` | 来源: modules/bot_api/bot_api.go#L365-L365 | group r |
| `POST` | `/v1/bot/sendMessage` | 来源: modules/bot_api/bot_api.go#L410-L410 | group botAPI declared L400 |
| `POST` | `/v1/bot/typing` | 来源: modules/bot_api/bot_api.go#L411-L411 | group botAPI declared L400 |
| `POST` | `/v1/bot/readReceipt` | 来源: modules/bot_api/bot_api.go#L412-L412 | group botAPI declared L400 |
| `POST` | `/v1/bot/events` | 来源: modules/bot_api/bot_api.go#L413-L413 | group botAPI declared L400 |
| `POST` | `/v1/bot/events/:event_id/ack` | 来源: modules/bot_api/bot_api.go#L414-L414 | group botAPI declared L400 |
| `POST` | `/v1/bot/messages/sync` | 来源: modules/bot_api/bot_api.go#L415-L415 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups` | 来源: modules/bot_api/bot_api.go#L416-L416 | group botAPI declared L400 |
| `GET` | `/v1/bot/resolve/targets` | 来源: modules/bot_api/bot_api.go#L417-L417 | group botAPI declared L400 |
| `POST` | `/v1/bot/users/batch` | 来源: modules/bot_api/bot_api.go#L422-L422 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups/:group_no` | 来源: modules/bot_api/bot_api.go#L423-L423 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups/:group_no/members` | 来源: modules/bot_api/bot_api.go#L424-L424 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups/:group_no/mention_pref` | 来源: modules/bot_api/bot_api.go#L425-L425 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups/:group_no/md` | 来源: modules/bot_api/bot_api.go#L426-L426 | group botAPI declared L400 |
| `PUT` | `/v1/bot/groups/:group_no/md` | 来源: modules/bot_api/bot_api.go#L427-L427 | group botAPI declared L400 |
| `GET` | `/v1/bot/space/members` | 来源: modules/bot_api/bot_api.go#L428-L428 | group botAPI declared L400 |
| `GET` | `/v1/bot/space/principals/:uid` | 来源: modules/bot_api/bot_api.go#L429-L429 | group botAPI declared L400 |
| `POST` | `/v1/bot/createGroup` | 来源: modules/bot_api/bot_api.go#L430-L430 | group botAPI declared L400 |
| `PUT` | `/v1/bot/groups/:group_no/info` | 来源: modules/bot_api/bot_api.go#L431-L431 | group botAPI declared L400 |
| `POST` | `/v1/bot/groups/:group_no/members/add` | 来源: modules/bot_api/bot_api.go#L432-L432 | group botAPI declared L400 |
| `POST` | `/v1/bot/groups/:group_no/members/remove` | 来源: modules/bot_api/bot_api.go#L433-L433 | group botAPI declared L400 |
| `POST` | `/v1/bot/groups/:group_no/threads` | 来源: modules/bot_api/bot_api.go#L435-L435 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups/:group_no/threads` | 来源: modules/bot_api/bot_api.go#L436-L436 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups/:group_no/threads/:short_id` | 来源: modules/bot_api/bot_api.go#L437-L437 | group botAPI declared L400 |
| `DELETE` | `/v1/bot/groups/:group_no/threads/:short_id` | 来源: modules/bot_api/bot_api.go#L438-L438 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups/:group_no/threads/:short_id/members` | 来源: modules/bot_api/bot_api.go#L439-L439 | group botAPI declared L400 |
| `POST` | `/v1/bot/groups/:group_no/threads/:short_id/join` | 来源: modules/bot_api/bot_api.go#L440-L440 | group botAPI declared L400 |
| `POST` | `/v1/bot/groups/:group_no/threads/:short_id/leave` | 来源: modules/bot_api/bot_api.go#L441-L441 | group botAPI declared L400 |
| `GET` | `/v1/bot/groups/:group_no/threads/:short_id/md` | 来源: modules/bot_api/bot_api.go#L442-L442 | group botAPI declared L400 |
| `PUT` | `/v1/bot/groups/:group_no/threads/:short_id/md` | 来源: modules/bot_api/bot_api.go#L443-L443 | group botAPI declared L400 |
| `POST` | `/v1/bot/setCommands` | 来源: modules/bot_api/bot_api.go#L444-L444 | group botAPI declared L400 |
| `POST` | `/v1/bot/file/upload` | 来源: modules/bot_api/bot_api.go#L446-L446 | group botAPI declared L400 |
| `POST` | `/v1/bot/upload` | 来源: modules/bot_api/bot_api.go#L447-L447 | group botAPI declared L400 |
| `GET` | `/v1/bot/file/download/*path` | 来源: modules/bot_api/bot_api.go#L448-L448 | group botAPI declared L400 |
| `GET` | `/v1/bot/upload/credentials` | 来源: modules/bot_api/bot_api.go#L449-L449 | group botAPI declared L400 |
| `GET` | `/v1/bot/upload/presigned` | 来源: modules/bot_api/bot_api.go#L450-L450 | group botAPI declared L400 |
| `POST` | `/v1/bot/message/edit` | 来源: modules/bot_api/bot_api.go#L451-L451 | group botAPI declared L400 |
| `POST` | `/v1/bot/message/card/revisions/clear` | 来源: modules/bot_api/bot_api.go#L452-L452 | group botAPI declared L400 |
| `GET` | `/v1/bot/card/profile` | 来源: modules/bot_api/bot_api.go#L453-L453 | group botAPI declared L400 |
| `GET` | `/v1/bot/user/info` | 来源: modules/bot_api/bot_api.go#L454-L454 | group botAPI declared L400 |
| `PUT` | `/v1/bot/voice/context` | 来源: modules/bot_api/bot_api.go#L456-L456 | group botAPI declared L400 |
| `GET` | `/v1/bot/voice/context` | 来源: modules/bot_api/bot_api.go#L457-L457 | group botAPI declared L400 |
| `DELETE` | `/v1/bot/voice/context` | 来源: modules/bot_api/bot_api.go#L458-L458 | group botAPI declared L400 |
| `POST` | `/v1/bot/voice/transcribe` | 来源: modules/bot_api/bot_api.go#L459-L459 | group botAPI declared L400 |
| `GET` | `/v1/bot/obo-grant` | 来源: modules/bot_api/bot_api.go#L467-L467 | group botAPI declared L400 |
| `GET` | `/v1/botfile/*path` | 来源: modules/bot_api/bot_api.go#L482-L482 | group botFileAPI declared L480 |
| `POST` | `/v1/botfile/upload` | 来源: modules/bot_api/bot_api.go#L483-L483 | group botFileAPI declared L480 |
| `Any` | `recover` | 来源: modules/bot_api/groups.go#L279-L279 | group zap |
| `POST` | `/v1/obo/grants` | 来源: modules/bot_api/obo_api.go#L111-L111 | group auth declared L110 |
| `GET` | `/v1/obo/grants` | 来源: modules/bot_api/obo_api.go#L112-L112 | group auth declared L110 |
| `DELETE` | `/v1/obo/grants/:id` | 来源: modules/bot_api/obo_api.go#L113-L113 | group auth declared L110 |
| `PUT` | `/v1/obo/grants/:id` | 来源: modules/bot_api/obo_api.go#L114-L114 | group auth declared L110 |
| `POST` | `/v1/obo/scopes` | 来源: modules/bot_api/obo_api.go#L115-L115 | group auth declared L110 |
| `DELETE` | `/v1/obo/scopes/:id` | 来源: modules/bot_api/obo_api.go#L116-L116 | group auth declared L110 |
| `GET` | `/v1/obo/grants/:id/scopes` | 来源: modules/bot_api/obo_api.go#L117-L117 | group auth declared L110 |
| `Any` | `error` | 来源: modules/bot_api/register.go#L340-L340 | group zap |
| `Any` | `error` | 来源: modules/bot_api/register.go#L491-L491 | group zap |
| `Any` | `recover` | 来源: modules/bot_api/send.go#L822-L822 | group zap |
| `Any` | `recover` | 来源: modules/bot_api/threads.go#L308-L308 | group zap |

## bot_mention

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/internal/bot-mentions` | 来源: modules/bot_mention/api.go#L72-L72 | group internal declared L71 |

## bot_provision

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/bot/mint` | 来源: modules/bot_provision/bot_api.go#L198-L198 | group mintAPI declared L197 |
| `GET` | `/v1/bot/:uid/token` | 来源: modules/bot_provision/bot_api.go#L217-L217 | group r |

## botfather

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/bot/skill.md` | 来源: modules/botfather/api.go#L94-L94 | group r |
| `GET` | `/v1/bot/cli-guide.md` | 来源: modules/botfather/api.go#L95-L95 | group r |
| `GET` | `/v1/bot/setup-install.md` | 来源: modules/botfather/api.go#L96-L96 | group r |
| `GET` | `/v1/bot/setup-newbot.md` | 来源: modules/botfather/api.go#L97-L97 | group r |
| `GET` | `/v1/bot/setup-quickstart.md` | 来源: modules/botfather/api.go#L98-L98 | group r |
| `GET` | `/v1/runtime-onboarding` | 来源: modules/botfather/api.go#L115-L115 | group runtimeAPI declared L114 |
| `Any` | `recover` | 来源: modules/botfather/api.go#L253-L253 | group zap |
| `Any` | `error` | 来源: modules/botfather/api.go#L458-L458 | group zap |
| `POST` | `/v1/robot/apply` | 来源: modules/botfather/api_apply.go#L529-L529 | group applyAPI declared L527 |
| `POST` | `/v1/robot/apply/sure` | 来源: modules/botfather/api_apply.go#L530-L530 | group applyAPI declared L527 |
| `PUT` | `/v1/robot/apply/refuse/:apply_id` | 来源: modules/botfather/api_apply.go#L531-L531 | group applyAPI declared L527 |
| `GET` | `/v1/robot/applies` | 来源: modules/botfather/api_apply.go#L532-L532 | group applyAPI declared L527 |
| `POST` | `/v1/user/bots` | 来源: modules/botfather/api_user.go#L108-L108 | group userAPI declared L106 |
| `GET` | `/v1/user/bots` | 来源: modules/botfather/api_user.go#L109-L109 | group userAPI declared L106 |
| `PUT` | `/v1/user/bots/:bot_id` | 来源: modules/botfather/api_user.go#L110-L110 | group userAPI declared L106 |
| `DELETE` | `/v1/user/bots/:bot_id` | 来源: modules/botfather/api_user.go#L111-L111 | group userAPI declared L106 |
| `GET` | `/v1/user/bots/:bot_id/token` | 来源: modules/botfather/api_user.go#L112-L112 | group userAPI declared L106 |
| `POST` | `/v1/user/bots/:bot_id/bind` | 来源: modules/botfather/api_user.go#L113-L113 | group userAPI declared L106 |
| `DELETE` | `/v1/user/bots/:bot_id/bind` | 来源: modules/botfather/api_user.go#L114-L114 | group userAPI declared L106 |

## card_template_catalog

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/validate` | 来源: modules/card_template_catalog/api.go#L128-L128 | group manager |
| `POST` | `/publish` | 来源: modules/card_template_catalog/api.go#L129-L129 | group manager |
| `GET` | `/:id/audit` | 来源: modules/card_template_catalog/api.go#L130-L130 | group manager |
| `GET` | `/:id` | 来源: modules/card_template_catalog/api.go#L131-L131 | group manager |
| `PUT` | `/:id/active` | 来源: modules/card_template_catalog/api.go#L132-L132 | group manager |
| `POST` | `/:id/rollback` | 来源: modules/card_template_catalog/api.go#L133-L133 | group manager |
| `POST` | `/:id/block` | 来源: modules/card_template_catalog/api.go#L134-L134 | group manager |

## category

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/spaces/:space_id/categories` | 来源: modules/category/api.go#L42-L42 | group spaces declared L40 |
| `GET` | `/v1/spaces/:space_id/categories` | 来源: modules/category/api.go#L43-L43 | group spaces declared L40 |
| `PUT` | `/v1/spaces/:space_id/categories/sort` | 来源: modules/category/api.go#L44-L44 | group spaces declared L40 |
| `PUT` | `/v1/spaces/:space_id/categories/:category_id` | 来源: modules/category/api.go#L45-L45 | group spaces declared L40 |
| `DELETE` | `/v1/spaces/:space_id/categories/:category_id` | 来源: modules/category/api.go#L46-L46 | group spaces declared L40 |
| `PUT` | `/v1/groups/:group_no/category` | 来源: modules/category/api.go#L51-L51 | group groups declared L49 |

## channel

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/channel/state` | 来源: modules/channel/api.go#L50-L50 | group auth declared L48 |
| `GET` | `/v1/channels/:channel_id/:channel_type` | 来源: modules/channel/api.go#L53-L53 | group auth declared L48 |
| `POST` | `/v1/channels/:channel_id/:channel_type/message/clear` | 来源: modules/channel/api.go#L54-L54 | group auth declared L48 |
| `GET` | `/v1/channels/:channel_id/:channel_type/storyline` | 来源: modules/channel/api.go#L55-L55 | group auth declared L48 |
| `POST` | `/v1/channels/:channel_id/:channel_type/message/autodelete` | 来源: modules/channel/api.go#L64-L64 | group spaceAuth declared L62 |

## common

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/common/appversion` | 来源: modules/common/api.go#L77-L77 | group common declared L75 |
| `GET` | `/v1/common/appversion/:os/:version` | 来源: modules/common/api.go#L78-L78 | group common declared L75 |
| `GET` | `/v1/common/appversion/list` | 来源: modules/common/api.go#L79-L79 | group common declared L75 |
| `GET` | `/v1/common/chatbg` | 来源: modules/common/api.go#L80-L80 | group common declared L75 |
| `GET` | `/v1/common/appmodule` | 来源: modules/common/api.go#L81-L81 | group common declared L75 |
| `GET` | `/v1/common/countries` | 来源: modules/common/api.go#L85-L85 | group commonNoAuth declared L83 |
| `GET` | `/v1/common/appconfig` | 来源: modules/common/api.go#L87-L87 | group commonNoAuth declared L83 |
| `GET` | `/v1/common/keepalive` | 来源: modules/common/api.go#L88-L88 | group commonNoAuth declared L83 |
| `GET` | `/v1/common/updater/:os/:version` | 来源: modules/common/api.go#L89-L89 | group commonNoAuth declared L83 |
| `GET` | `/v1/common/pcupdater/:os` | 来源: modules/common/api.go#L90-L90 | group commonNoAuth declared L83 |
| `GET` | `/v1/common/changelog` | 来源: modules/common/api.go#L91-L91 | group commonNoAuth declared L83 |
| `GET` | `/v1/common/emojis` | 来源: modules/common/api.go#L92-L92 | group commonNoAuth declared L83 |
| `GET` | `/v1/health` | 来源: modules/common/api.go#L95-L95 | group r |
| `GET` | `/v1/ready` | 来源: modules/common/api.go#L96-L96 | group r |
| `GET` | `/v1/manager/common/appconfig` | 来源: modules/common/api_manager.go#L39-L39 | group auth declared L37 |
| `POST` | `/v1/manager/common/appconfig` | 来源: modules/common/api_manager.go#L40-L40 | group auth declared L37 |
| `GET` | `/v1/manager/common/appmodule` | 来源: modules/common/api_manager.go#L41-L41 | group auth declared L37 |
| `PUT` | `/v1/manager/common/appmodule` | 来源: modules/common/api_manager.go#L42-L42 | group auth declared L37 |
| `POST` | `/v1/manager/common/appmodule` | 来源: modules/common/api_manager.go#L43-L43 | group auth declared L37 |
| `DELETE` | `/v1/manager/common/:sid/appmodule` | 来源: modules/common/api_manager.go#L44-L44 | group auth declared L37 |
| `GET` | `/v1/manager/common/system_setting` | 来源: modules/common/api_manager.go#L47-L47 | group auth declared L37 |
| `POST` | `/v1/manager/common/system_setting` | 来源: modules/common/api_manager.go#L48-L48 | group auth declared L37 |
| `POST` | `/v1/manager/common/system_setting/test_email` | 来源: modules/common/api_manager.go#L49-L49 | group auth declared L37 |

## conversation_ext

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/follow/dm` | 来源: modules/conversation_ext/1module.go#L64-L64 | group grp declared L60 |
| `DELETE` | `/v1/follow/dm` | 来源: modules/conversation_ext/1module.go#L65-L65 | group grp declared L60 |
| `POST` | `/v1/follow/channel/unfollow` | 来源: modules/conversation_ext/1module.go#L66-L66 | group grp declared L60 |
| `POST` | `/v1/follow/channel/refollow` | 来源: modules/conversation_ext/1module.go#L67-L67 | group grp declared L60 |
| `POST` | `/v1/follow/thread` | 来源: modules/conversation_ext/1module.go#L68-L68 | group grp declared L60 |
| `DELETE` | `/v1/follow/thread` | 来源: modules/conversation_ext/1module.go#L69-L69 | group grp declared L60 |
| `PUT` | `/v1/follow/sort` | 来源: modules/conversation_ext/1module.go#L70-L70 | group grp declared L60 |

## file

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/file/preview/*path` | 来源: modules/file/api.go#L89-L89 | group auth declared L85 |
| `GET` | `/v1/file/upload` | 来源: modules/file/api.go#L91-L91 | group auth declared L85 |
| `POST` | `/v1/file/upload` | 来源: modules/file/api.go#L93-L93 | group auth declared L85 |
| `GET` | `/v1/file/upload/presigned` | 来源: modules/file/api.go#L95-L95 | group auth declared L85 |
| `GET` | `/v1/file/upload/credentials` | 来源: modules/file/api.go#L96-L96 | group auth declared L85 |
| `GET` | `/v1/file/download/url` | 来源: modules/file/api.go#L98-L98 | group auth declared L85 |
| `Any` | `imageURLs` | 来源: modules/file/api.go#L183-L183 | group zap |
| `Any` | `resultMap` | 来源: modules/file/api.go#L189-L189 | group zap |

## group

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/group/create` | 来源: modules/group/api.go#L94-L94 | group group declared L92 |
| `GET` | `/v1/group/my` | 来源: modules/group/api.go#L95-L95 | group group declared L92 |
| `GET` | `/v1/group/forbidden_times` | 来源: modules/group/api.go#L96-L96 | group group declared L92 |
| `POST` | `/v1/groups/:group_no/members` | 来源: modules/group/api.go#L105-L105 | group groups declared L98 |
| `DELETE` | `/v1/groups/:group_no/members` | 来源: modules/group/api.go#L106-L106 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no/members` | 来源: modules/group/api.go#L107-L107 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no/members/:uid` | 来源: modules/group/api.go#L108-L108 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/members_delete` | 来源: modules/group/api.go#L109-L109 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no/membersync` | 来源: modules/group/api.go#L110-L110 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no` | 来源: modules/group/api.go#L111-L111 | group groups declared L98 |
| `PUT` | `/v1/groups/:group_no/setting` | 来源: modules/group/api.go#L112-L112 | group groups declared L98 |
| `PUT` | `/v1/groups/:group_no` | 来源: modules/group/api.go#L113-L113 | group groups declared L98 |
| `PUT` | `/v1/groups/:group_no/members/:uid` | 来源: modules/group/api.go#L114-L114 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/exit` | 来源: modules/group/api.go#L115-L115 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/managers` | 来源: modules/group/api.go#L116-L116 | group groups declared L98 |
| `DELETE` | `/v1/groups/:group_no/managers` | 来源: modules/group/api.go#L117-L117 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/forbidden/:on` | 来源: modules/group/api.go#L118-L118 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no/qrcode` | 来源: modules/group/api.go#L119-L119 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/transfer/:to_uid` | 来源: modules/group/api.go#L120-L120 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/member/invite` | 来源: modules/group/api.go#L121-L121 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no/member/h5confirm` | 来源: modules/group/api.go#L122-L122 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/blacklist/:action` | 来源: modules/group/api.go#L123-L123 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/forbidden_with_member` | 来源: modules/group/api.go#L124-L124 | group groups declared L98 |
| `POST` | `/v1/groups/:group_no/avatar` | 来源: modules/group/api.go#L125-L125 | group groups declared L98 |
| `DELETE` | `/v1/groups/:group_no/disband` | 来源: modules/group/api.go#L126-L126 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no/detail` | 来源: modules/group/api.go#L127-L127 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no/md` | 来源: modules/group/api.go#L128-L128 | group groups declared L98 |
| `PUT` | `/v1/groups/:group_no/md` | 来源: modules/group/api.go#L129-L129 | group groups declared L98 |
| `DELETE` | `/v1/groups/:group_no/md` | 来源: modules/group/api.go#L130-L130 | group groups declared L98 |
| `PUT` | `/v1/groups/:group_no/bot_admin/:uid` | 来源: modules/group/api.go#L131-L131 | group groups declared L98 |
| `DELETE` | `/v1/groups/:group_no/bot_admin/:uid` | 来源: modules/group/api.go#L132-L132 | group groups declared L98 |
| `GET` | `/v1/groups/:group_no/avatar` | 来源: modules/group/api.go#L136-L136 | group openGroups declared L134 |
| `GET` | `/v1/groups/:group_no/scanjoin` | 来源: modules/group/api.go#L140-L140 | group authGroups declared L138 |
| `GET` | `/v1/groups/:group_no/welcome` | 来源: modules/group/api.go#L146-L146 | group welcomeGroups declared L144 |
| `PUT` | `/v1/groups/:group_no/welcome` | 来源: modules/group/api.go#L147-L147 | group welcomeGroups declared L144 |
| `DELETE` | `/v1/groups/:group_no/welcome` | 来源: modules/group/api.go#L148-L148 | group welcomeGroups declared L144 |
| `POST` | `/v1/group/invite/authorize` | 来源: modules/group/api.go#L159-L159 | group authInviteGroup declared L157 |
| `POST` | `/v1/groupinvite/sure` | 来源: modules/group/api.go#L186-L186 | group openGroup declared L183 |
| `GET` | `/v1/group/invite` | 来源: modules/group/api.go#L187-L187 | group openGroup declared L183 |
| `GET` | `/v1/group/invite/detail` | 来源: modules/group/api.go#L188-L188 | group openGroup declared L183 |
| `GET` | `/v1/group/avatar_palette` | 来源: modules/group/api.go#L189-L189 | group openGroup declared L183 |
| `GET` | `/v1/group/invites/:invite_no` | 来源: modules/group/api.go#L192-L192 | group group declared L92 |
| `Any` | `memberUIDs` | 来源: modules/group/api.go#L2122-L2122 | group zap |
| `Any` | `memberUIDs` | 来源: modules/group/api.go#L2226-L2226 | group zap |
| `Any` | `recover` | 来源: modules/group/api.go#L4218-L4218 | group zap |
| `Any` | `recover` | 来源: modules/group/api.go#L4265-L4265 | group zap |
| `GET` | `/v1/manager/group/list` | 来源: modules/group/api_manager.go#L49-L49 | group auth declared L47 |
| `GET` | `/v1/manager/group/disablelist` | 来源: modules/group/api_manager.go#L50-L50 | group auth declared L47 |
| `PUT` | `/v1/manager/group/liftban/:groupNo/:status` | 来源: modules/group/api_manager.go#L51-L51 | group auth declared L47 |
| `PUT` | `/v1/manager/groups/:group_no/forbidden/:on` | 来源: modules/group/api_manager.go#L52-L52 | group auth declared L47 |
| `GET` | `/v1/manager/groups/:group_no/members` | 来源: modules/group/api_manager.go#L53-L53 | group auth declared L47 |
| `GET` | `/v1/manager/groups/:group_no/members/blacklist` | 来源: modules/group/api_manager.go#L54-L54 | group auth declared L47 |
| `DELETE` | `/v1/manager/groups/:group_no/members` | 来源: modules/group/api_manager.go#L55-L55 | group auth declared L47 |
| `Any` | `groupMap` | 来源: modules/group/api_manager.go#L269-L269 | group zap |

## incomingwebhook

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `PUT` | `/:webhook_id` | 来源: modules/incomingwebhook/api.go#L292-L292 | group g |
| `DELETE` | `/:webhook_id` | 来源: modules/incomingwebhook/api.go#L293-L293 | group g |
| `POST` | `/:webhook_id/regenerate` | 来源: modules/incomingwebhook/api.go#L294-L294 | group g |
| `GET` | `/:webhook_id/deliveries` | 来源: modules/incomingwebhook/api.go#L296-L296 | group g |
| `POST` | `/:webhook_id/test` | 来源: modules/incomingwebhook/api.go#L298-L298 | group g |
| `Any` | `recover` | 来源: modules/incomingwebhook/api.go#L1768-L1768 | group zap |

## integration

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/integrations/oidc/spaces` | 来源: modules/integration/api.go#L156-L156 | group base declared L155 |
| `POST` | `/v1/integrations/oidc/exchange` | 来源: modules/integration/api.go#L157-L157 | group base declared L155 |
| `DELETE` | `/v1/integrations/oidc/binding` | 来源: modules/integration/api.go#L158-L158 | group base declared L155 |
| `POST` | `/v1/integrations/oidc/groups` | 来源: modules/integration/api.go#L159-L159 | group base declared L155 |
| `GET` | `/v1/integrations/oidc/groups/:group_no` | 来源: modules/integration/api.go#L160-L160 | group base declared L155 |
| `PUT` | `/v1/manager/integrations/oidc/client` | 来源: modules/integration/api.go#L163-L163 | group manager declared L162 |

## message

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/message/sync` | 来源: modules/message/api.go#L365-L365 | group message declared L362 |
| `POST` | `/v1/message/syncack/:last_message_seq` | 来源: modules/message/api.go#L366-L366 | group message declared L362 |
| `DELETE` | `/v1/message/mutual` | 来源: modules/message/api.go#L368-L368 | group message declared L362 |
| `POST` | `/v1/message/revoke` | 来源: modules/message/api.go#L369-L369 | group message declared L362 |
| `POST` | `/v1/message/offset` | 来源: modules/message/api.go#L370-L370 | group message declared L362 |
| `PUT` | `/v1/message/voicereaded` | 来源: modules/message/api.go#L371-L371 | group message declared L362 |
| `POST` | `/v1/message/search` | 来源: modules/message/api.go#L372-L372 | group message declared L362 |
| `POST` | `/v1/message/typing` | 来源: modules/message/api.go#L373-L373 | group message declared L362 |
| `POST` | `/v1/message/channel/sync` | 来源: modules/message/api.go#L374-L374 | group message declared L362 |
| `POST` | `/v1/message/extra/sync` | 来源: modules/message/api.go#L375-L375 | group message declared L362 |
| `POST` | `/v1/message/readed` | 来源: modules/message/api.go#L376-L376 | group message declared L362 |
| `GET` | `/v1/message/sync/sensitivewords` | 来源: modules/message/api.go#L377-L377 | group message declared L362 |
| `POST` | `/v1/message/edit` | 来源: modules/message/api.go#L378-L378 | group message declared L362 |
| `POST` | `/v1/message/card/action` | 来源: modules/message/api.go#L379-L379 | group message declared L362 |
| `GET` | `/v1/message/card/revisions` | 来源: modules/message/api.go#L380-L380 | group message declared L362 |
| `POST` | `/v1/message/reminder/sync` | 来源: modules/message/api.go#L381-L381 | group message declared L362 |
| `POST` | `/v1/message/reminder/done` | 来源: modules/message/api.go#L382-L382 | group message declared L362 |
| `GET` | `/v1/message/prohibit_words/sync` | 来源: modules/message/api.go#L383-L383 | group message declared L362 |
| `POST` | `/v1/message/pinned` | 来源: modules/message/api.go#L384-L384 | group message declared L362 |
| `POST` | `/v1/message/pinned/sync` | 来源: modules/message/api.go#L385-L385 | group message declared L362 |
| `POST` | `/v1/message/pinned/clear` | 来源: modules/message/api.go#L386-L386 | group message declared L362 |
| `POST` | `/v1/message/channel/files` | 来源: modules/message/api.go#L387-L387 | group message declared L362 |
| `PUT` | `/v1/messages/:message_id/voicereaded` | 来源: modules/message/api.go#L391-L391 | group messages declared L389 |
| `GET` | `/v1/messages/:message_id/receipt` | 来源: modules/message/api.go#L392-L392 | group messages declared L389 |
| `GET` | `/v1/messages/person/:peer_uid/:message_id` | 来源: modules/message/api.go#L402-L402 | group messages declared L389 |
| `POST` | `/v1/reaction/sync` | 来源: modules/message/api.go#L414-L414 | group reaction declared L412 |
| `POST` | `/v1/message/send` | 来源: modules/message/api.go#L418-L418 | group msg declared L416 |
| `GET` | `/v1/groups/:group_no/messages/:message_id` | 来源: modules/message/api.go#L423-L423 | group groups declared L421 |
| `GET` | `/v1/groups/:group_no/threads/:short_id/messages/:message_id` | 来源: modules/message/api.go#L429-L429 | group groups declared L421 |
| `Any` | `recover` | 来源: modules/message/api.go#L1235-L1235 | group zap |
| `Any` | `msg` | 来源: modules/message/api.go#L3502-L3502 | group zap |
| `PUT` | `/v1/coversation/clearUnread` | 来源: modules/message/api_conversation.go#L108-L108 | group cnversation declared L106 |
| `POST` | `/v1/conversation/sync` | 来源: modules/message/api_conversation.go#L114-L114 | group conversation declared L111 |
| `POST` | `/v1/conversation/syncack` | 来源: modules/message/api_conversation.go#L115-L115 | group conversation declared L111 |
| `POST` | `/v1/conversation/extra/sync` | 来源: modules/message/api_conversation.go#L116-L116 | group conversation declared L111 |
| `PUT` | `/v1/conversation/clearUnread` | 来源: modules/message/api_conversation.go#L117-L117 | group conversation declared L111 |
| `DELETE` | `/v1/conversations/:channel_id/:channel_type` | 来源: modules/message/api_conversation.go#L121-L121 | group conversations declared L119 |
| `POST` | `/v1/conversations/:channel_id/:channel_type/extra` | 来源: modules/message/api_conversation.go#L122-L122 | group conversations declared L119 |
| `POST` | `/v1/manager/message/send` | 来源: modules/message/api_manager.go#L58-L58 | group auth declared L56 |
| `POST` | `/v1/managermessage/sendfriends` | 来源: modules/message/api_manager.go#L59-L59 | group auth declared L56 |
| `GET` | `/v1/manager/message` | 来源: modules/message/api_manager.go#L60-L60 | group auth declared L56 |
| `POST` | `/v1/manager/message/sendall` | 来源: modules/message/api_manager.go#L61-L61 | group auth declared L56 |
| `GET` | `/v1/manager/message/record` | 来源: modules/message/api_manager.go#L62-L62 | group auth declared L56 |
| `GET` | `/v1/manager/message/recordpersonal` | 来源: modules/message/api_manager.go#L63-L63 | group auth declared L56 |
| `POST` | `/v1/manager/message/prohibit_words` | 来源: modules/message/api_manager.go#L64-L64 | group auth declared L56 |
| `GET` | `/v1/manager/message/prohibit_words` | 来源: modules/message/api_manager.go#L65-L65 | group auth declared L56 |
| `DELETE` | `/v1/manager/message/prohibit_words` | 来源: modules/message/api_manager.go#L66-L66 | group auth declared L56 |
| `DELETE` | `/v1/manager/message` | 来源: modules/message/api_manager.go#L67-L67 | group auth declared L56 |
| `POST` | `/v1/sidebar/sync` | 来源: modules/message/api_sidebar.go#L172-L172 | group grp declared L170 |

## messages_search

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/_search_all` | 来源: modules/messages_search/search_all.go#L25-L25 | group g |
| `POST` | `/_search_around` | 来源: modules/messages_search/search_around.go#L27-L27 | group g |
| `GET` | `/v1/messages/_search_file_types` | 来源: modules/messages_search/search_file_types.go#L67-L67 | group g declared L63 |
| `POST` | `/_search_files` | 来源: modules/messages_search/search_files.go#L59-L59 | group g |
| `POST` | `/_search_global_files` | 来源: modules/messages_search/search_global_files.go#L28-L28 | group g |
| `POST` | `/_search_global_groups` | 来源: modules/messages_search/search_global_groups.go#L87-L87 | group g |
| `POST` | `/_search_global_messages` | 来源: modules/messages_search/search_global_messages.go#L28-L28 | group g |
| `POST` | `/_search_media` | 来源: modules/messages_search/search_media.go#L38-L38 | group g |
| `POST` | `/_search` | 来源: modules/messages_search/search_messages.go#L56-L56 | group g |

## notification

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/user/notification-pause` | 来源: modules/notification/api.go#L34-L34 | group user declared L32 |
| `PUT` | `/v1/user/notification-pause` | 来源: modules/notification/api.go#L35-L35 | group user declared L32 |
| `DELETE` | `/v1/user/notification-pause` | 来源: modules/notification/api.go#L36-L36 | group user declared L32 |

## notify

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/internal/notify` | 来源: modules/notify/api.go#L210-L210 | group internal declared L208 |
| `POST` | `/v1/internal/notify/batch` | 来源: modules/notify/api.go#L211-L211 | group internal declared L208 |
| `POST` | `/v1/internal/cards/mutate` | 来源: modules/notify/api.go#L212-L212 | group internal declared L208 |
| `Any` | `recover` | 来源: modules/notify/api.go#L307-L307 | group zap |
| `Any` | `recover` | 来源: modules/notify/group_welcome.go#L734-L734 | group zap |
| `Any` | `recover` | 来源: modules/notify/space_welcome.go#L655-L655 | group zap |

## oidc

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/authorize` | 来源: modules/oidc/api.go#L385-L385 | group pub |
| `GET` | `/callback` | 来源: modules/oidc/api.go#L386-L386 | group pub |
| `POST` | `/logout` | 来源: modules/oidc/api.go#L387-L387 | group pub |
| `POST` | `/exchange` | 来源: modules/oidc/api.go#L388-L388 | group pub |
| `POST` | `/exchange-jwt` | 来源: modules/oidc/api.go#L389-L389 | group pub |
| `GET` | `/authorize` | 来源: modules/oidc/api.go#L399-L399 | group pub |
| `GET` | `/callback` | 来源: modules/oidc/api.go#L400-L400 | group pub |
| `POST` | `/exchange` | 来源: modules/oidc/api.go#L421-L421 | group pub |
| `POST` | `/exchange-jwt` | 来源: modules/oidc/api.go#L422-L422 | group pub |
| `POST` | `/logout` | 来源: modules/oidc/api.go#L425-L425 | group authed |
| `GET` | `/bind/info` | 来源: modules/oidc/api_bind.go#L95-L95 | group g |
| `POST` | `/bind/verify/password` | 来源: modules/oidc/api_bind.go#L96-L96 | group g |
| `POST` | `/bind/verify/otp/send` | 来源: modules/oidc/api_bind.go#L97-L97 | group g |
| `POST` | `/bind/verify/otp/check` | 来源: modules/oidc/api_bind.go#L98-L98 | group g |
| `POST` | `/bind/confirm` | 来源: modules/oidc/api_bind.go#L99-L99 | group g |
| `POST` | `/bind/create` | 来源: modules/oidc/api_bind.go#L101-L101 | group g |
| `Any` | `recover` | 来源: modules/oidc/initial_space.go#L38-L38 | group zap |
| `Any` | `panic` | 来源: modules/oidc/sync_worker.go#L268-L268 | group zap |

## opanalytics

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/manager/dashboard/overview` | 来源: modules/opanalytics/api.go#L60-L60 | group auth declared L58 |
| `GET` | `/v1/manager/dashboard/trend` | 来源: modules/opanalytics/api.go#L61-L61 | group auth declared L58 |
| `GET` | `/v1/manager/dashboard/spaces` | 来源: modules/opanalytics/api.go#L62-L62 | group auth declared L58 |
| `GET` | `/v1/manager/dashboard/spaces/:space_id/channels` | 来源: modules/opanalytics/api.go#L63-L63 | group auth declared L58 |
| `GET` | `/v1/manager/dashboard/channels/:channel_id/members` | 来源: modules/opanalytics/api.go#L64-L64 | group auth declared L58 |
| `GET` | `/v1/manager/dashboard/global/direct-chats` | 来源: modules/opanalytics/api.go#L65-L65 | group auth declared L58 |
| `POST` | `/v1/manager/dashboard/etl/run` | 来源: modules/opanalytics/api.go#L66-L66 | group auth declared L58 |

## openapi

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/openapi/access_token` | 来源: modules/openapi/api.go#L63-L63 | group openapinoauth declared L60 |
| `GET` | `/v1/openapi/userinfo` | 来源: modules/openapi/api.go#L64-L64 | group openapinoauth declared L60 |
| `GET` | `/v1/openapi/authcode` | 来源: modules/openapi/api.go#L70-L70 | group openapi declared L67 |

## report

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/report/categories` | 来源: modules/report/api.go#L41-L41 | group v declared L39 |
| `GET` | `/v1/report/html` | 来源: modules/report/api.go#L42-L42 | group v declared L39 |
| `POST` | `/v1/report/session/resolve` | 来源: modules/report/api.go#L43-L43 | group v declared L39 |
| `GET` | `/v1/manager/report/list` | 来源: modules/report/api_manager.go#L45-L45 | group auth declared L43 |

## robot

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/robot/sync` | 来源: modules/robot/api.go#L420-L420 | group auth declared L418 |
| `POST` | `/v1/robot/inline_query` | 来源: modules/robot/api.go#L421-L421 | group auth declared L418 |
| `GET` | `/v1/robot/commands` | 来源: modules/robot/api.go#L422-L422 | group auth declared L418 |
| `PUT` | `/v1/robot/:robot_id/description` | 来源: modules/robot/api.go#L423-L423 | group auth declared L418 |
| `PUT` | `/v1/robot/:robot_id/auto_approve` | 来源: modules/robot/api.go#L424-L424 | group auth declared L418 |
| `GET` | `/v1/robot/my_bots` | 来源: modules/robot/api.go#L425-L425 | group auth declared L418 |
| `GET` | `/v1/robot/:robot_id/groups` | 来源: modules/robot/api.go#L427-L427 | group auth declared L418 |
| `PUT` | `/v1/robot/:robot_id/groups/:group_no/mention_pref` | 来源: modules/robot/api.go#L428-L428 | group auth declared L418 |
| `DELETE` | `/v1/robot/:robot_id/groups/:group_no/mention_pref` | 来源: modules/robot/api.go#L429-L429 | group auth declared L418 |
| `GET` | `/v1/robot/:robot_id/groups/:group_no/mention_pref` | 来源: modules/robot/api.go#L430-L430 | group auth declared L418 |
| `GET` | `/v1/robot/:robot_id/settings` | 来源: modules/robot/api.go#L436-L436 | group auth declared L418 |
| `PUT` | `/v1/robot/:robot_id/settings` | 来源: modules/robot/api.go#L437-L437 | group auth declared L418 |
| `DELETE` | `/v1/robot/:robot_id/settings/:key` | 来源: modules/robot/api.go#L438-L438 | group auth declared L418 |
| `GET` | `/v1/robot/owned_bots` | 来源: modules/robot/api.go#L443-L443 | group ownedBots declared L441 |
| `GET` | `/v1/robot/space_bots` | 来源: modules/robot/api.go#L461-L461 | group spaceBots declared L459 |
| `GET` | `/v1/robots/:robot_id/:app_key/events` | 来源: modules/robot/api.go#L466-L466 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/events` | 来源: modules/robot/api.go#L467-L467 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/events/:event_id/ack` | 来源: modules/robot/api.go#L468-L468 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/answerInlineQuery` | 来源: modules/robot/api.go#L469-L469 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/sendMessage` | 来源: modules/robot/api.go#L470-L470 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/typing` | 来源: modules/robot/api.go#L471-L471 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/stream/start` | 来源: modules/robot/api.go#L472-L472 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/stream/end` | 来源: modules/robot/api.go#L473-L473 | group robotAuth declared L464 |
| `GET` | `/v1/robots/:robot_id/:app_key/file/*path` | 来源: modules/robot/api.go#L474-L474 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/upload` | 来源: modules/robot/api.go#L475-L475 | group robotAuth declared L464 |
| `GET` | `/v1/robots/:robot_id/:app_key/upload/credentials` | 来源: modules/robot/api.go#L476-L476 | group robotAuth declared L464 |
| `GET` | `/v1/robots/:robot_id/:app_key/upload/presigned` | 来源: modules/robot/api.go#L477-L477 | group robotAuth declared L464 |
| `POST` | `/v1/robots/:robot_id/:app_key/message/edit` | 来源: modules/robot/api.go#L478-L478 | group robotAuth declared L464 |
| `GET` | `/v1/manager/robot/menus` | 来源: modules/robot/api_manager.go#L40-L40 | group auth declared L38 |
| `DELETE` | `/v1/manager/robot/:robot_id/:id` | 来源: modules/robot/api_manager.go#L41-L41 | group auth declared L38 |
| `PUT` | `/v1/manager/robot/status/:robot_id/:status` | 来源: modules/robot/api_manager.go#L42-L42 | group auth declared L38 |
| `GET` | `/v1/manager/robots` | 来源: modules/robot/api_manager.go#L44-L44 | group auth declared L38 |
| `GET` | `/v1/manager/robots/:robot_id` | 来源: modules/robot/api_manager.go#L45-L45 | group auth declared L38 |
| `PUT` | `/v1/manager/robots/:robot_id` | 来源: modules/robot/api_manager.go#L46-L46 | group auth declared L38 |
| `DELETE` | `/v1/manager/robots/:robot_id` | 来源: modules/robot/api_manager.go#L47-L47 | group auth declared L38 |
| `POST` | `/v1/manager/robots/:robot_id/revoke_token` | 来源: modules/robot/api_manager.go#L48-L48 | group auth declared L38 |
| `Any` | `recover` | 来源: modules/robot/bot_setting.go#L629-L629 | group zap |
| `Any` | `recover` | 来源: modules/robot/event.go#L413-L413 | group zap |
| `Any` | `recover` | 来源: modules/robot/event.go#L427-L427 | group zap |
| `Any` | `recover` | 来源: modules/robot/mention_pref.go#L166-L166 | group zap |
| `Any` | `recover` | 来源: modules/robot/mention_pref.go#L198-L198 | group zap |

## search

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/search/global` | 来源: modules/search/api.go#L46-L46 | group searchs declared L44 |

## space

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/space/create` | 来源: modules/space/api.go#L83-L83 | group auth declared L81 |
| `GET` | `/v1/space/my` | 来源: modules/space/api.go#L84-L84 | group auth declared L81 |
| `GET` | `/v1/space/:space_id` | 来源: modules/space/api.go#L86-L86 | group auth declared L81 |
| `PUT` | `/v1/space/:space_id` | 来源: modules/space/api.go#L87-L87 | group auth declared L81 |
| `DELETE` | `/v1/space/:space_id` | 来源: modules/space/api.go#L88-L88 | group auth declared L81 |
| `GET` | `/v1/space/:space_id/members` | 来源: modules/space/api.go#L90-L90 | group auth declared L81 |
| `POST` | `/v1/space/:space_id/members/add` | 来源: modules/space/api.go#L91-L91 | group auth declared L81 |
| `POST` | `/v1/space/:space_id/members/remove` | 来源: modules/space/api.go#L92-L92 | group auth declared L81 |
| `POST` | `/v1/space/:space_id/leave` | 来源: modules/space/api.go#L93-L93 | group auth declared L81 |
| `PUT` | `/v1/space/:space_id/members/:uid/role` | 来源: modules/space/api.go#L94-L94 | group auth declared L81 |
| `POST` | `/v1/space/:space_id/invite` | 来源: modules/space/api.go#L96-L96 | group auth declared L81 |
| `PUT` | `/v1/space/:space_id/invite/:code` | 来源: modules/space/api.go#L97-L97 | group auth declared L81 |
| `DELETE` | `/v1/space/:space_id/invite/:code` | 来源: modules/space/api.go#L98-L98 | group auth declared L81 |
| `GET` | `/v1/space/:space_id/invites` | 来源: modules/space/api.go#L99-L99 | group auth declared L81 |
| `GET` | `/v1/space/:space_id/join-applies` | 来源: modules/space/api.go#L101-L101 | group auth declared L81 |
| `POST` | `/v1/space/:space_id/join-applies/:id/approve` | 来源: modules/space/api.go#L102-L102 | group auth declared L81 |
| `POST` | `/v1/space/:space_id/join-applies/:id/reject` | 来源: modules/space/api.go#L103-L103 | group auth declared L81 |
| `POST` | `/v1/space/:space_id/email-invites` | 来源: modules/space/api.go#L105-L105 | group auth declared L81 |
| `GET` | `/v1/space/:space_id/email-invites` | 来源: modules/space/api.go#L106-L106 | group auth declared L81 |
| `DELETE` | `/v1/space/:space_id/email-invites/:id` | 来源: modules/space/api.go#L107-L107 | group auth declared L81 |
| `POST` | `/v1/space/join` | 来源: modules/space/api.go#L134-L134 | group joinLimited declared L132 |
| `GET` | `/v1/space/:space_id/members/search` | 来源: modules/space/api.go#L139-L139 | group search declared L137 |
| `GET` | `/v1/space/:space_id/welcome` | 来源: modules/space/api.go#L144-L144 | group search declared L137 |
| `PUT` | `/v1/space/:space_id/welcome` | 来源: modules/space/api.go#L145-L145 | group search declared L137 |
| `DELETE` | `/v1/space/:space_id/welcome` | 来源: modules/space/api.go#L146-L146 | group search declared L137 |
| `GET` | `/v1/space/invite/:invite_code` | 来源: modules/space/api.go#L161-L161 | group open declared L159 |
| `GET` | `/v1/space/invite/:invite_code/preview` | 来源: modules/space/api.go#L162-L162 | group open declared L159 |
| `GET` | `/v1/space/email-invite` | 来源: modules/space/api.go#L163-L163 | group open declared L159 |
| `GET` | `/v1/space/email-invite/:token` | 来源: modules/space/api.go#L164-L164 | group open declared L159 |
| `GET` | `/v1/space/join-approve` | 来源: modules/space/api.go#L165-L165 | group open declared L159 |
| `GET` | `/v1/space/join-approve/detail` | 来源: modules/space/api.go#L166-L166 | group open declared L159 |
| `POST` | `/v1/space/join-approve/sure` | 来源: modules/space/api.go#L167-L167 | group open declared L159 |
| `POST` | `/v1/space/email-invite/:token/accept` | 来源: modules/space/api.go#L173-L173 | group authAccept declared L171 |
| `Any` | `recover` | 来源: modules/space/api.go#L1332-L1332 | group zap |
| `Any` | `recover` | 来源: modules/space/api.go#L2241-L2241 | group zap |
| `GET` | `/v1/manager/spaces` | 来源: modules/space/api_manager.go#L82-L82 | group auth declared L79 |
| `POST` | `/v1/manager/spaces` | 来源: modules/space/api_manager.go#L83-L83 | group auth declared L79 |
| `GET` | `/v1/manager/spaces/disabled` | 来源: modules/space/api_manager.go#L84-L84 | group auth declared L79 |
| `GET` | `/v1/manager/spaces/:space_id` | 来源: modules/space/api_manager.go#L87-L87 | group auth declared L79 |
| `PUT` | `/v1/manager/spaces/:space_id` | 来源: modules/space/api_manager.go#L88-L88 | group auth declared L79 |
| `DELETE` | `/v1/manager/spaces/:space_id` | 来源: modules/space/api_manager.go#L89-L89 | group auth declared L79 |
| `PUT` | `/v1/manager/spaces/:space_id/status/:status` | 来源: modules/space/api_manager.go#L90-L90 | group auth declared L79 |
| `GET` | `/v1/manager/spaces/:space_id/members` | 来源: modules/space/api_manager.go#L93-L93 | group auth declared L79 |
| `POST` | `/v1/manager/spaces/:space_id/members` | 来源: modules/space/api_manager.go#L94-L94 | group auth declared L79 |
| `DELETE` | `/v1/manager/spaces/:space_id/members` | 来源: modules/space/api_manager.go#L95-L95 | group auth declared L79 |
| `PUT` | `/v1/manager/spaces/:space_id/members/:uid/role` | 来源: modules/space/api_manager.go#L96-L96 | group auth declared L79 |
| `GET` | `/v1/manager/spaces/:space_id/invites` | 来源: modules/space/api_manager.go#L99-L99 | group auth declared L79 |
| `POST` | `/v1/manager/spaces/:space_id/invites` | 来源: modules/space/api_manager.go#L100-L100 | group auth declared L79 |
| `PUT` | `/v1/manager/spaces/:space_id/invites/:code` | 来源: modules/space/api_manager.go#L101-L101 | group auth declared L79 |
| `DELETE` | `/v1/manager/spaces/:space_id/invites/:code` | 来源: modules/space/api_manager.go#L102-L102 | group auth declared L79 |
| `POST` | `/v1/manager/spaces/invites` | 来源: modules/space/api_manager.go#L105-L105 | group auth declared L79 |
| `GET` | `/v1/manager/spaces/invites` | 来源: modules/space/api_manager.go#L106-L106 | group auth declared L79 |
| `DELETE` | `/v1/manager/spaces/invites/:id` | 来源: modules/space/api_manager.go#L107-L107 | group auth declared L79 |
| `GET` | `/v1/manager/spaces/:space_id/join-applies` | 来源: modules/space/api_manager.go#L110-L110 | group auth declared L79 |
| `POST` | `/v1/manager/spaces/:space_id/join-applies/:id/approve` | 来源: modules/space/api_manager.go#L111-L111 | group auth declared L79 |
| `POST` | `/v1/manager/spaces/:space_id/join-applies/:id/reject` | 来源: modules/space/api_manager.go#L112-L112 | group auth declared L79 |
| `Any` | `recover` | 来源: modules/space/member_removal.go#L222-L222 | group zap |
| `Any` | `recover` | 来源: modules/space/member_removal.go#L354-L354 | group zap |
| `Any` | `recover` | 来源: modules/space/member_removal.go#L385-L385 | group zap |
| `Any` | `recover` | 来源: modules/space/member_removal.go#L451-L451 | group zap |

## statistics

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/statistics/countnum` | 来源: modules/statistics/api.go#L36-L36 | group v declared L34 |
| `GET` | `/v1/statistics/registeruser/:start_date/:end_date` | 来源: modules/statistics/api.go#L37-L37 | group v declared L34 |
| `GET` | `/v1/statistics/createdgroup/:start_date/:end_date` | 来源: modules/statistics/api.go#L38-L38 | group v declared L34 |

## sticker

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/sticker/user` | 来源: modules/sticker/api.go#L117-L117 | group auth declared L115 |
| `POST` | `/v1/sticker/user` | 来源: modules/sticker/api.go#L118-L118 | group auth declared L115 |
| `POST` | `/v1/sticker/user/collect` | 来源: modules/sticker/api.go#L119-L119 | group auth declared L115 |
| `PUT` | `/v1/sticker/user/:sticker_id` | 来源: modules/sticker/api.go#L120-L120 | group auth declared L115 |
| `DELETE` | `/v1/sticker/user/:sticker_id` | 来源: modules/sticker/api.go#L121-L121 | group auth declared L115 |

## thread

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/groups/:group_no/threads/:short_id` | 来源: modules/thread/api.go#L185-L185 | group threads declared L181 |
| `PUT` | `/v1/groups/:group_no/threads/:short_id` | 来源: modules/thread/api.go#L186-L186 | group threads declared L181 |
| `PUT` | `/v1/groups/:group_no/threads/:short_id/setting` | 来源: modules/thread/api.go#L187-L187 | group threads declared L181 |
| `GET` | `/v1/groups/:group_no/threads/:short_id/members` | 来源: modules/thread/api.go#L188-L188 | group threads declared L181 |
| `POST` | `/v1/groups/:group_no/threads/:short_id/join` | 来源: modules/thread/api.go#L189-L189 | group threads declared L181 |
| `POST` | `/v1/groups/:group_no/threads/:short_id/leave` | 来源: modules/thread/api.go#L190-L190 | group threads declared L181 |
| `POST` | `/v1/groups/:group_no/threads/:short_id/archive` | 来源: modules/thread/api.go#L191-L191 | group threads declared L181 |
| `POST` | `/v1/groups/:group_no/threads/:short_id/unarchive` | 来源: modules/thread/api.go#L192-L192 | group threads declared L181 |
| `DELETE` | `/v1/groups/:group_no/threads/:short_id` | 来源: modules/thread/api.go#L193-L193 | group threads declared L181 |
| `GET` | `/v1/groups/:group_no/threads/:short_id/md` | 来源: modules/thread/api.go#L194-L194 | group threads declared L181 |
| `PUT` | `/v1/groups/:group_no/threads/:short_id/md` | 来源: modules/thread/api.go#L195-L195 | group threads declared L181 |
| `DELETE` | `/v1/groups/:group_no/threads/:short_id/md` | 来源: modules/thread/api.go#L196-L196 | group threads declared L181 |
| `POST` | `/v1/threads/:short_id/join` | 来源: modules/thread/api.go#L202-L202 | group threadSimple declared L200 |
| `POST` | `/v1/threads/:short_id/leave` | 来源: modules/thread/api.go#L203-L203 | group threadSimple declared L200 |
| `GET` | `/v1/threads/:short_id` | 来源: modules/thread/api.go#L204-L204 | group threadSimple declared L200 |
| `Any` | `recover` | 来源: modules/thread/api.go#L751-L751 | group zap |
| `Any` | `recover` | 来源: modules/thread/api.go#L813-L813 | group zap |

## user

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/users/:uid` | 来源: modules/user/api.go#L270-L270 | group auth declared L264 |
| `POST` | `/v1/users/batch` | 来源: modules/user/api.go#L280-L280 | group auth declared L264 |
| `GET` | `/v1/users/:uid/conversation` | 来源: modules/user/api.go#L282-L282 | group auth declared L264 |
| `GET` | `/v1/user/search` | 来源: modules/user/api.go#L284-L284 | group auth declared L264 |
| `POST` | `/v1/users/:uid/avatar` | 来源: modules/user/api.go#L285-L285 | group auth declared L264 |
| `PUT` | `/v1/users/:uid/setting` | 来源: modules/user/api.go#L286-L286 | group auth declared L264 |
| `POST` | `/v1/user/device_token` | 来源: modules/user/api.go#L319-L319 | group user declared L317 |
| `DELETE` | `/v1/user/device_token` | 来源: modules/user/api.go#L320-L320 | group user declared L317 |
| `POST` | `/v1/user/device_badge` | 来源: modules/user/api.go#L321-L321 | group user declared L317 |
| `GET` | `/v1/user/grant_login` | 来源: modules/user/api.go#L322-L322 | group user declared L317 |
| `GET` | `/v1/user/current` | 来源: modules/user/api.go#L323-L323 | group user declared L317 |
| `PUT` | `/v1/user/current` | 来源: modules/user/api.go#L324-L324 | group user declared L317 |
| `PUT` | `/v1/user/language` | 来源: modules/user/api.go#L325-L325 | group user declared L317 |
| `GET` | `/v1/user/qrcode` | 来源: modules/user/api.go#L326-L326 | group user declared L317 |
| `PUT` | `/v1/user/my/setting` | 来源: modules/user/api.go#L327-L327 | group user declared L317 |
| `POST` | `/v1/user/blacklist/:uid` | 来源: modules/user/api.go#L328-L328 | group user declared L317 |
| `DELETE` | `/v1/user/blacklist/:uid` | 来源: modules/user/api.go#L329-L329 | group user declared L317 |
| `GET` | `/v1/user/blacklists` | 来源: modules/user/api.go#L330-L330 | group user declared L317 |
| `POST` | `/v1/user/chatpwd` | 来源: modules/user/api.go#L331-L331 | group user declared L317 |
| `POST` | `/v1/user/lockscreenpwd` | 来源: modules/user/api.go#L332-L332 | group user declared L317 |
| `PUT` | `/v1/user/lock_after_minute` | 来源: modules/user/api.go#L333-L333 | group user declared L317 |
| `DELETE` | `/v1/user/lockscreenpwd` | 来源: modules/user/api.go#L334-L334 | group user declared L317 |
| `GET` | `/v1/user/customerservices` | 来源: modules/user/api.go#L335-L335 | group user declared L317 |
| `DELETE` | `/v1/user/destroy/:code` | 来源: modules/user/api.go#L336-L336 | group user declared L317 |
| `POST` | `/v1/user/sms/destroy` | 来源: modules/user/api.go#L337-L337 | group user declared L317 |
| `POST` | `/v1/user/destroy/apply` | 来源: modules/user/api.go#L338-L338 | group user declared L317 |
| `POST` | `/v1/user/destroy/cancel` | 来源: modules/user/api.go#L339-L339 | group user declared L317 |
| `GET` | `/v1/user/destroy/status` | 来源: modules/user/api.go#L340-L340 | group user declared L317 |
| `PUT` | `/v1/user/updatepassword` | 来源: modules/user/api.go#L341-L341 | group user declared L317 |
| `POST` | `/v1/user/web3publickey` | 来源: modules/user/api.go#L342-L342 | group user declared L317 |
| `POST` | `/v1/user/quit` | 来源: modules/user/api.go#L343-L343 | group user declared L317 |
| `GET` | `/v1/user/devices` | 来源: modules/user/api.go#L345-L345 | group user declared L317 |
| `DELETE` | `/v1/user/devices/:device_id` | 来源: modules/user/api.go#L346-L346 | group user declared L317 |
| `GET` | `/v1/user/devices/:device_id` | 来源: modules/user/api.go#L347-L347 | group user declared L317 |
| `GET` | `/v1/user/online` | 来源: modules/user/api.go#L348-L348 | group user declared L317 |
| `POST` | `/v1/user/online` | 来源: modules/user/api.go#L349-L349 | group user declared L317 |
| `POST` | `/v1/user/pc/quit` | 来源: modules/user/api.go#L350-L350 | group user declared L317 |
| `POST` | `/v1/user/maillist` | 来源: modules/user/api.go#L353-L353 | group user declared L317 |
| `GET` | `/v1/user/maillist` | 来源: modules/user/api.go#L354-L354 | group user declared L317 |
| `GET` | `/v1/user/reddot/:category` | 来源: modules/user/api.go#L357-L357 | group user declared L317 |
| `DELETE` | `/v1/user/reddot/:category` | 来源: modules/user/api.go#L358-L358 | group user declared L317 |
| `PUT` | `/v1/user/pinned/sort` | 来源: modules/user/api.go#L367-L367 | group pinned declared L362 |
| `GET` | `/v1/user/space/setting` | 来源: modules/user/api.go#L373-L373 | group spaceSetting declared L371 |
| `PUT` | `/v1/user/space/setting` | 来源: modules/user/api.go#L374-L374 | group spaceSetting declared L371 |
| `POST` | `/v1/user/register` | 来源: modules/user/api.go#L379-L379 | group v declared L376 |
| `POST` | `/v1/user/login` | 来源: modules/user/api.go#L380-L380 | group v declared L376 |
| `POST` | `/v1/user/usernamelogin` | 来源: modules/user/api.go#L381-L381 | group v declared L376 |
| `POST` | `/v1/user/usernameregister` | 来源: modules/user/api.go#L382-L382 | group v declared L376 |
| `POST` | `/v1/user/emaillogin` | 来源: modules/user/api.go#L383-L383 | group v declared L376 |
| `POST` | `/v1/user/emailregister` | 来源: modules/user/api.go#L384-L384 | group v declared L376 |
| `POST` | `/v1/user/email/sendcode` | 来源: modules/user/api.go#L385-L385 | group v declared L376 |
| `POST` | `/v1/user/email/forgetpwd` | 来源: modules/user/api.go#L386-L386 | group v declared L376 |
| `POST` | `/v1/user/pwdforget_web3` | 来源: modules/user/api.go#L388-L388 | group v declared L376 |
| `GET` | `/v1/user/web3verifytext` | 来源: modules/user/api.go#L389-L389 | group v declared L376 |
| `POST` | `/v1/user/web3verifysign` | 来源: modules/user/api.go#L390-L390 | group v declared L376 |
| `POST` | `/v1user/wxlogin` | 来源: modules/user/api.go#L391-L391 | group v declared L376 |
| `POST` | `/v1/user/sms/forgetpwd` | 来源: modules/user/api.go#L392-L392 | group v declared L376 |
| `POST` | `/v1/user/pwdforget` | 来源: modules/user/api.go#L393-L393 | group v declared L376 |
| `GET` | `/v1/users/:uid/avatar` | 来源: modules/user/api.go#L394-L394 | group v declared L376 |
| `GET` | `/v1/users/:uid/im` | 来源: modules/user/api.go#L395-L395 | group v declared L376 |
| `GET` | `/v1/user/loginuuid` | 来源: modules/user/api.go#L396-L396 | group v declared L376 |
| `GET` | `/v1/user/loginstatus` | 来源: modules/user/api.go#L397-L397 | group v declared L376 |
| `POST` | `/v1/user/sms/registercode` | 来源: modules/user/api.go#L398-L398 | group v declared L376 |
| `POST` | `/v1/user/login_authcode/:auth_code` | 来源: modules/user/api.go#L399-L399 | group v declared L376 |
| `POST` | `/v1/user/sms/login_check_phone` | 来源: modules/user/api.go#L400-L400 | group v declared L376 |
| `POST` | `/v1/user/login/check_phone` | 来源: modules/user/api.go#L401-L401 | group v declared L376 |
| `POST` | `/v1/auth/verify` | 来源: modules/user/api.go#L404-L404 | group v declared L376 |
| `POST` | `/v1/auth/verify-bot` | 来源: modules/user/api.go#L405-L405 | group v declared L376 |
| `POST` | `/v1/auth/verify-api-key` | 来源: modules/user/api.go#L406-L406 | group v declared L376 |
| `GET` | `/v1/user/thirdlogin/authcode` | 来源: modules/user/api.go#L412-L412 | group v declared L376 |
| `GET` | `/v1/user/thirdlogin/authstatus` | 来源: modules/user/api.go#L413-L413 | group v declared L376 |
| `GET` | `/v1/user/github` | 来源: modules/user/api.go#L415-L415 | group v declared L376 |
| `GET` | `/v1/user/oauth/github` | 来源: modules/user/api.go#L416-L416 | group v declared L376 |
| `GET` | `/v1/user/gitee` | 来源: modules/user/api.go#L418-L418 | group v declared L376 |
| `GET` | `/v1/user/oauth/gitee` | 来源: modules/user/api.go#L419-L419 | group v declared L376 |
| `GET` | `/v1/internal/verify-token` | 来源: modules/user/api.go#L437-L437 | group internal declared L435 |
| `POST` | `/v1/internal/verify-token` | 来源: modules/user/api.go#L438-L438 | group internal declared L435 |
| `Any` | `recover` | 来源: modules/user/api_emaillogin.go#L202-L202 | group zap |
| `POST` | `/v1/friend/apply` | 来源: modules/user/api_friend.go#L63-L63 | group friend declared L61 |
| `GET` | `/v1/friend/apply` | 来源: modules/user/api_friend.go#L64-L64 | group friend declared L61 |
| `DELETE` | `/v1/friend/apply/:to_uid` | 来源: modules/user/api_friend.go#L65-L65 | group friend declared L61 |
| `PUT` | `/v1/friend/refuse/:to_uid` | 来源: modules/user/api_friend.go#L66-L66 | group friend declared L61 |
| `POST` | `/v1/friend/sure` | 来源: modules/user/api_friend.go#L67-L67 | group friend declared L61 |
| `GET` | `/v1/friend/sync` | 来源: modules/user/api_friend.go#L68-L68 | group friend declared L61 |
| `GET` | `/v1/friend/search` | 来源: modules/user/api_friend.go#L69-L69 | group friend declared L61 |
| `PUT` | `/v1/friend/remark` | 来源: modules/user/api_friend.go#L70-L70 | group friend declared L61 |
| `DELETE` | `/v1/friends/:uid` | 来源: modules/user/api_friend.go#L74-L74 | group friends declared L72 |
| `Any` | `from_uid` | 来源: modules/user/api_friend.go#L757-L757 | group zap |
| `Any` | `vercode` | 来源: modules/user/api_friend.go#L763-L763 | group zap |
| `POST` | `/v1/manager/login` | 来源: modules/user/api_manager.go#L108-L108 | group user declared L106 |
| `POST` | `/v1/manager/login/send` | 来源: modules/user/api_manager.go#L109-L109 | group user declared L106 |
| `POST` | `/v1/manager/login/resend` | 来源: modules/user/api_manager.go#L110-L110 | group user declared L106 |
| `POST` | `/v1/manager/login/verify` | 来源: modules/user/api_manager.go#L111-L111 | group user declared L106 |
| `GET` | `/v1/manager/me` | 来源: modules/user/api_manager.go#L115-L115 | group auth declared L113 |
| `POST` | `/v1/manager/user/admin` | 来源: modules/user/api_manager.go#L116-L116 | group auth declared L113 |
| `GET` | `/v1/manager/user/admin` | 来源: modules/user/api_manager.go#L117-L117 | group auth declared L113 |
| `DELETE` | `/v1/manager/user/admin` | 来源: modules/user/api_manager.go#L118-L118 | group auth declared L113 |
| `PUT` | `/v1/manager/user/admin/email` | 来源: modules/user/api_manager.go#L119-L119 | group auth declared L113 |
| `POST` | `/v1/manager/user/add` | 来源: modules/user/api_manager.go#L120-L120 | group auth declared L113 |
| `POST` | `/v1/manager/user/resetpassword` | 来源: modules/user/api_manager.go#L121-L121 | group auth declared L113 |
| `GET` | `/v1/manager/user/list` | 来源: modules/user/api_manager.go#L122-L122 | group auth declared L113 |
| `GET` | `/v1/manager/user/friends` | 来源: modules/user/api_manager.go#L123-L123 | group auth declared L113 |
| `GET` | `/v1/manager/user/blacklist` | 来源: modules/user/api_manager.go#L124-L124 | group auth declared L113 |
| `GET` | `/v1/manager/user/disablelist` | 来源: modules/user/api_manager.go#L125-L125 | group auth declared L113 |
| `GET` | `/v1/manageruser/online` | 来源: modules/user/api_manager.go#L126-L126 | group auth declared L113 |
| `PUT` | `/v1/manager/user/liftban/:uid/:status` | 来源: modules/user/api_manager.go#L127-L127 | group auth declared L113 |
| `POST` | `/v1/manager/user/updatepassword` | 来源: modules/user/api_manager.go#L128-L128 | group auth declared L113 |
| `GET` | `/v1/manager/user/devices` | 来源: modules/user/api_manager.go#L129-L129 | group auth declared L113 |
| `POST` | `/v1/manager/user/phone_shadow_backfill` | 来源: modules/user/api_manager.go#L137-L137 | group auth declared L113 |
| `GET` | `/v1/manager/user/phone_shadow_backfill` | 来源: modules/user/api_manager.go#L138-L138 | group auth declared L113 |
| `GET` | `/dashboard-read` | 来源: modules/user/api_manager.go#L148-L148 | group fixedRole |
| `PUT` | `/:uid/dashboard-read` | 来源: modules/user/api_manager.go#L149-L149 | group fixedRole |
| `DELETE` | `/:uid/dashboard-read` | 来源: modules/user/api_manager.go#L150-L150 | group fixedRole |
| `GET` | `/market-admin` | 来源: modules/user/api_manager.go#L152-L152 | group fixedRole |
| `PUT` | `/:uid/market-admin` | 来源: modules/user/api_manager.go#L153-L153 | group fixedRole |
| `DELETE` | `/:uid/market-admin` | 来源: modules/user/api_manager.go#L154-L154 | group fixedRole |

## usersecret

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `PUT` | `/v1/manager/secrets/:secret_id` | 来源: modules/usersecret/api.go#L101-L101 | group mgr declared L97 |
| `DELETE` | `/v1/manager/secrets/:secret_id` | 来源: modules/usersecret/api.go#L102-L102 | group mgr declared L97 |
| `POST` | `/v1/bot/secrets/resolve` | 来源: modules/usersecret/api.go#L113-L113 | group r |

## voice_adapter

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/voice/transcribe` | 来源: modules/voice_adapter/adapter.go#L36-L36 | group auth declared L34 |
| `GET` | `/v1/voice/config` | 来源: modules/voice_adapter/adapter.go#L37-L37 | group auth declared L34 |
| `GET` | `/v1/voice/context` | 来源: modules/voice_adapter/adapter.go#L38-L38 | group auth declared L34 |
| `GET` | `/v1/voice/document/asr_service_doc` | 来源: modules/voice_adapter/adapter.go#L39-L39 | group auth declared L34 |
| `PUT` | `/v1/voice/local-config` | 来源: modules/voice_adapter/adapter.go#L40-L40 | group auth declared L34 |
| `GET` | `/v1/voice/local-config` | 来源: modules/voice_adapter/adapter.go#L41-L41 | group auth declared L34 |
| `DELETE` | `/v1/voice/local-config` | 来源: modules/voice_adapter/adapter.go#L42-L42 | group auth declared L34 |
| `POST` | `/v1/voice/local-config/reset` | 来源: modules/voice_adapter/adapter.go#L43-L43 | group auth declared L34 |

## webhook

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `POST` | `/v1/webhook` | 来源: modules/webhook/api.go#L150-L150 | group r |
| `POST` | `/v2/webhook` | 来源: modules/webhook/api.go#L152-L152 | group r |
| `POST` | `/v1/datasource` | 来源: modules/webhook/api.go#L154-L154 | group r |
| `POST` | `/v1/webhook/message/notify` | 来源: modules/webhook/api.go#L156-L156 | group r |
| `POST` | `/v1/webhook/github` | 来源: modules/webhook/api.go#L158-L158 | group r |
| `Any` | `msg` | 来源: modules/webhook/api.go#L470-L470 | group zap |
| `Any` | `type` | 来源: modules/webhook/api.go#L526-L526 | group zap |
| `Any` | `data` | 来源: modules/webhook/api.go#L681-L681 | group zap |
| `Any` | `cmd` | 来源: modules/webhook/api_datasource.go#L32-L32 | group zap |
| `Any` | `params` | 来源: modules/webhook/github.go#L14-L14 | group zap |
| `Any` | `data` | 来源: modules/webhook/push_mi.go#L90-L90 | group zap |

## workplace

| Method | Path | 来源 | 备注 |
|---|---|---|---|
| `GET` | `/v1/workplace/banner` | 来源: modules/workplace/api.go#L35-L35 | group auth declared L33 |
| `PUT` | `/v1/workplace/app/reorder` | 来源: modules/workplace/api.go#L36-L36 | group auth declared L33 |
| `GET` | `/v1/workplace/app/record` | 来源: modules/workplace/api.go#L37-L37 | group auth declared L33 |
| `GET` | `/v1/workplace/app` | 来源: modules/workplace/api.go#L38-L38 | group auth declared L33 |
| `POST` | `/v1/workplace/apps/:app_id` | 来源: modules/workplace/api.go#L39-L39 | group auth declared L33 |
| `DELETE` | `/v1/workplace/apps/:app_id` | 来源: modules/workplace/api.go#L40-L40 | group auth declared L33 |
| `POST` | `/v1/workplace/apps/:app_id/record` | 来源: modules/workplace/api.go#L41-L41 | group auth declared L33 |
| `DELETE` | `/v1/workplace/apps/:app_id/record` | 来源: modules/workplace/api.go#L42-L42 | group auth declared L33 |
| `GET` | `/v1/workplace/category` | 来源: modules/workplace/api.go#L43-L43 | group auth declared L33 |
| `GET` | `/v1/workplace/categorys/:category_no/app` | 来源: modules/workplace/api.go#L44-L44 | group auth declared L33 |
| `POST` | `/v1/manager/workplace/category` | 来源: modules/workplace/api_manager.go#L41-L41 | group auth declared L39 |
| `GET` | `/v1/manager/workplace/category` | 来源: modules/workplace/api_manager.go#L42-L42 | group auth declared L39 |
| `PUT` | `/v1/manager/workplace/category/reorder` | 来源: modules/workplace/api_manager.go#L43-L43 | group auth declared L39 |
| `DELETE` | `/v1/manager/workplace/categorys/:category_no` | 来源: modules/workplace/api_manager.go#L44-L44 | group auth declared L39 |
| `PUT` | `/v1/manager/workplace/categorys/:category_no` | 来源: modules/workplace/api_manager.go#L45-L45 | group auth declared L39 |
| `GET` | `/v1/manager/workplace/categorys/:category_no/app` | 来源: modules/workplace/api_manager.go#L46-L46 | group auth declared L39 |
| `PUT` | `/v1/manager/workplace/categorys/:category_no/app/reorder` | 来源: modules/workplace/api_manager.go#L47-L47 | group auth declared L39 |
| `POST` | `/v1/manager/workplace/categorys/:category_no/app` | 来源: modules/workplace/api_manager.go#L48-L48 | group auth declared L39 |
| `DELETE` | `/v1/manager/workplace/categorys/:category_no/apps/:app_id` | 来源: modules/workplace/api_manager.go#L49-L49 | group auth declared L39 |
| `POST` | `/v1/manager/workplace/app` | 来源: modules/workplace/api_manager.go#L50-L50 | group auth declared L39 |
| `GET` | `/v1/manager/workplace/app` | 来源: modules/workplace/api_manager.go#L51-L51 | group auth declared L39 |
| `PUT` | `/v1/manager/workplace/apps/:app_id` | 来源: modules/workplace/api_manager.go#L52-L52 | group auth declared L39 |
| `DELETE` | `/v1/manager/workplace/apps/:app_id` | 来源: modules/workplace/api_manager.go#L53-L53 | group auth declared L39 |
| `POST` | `/v1/manager/workplace/banner` | 来源: modules/workplace/api_manager.go#L54-L54 | group auth declared L39 |
| `GET` | `/v1/manager/workplace/banner` | 来源: modules/workplace/api_manager.go#L55-L55 | group auth declared L39 |
| `DELETE` | `/v1/manager/workplace/banners/:banner_no` | 来源: modules/workplace/api_manager.go#L56-L56 | group auth declared L39 |
| `PUT` | `/v1/manager/workplace/banners/:banner_no` | 来源: modules/workplace/api_manager.go#L57-L57 | group auth declared L39 |
| `PUT` | `/v1/manager/workplace/banner/reorder` | 来源: modules/workplace/api_manager.go#L58-L58 | group auth declared L39 |
