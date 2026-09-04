# 错误码全量索引（pkg/errcode + shared codes）

- Target commit: `49dc9fd97b49c6c9bad9a0abaefb0b48241e9601`
- Error code count: 461
- 说明：本索引用源码中 `codes.Register` / `register(codes.Code{...})` 块解析生成；HTTPStatus 以同一 Code 块内字段为准。

| ID | HTTPStatus | 来源 | 安全信息 |
|---|---|---|---|
| `err.server.agent_mail_gateway.bad_response` | `http.StatusBadGateway` | 来源: pkg/errcode/agent_mail_gateway.go#L36-L36 | Internal: true |
| `err.server.agent_mail_gateway.payload_too_large` | `http.StatusRequestEntityTooLarge` | 来源: pkg/errcode/agent_mail_gateway.go#L25-L25 |  |
| `err.server.agent_mail_gateway.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/agent_mail_gateway.go#L20-L20 |  |
| `err.server.agent_mail_gateway.space_required` | `http.StatusBadRequest` | 来源: pkg/errcode/agent_mail_gateway.go#L15-L15 |  |
| `err.server.agent_mail_gateway.unauthorized` | `http.StatusUnauthorized` | 来源: pkg/errcode/agent_mail_gateway.go#L10-L10 |  |
| `err.server.agent_mail_gateway.unavailable` | `http.StatusServiceUnavailable` | 来源: pkg/errcode/agent_mail_gateway.go#L30-L30 | Internal: true |
| `err.server.app_bot.id_conflict` | `http.StatusConflict` | 来源: pkg/errcode/app_bot.go#L53-L53 |  |
| `err.server.app_bot.id_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/app_bot.go#L34-L34 |  |
| `err.server.app_bot.im_token_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/app_bot.go#L87-L87 | Internal: true |
| `err.server.app_bot.internal` | `http.StatusInternalServerError` | 来源: pkg/errcode/app_bot.go#L95-L95 | Internal: true |
| `err.server.app_bot.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/app_bot.go#L44-L44 |  |
| `err.server.app_bot.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/app_bot.go#L70-L70 | Internal: true |
| `err.server.app_bot.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/app_bot.go#L26-L26 | SafeDetailKeys: []string{"field"} |
| `err.server.app_bot.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/app_bot.go#L79-L79 | Internal: true |
| `err.server.app_bot.token_rotation_conflict` | `http.StatusConflict` | 来源: pkg/errcode/app_bot.go#L60-L60 |  |
| `err.server.bot.occupied` | `http.StatusConflict` | 来源: pkg/errcode/integration.go#L31-L31 | SafeDetailKeys: []string{"occupied_by"} |
| `err.server.bot_api.app_bot_dm_only` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L165-L165 |  |
| `err.server.bot_api.app_bot_unsupported` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L158-L158 |  |
| `err.server.bot_api.auth_check_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/bot_api.go#L352-L352 | Internal: true |
| `err.server.bot_api.auth_failed` | `http.StatusUnauthorized` | 来源: pkg/errcode/bot_api.go#L286-L286 |  |
| `err.server.bot_api.bot_not_provisioned` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L94-L94 |  |
| `err.server.bot_api.bot_not_registered` | `http.StatusNotFound` | 来源: pkg/errcode/bot_api.go#L229-L229 |  |
| `err.server.bot_api.bot_unavailable` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L200-L200 |  |
| `err.server.bot_api.cannot_remove_privileged` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L144-L144 | SafeDetailKeys: []string{"uid"} |
| `err.server.bot_api.card_disabled` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L380-L380 |  |
| `err.server.bot_api.card_edit_forbidden` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L401-L401 |  |
| `err.server.bot_api.card_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L387-L387 |  |
| `err.server.bot_api.card_obo_forbidden` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L394-L394 |  |
| `err.server.bot_api.card_revision_clear_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L415-L415 |  |
| `err.server.bot_api.card_seq_conflict` | `http.StatusConflict` | 来源: pkg/errcode/bot_api.go#L408-L408 |  |
| `err.server.bot_api.content_too_large` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L45-L45 | SafeDetailKeys: []string{"field", "max_size", "max_bytes"} |
| `err.server.bot_api.conversation_not_started` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L179-L179 |  |
| `err.server.bot_api.file_too_large` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L53-L53 | SafeDetailKeys: []string{"max_size_kb", "max_mb"} |
| `err.server.bot_api.file_type_unsupported` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L70-L70 |  |
| `err.server.bot_api.group_disbanded` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L128-L128 |  |
| `err.server.bot_api.group_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/bot_api.go#L209-L209 |  |
| `err.server.bot_api.im_token_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/bot_api.go#L341-L341 | Internal: true |
| `err.server.bot_api.limit_exceeded` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L36-L36 | SafeDetailKeys: []string{"field", "max"} |
| `err.server.bot_api.member_not_human` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L78-L78 | SafeDetailKeys: []string{"field"} |
| `err.server.bot_api.message_edit_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L186-L186 |  |
| `err.server.bot_api.message_not_delivered` | `http.StatusConflict` | 来源: pkg/errcode/bot_api.go#L272-L272 |  |
| `err.server.bot_api.message_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/bot_api.go#L215-L215 |  |
| `err.server.bot_api.not_friend` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L172-L172 |  |
| `err.server.bot_api.not_group_admin` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L134-L134 |  |
| `err.server.bot_api.not_group_member` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L117-L117 |  |
| `err.server.bot_api.not_space_member` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L151-L151 |  |
| `err.server.bot_api.obo_channel_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/bot_api.go#L248-L248 |  |
| `err.server.bot_api.obo_grant_exists` | `http.StatusConflict` | 来源: pkg/errcode/bot_api.go#L258-L258 |  |
| `err.server.bot_api.obo_grant_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/bot_api.go#L235-L235 |  |
| `err.server.bot_api.obo_internal` | `http.StatusInternalServerError` | 来源: pkg/errcode/bot_api.go#L360-L360 | Internal: true |
| `err.server.bot_api.obo_mode_unsupported` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L101-L101 |  |
| `err.server.bot_api.obo_not_authorized` | `http.StatusForbidden` | 来源: pkg/errcode/bot_api.go#L193-L193 |  |
| `err.server.bot_api.obo_reserved_field` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L108-L108 |  |
| `err.server.bot_api.obo_scope_exists` | `http.StatusConflict` | 来源: pkg/errcode/bot_api.go#L265-L265 |  |
| `err.server.bot_api.obo_scope_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/bot_api.go#L241-L241 |  |
| `err.server.bot_api.payload_too_large` | `http.StatusRequestEntityTooLarge` | 来源: pkg/errcode/bot_api.go#L63-L63 | SafeDetailKeys: []string{"max_bytes"} |
| `err.server.bot_api.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/bot_api.go#L308-L308 | Internal: true |
| `err.server.bot_api.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L27-L27 | SafeDetailKeys: []string{"field"} |
| `err.server.bot_api.send_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/bot_api.go#L325-L325 | Internal: true |
| `err.server.bot_api.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/bot_api.go#L317-L317 | Internal: true |
| `err.server.bot_api.thread_channel_not_accepted` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_api.go#L86-L86 |  |
| `err.server.bot_api.upload_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/bot_api.go#L333-L333 | Internal: true |
| `err.server.bot_api.upstream_failed` | `http.StatusBadGateway` | 来源: pkg/errcode/bot_api.go#L296-L296 | Internal: true |
| `err.server.bot_api.user_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/bot_api.go#L222-L222 |  |
| `err.server.bot_mention.idempotency_conflict` | `http.StatusConflict` | 来源: pkg/errcode/bot_mention.go#L15-L15 |  |
| `err.server.bot_mention.in_progress` | `http.StatusConflict` | 来源: pkg/errcode/bot_mention.go#L10-L10 |  |
| `err.server.bot_mention.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/bot_mention.go#L20-L20 | Internal: true |
| `err.server.bot_provision.auth_failed` | `http.StatusUnauthorized` | 来源: pkg/errcode/bot_provision.go#L51-L51 |  |
| `err.server.bot_provision.bot_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/bot_provision.go#L71-L71 |  |
| `err.server.bot_provision.bot_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/bot_provision.go#L81-L81 |  |
| `err.server.bot_provision.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/bot_provision.go#L36-L36 | SafeDetailKeys: []string{"field"} |
| `err.server.bot_provision.space_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/bot_provision.go#L63-L63 |  |
| `err.server.botfather.already_friends` | `http.StatusConflict` | 来源: pkg/errcode/botfather.go#L118-L118 |  |
| `err.server.botfather.apply_exists` | `http.StatusConflict` | 来源: pkg/errcode/botfather.go#L111-L111 |  |
| `err.server.botfather.apply_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/botfather.go#L87-L87 |  |
| `err.server.botfather.apply_processed` | `http.StatusConflict` | 来源: pkg/errcode/botfather.go#L105-L105 |  |
| `err.server.botfather.auth_failed` | `http.StatusUnauthorized` | 来源: pkg/errcode/botfather.go#L143-L143 |  |
| `err.server.botfather.bot_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/botfather.go#L95-L95 |  |
| `err.server.botfather.bot_not_in_space` | `http.StatusForbidden` | 来源: pkg/errcode/botfather.go#L63-L63 |  |
| `err.server.botfather.cannot_apply_own_bot` | `http.StatusBadRequest` | 来源: pkg/errcode/botfather.go#L36-L36 |  |
| `err.server.botfather.not_owner` | `http.StatusForbidden` | 来源: pkg/errcode/botfather.go#L55-L55 |  |
| `err.server.botfather.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/botfather.go#L154-L154 | Internal: true |
| `err.server.botfather.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/botfather.go#L29-L29 | SafeDetailKeys: []string{"field"} |
| `err.server.botfather.robot_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/botfather.go#L81-L81 |  |
| `err.server.botfather.runtime_onboarding_config_invalid` | `http.StatusInternalServerError` | 来源: pkg/errcode/botfather.go#L179-L179 | Internal: true |
| `err.server.botfather.runtime_onboarding_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/botfather.go#L171-L171 | Internal: true |
| `err.server.botfather.runtime_onboarding_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/botfather.go#L71-L71 |  |
| `err.server.botfather.runtime_onboarding_space_required` | `http.StatusBadRequest` | 来源: pkg/errcode/botfather.go#L44-L44 | SafeDetailKeys: []string{"field"} |
| `err.server.botfather.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/botfather.go#L163-L163 | Internal: true |
| `err.server.botfather.username_taken` | `http.StatusConflict` | 来源: pkg/errcode/botfather.go#L126-L126 | SafeDetailKeys: []string{"username"} |
| `err.server.card_template_catalog.blocked` | `http.StatusConflict` | 来源: pkg/errcode/card_template_catalog.go#L48-L48 |  |
| `err.server.card_template_catalog.conflict` | `http.StatusConflict` | 来源: pkg/errcode/card_template_catalog.go#L26-L26 |  |
| `err.server.card_template_catalog.content_too_large` | `http.StatusRequestEntityTooLarge` | 来源: pkg/errcode/card_template_catalog.go#L21-L21 |  |
| `err.server.card_template_catalog.control_disabled` | `http.StatusServiceUnavailable` | 来源: pkg/errcode/card_template_catalog.go#L37-L37 | Internal: true |
| `err.server.card_template_catalog.forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/card_template_catalog.go#L10-L10 |  |
| `err.server.card_template_catalog.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/card_template_catalog.go#L15-L15 | SafeDetailKeys: []string{"category", "document"} |
| `err.server.card_template_catalog.state_conflict` | `http.StatusConflict` | 来源: pkg/errcode/card_template_catalog.go#L43-L43 |  |
| `err.server.card_template_catalog.unavailable` | `http.StatusServiceUnavailable` | 来源: pkg/errcode/card_template_catalog.go#L31-L31 | Internal: true |
| `err.server.category.default_immutable` | `http.StatusForbidden` | 来源: pkg/errcode/category.go#L72-L72 |  |
| `err.server.category.default_undeletable` | `http.StatusForbidden` | 来源: pkg/errcode/category.go#L77-L77 |  |
| `err.server.category.group_member_required` | `http.StatusForbidden` | 来源: pkg/errcode/category.go#L60-L60 |  |
| `err.server.category.group_space_missing` | `http.StatusBadRequest` | 来源: pkg/errcode/category.go#L42-L42 |  |
| `err.server.category.limit_exceeded` | `http.StatusConflict` | 来源: pkg/errcode/category.go#L95-L95 | SafeDetailKeys: []string{"max"} |
| `err.server.category.name_too_long` | `http.StatusBadRequest` | 来源: pkg/errcode/category.go#L26-L26 | SafeDetailKeys: []string{"field", "max_length"} |
| `err.server.category.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/category.go#L87-L87 |  |
| `err.server.category.permission_denied` | `http.StatusForbidden` | 来源: pkg/errcode/category.go#L67-L67 |  |
| `err.server.category.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/category.go#L106-L106 | Internal: true |
| `err.server.category.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/category.go#L20-L20 | SafeDetailKeys: []string{"field"} |
| `err.server.category.sort_list_duplicate` | `http.StatusBadRequest` | 来源: pkg/errcode/category.go#L37-L37 |  |
| `err.server.category.sort_list_mismatch` | `http.StatusBadRequest` | 来源: pkg/errcode/category.go#L32-L32 |  |
| `err.server.category.space_member_required` | `http.StatusForbidden` | 来源: pkg/errcode/category.go#L55-L55 |  |
| `err.server.category.space_mismatch` | `http.StatusBadRequest` | 来源: pkg/errcode/category.go#L47-L47 |  |
| `err.server.category.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/category.go#L115-L115 | Internal: true |
| `err.server.common.file_extension_not_allowlistable` | `http.StatusBadRequest` | 来源: pkg/errcode/common.go#L73-L73 | SafeDetailKeys: []string{"extension"} |
| `err.server.common.file_upload_size_ordering` | `http.StatusBadRequest` | 来源: pkg/errcode/common.go#L56-L56 | SafeDetailKeys: []string{"file_max_size_kb", "sticker_max_size_kb"} |
| `err.server.common.manager_mfa_smtp_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/common.go#L79-L79 |  |
| `err.server.common.oidc_initial_space_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/common.go#L101-L101 | SafeDetailKeys: []string{"field"} |
| `err.server.common.space_welcome_config_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/common.go#L17-L17 | SafeDetailKeys: []string{"field"} |
| `err.server.common.thread_archive_window_ordering` | `http.StatusBadRequest` | 来源: pkg/errcode/common.go#L38-L38 | SafeDetailKeys: []string{"archive_days", "recent_days"} |
| `err.server.file.extension_list_too_large` | `http.StatusBadRequest` | 来源: pkg/errcode/file.go#L53-L53 | SafeDetailKeys: []string{"max_entries", "got", "extension", "max_bytes", "got_bytes"} |
| `err.server.file.extension_list_too_long` | `http.StatusBadRequest` | 来源: pkg/errcode/file.go#L33-L33 | SafeDetailKeys: []string{"max_bytes", "got_bytes"} |
| `err.server.file.upload_too_large` | `http.StatusBadRequest` | 来源: pkg/errcode/file.go#L21-L21 | SafeDetailKeys: []string{"max_size_kb", "max_mb"} |
| `err.server.group.already_member` | `http.StatusConflict` | 来源: pkg/errcode/group.go#L192-L192 |  |
| `err.server.group.auth_code_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L53-L53 |  |
| `err.server.group.auth_code_user_mismatch` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L146-L146 |  |
| `err.server.group.bot_not_in_space` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L141-L141 |  |
| `err.server.group.bot_ownership_denied` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L136-L136 |  |
| `err.server.group.cannot_remove_admin` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L96-L96 |  |
| `err.server.group.cannot_remove_owner` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L101-L101 |  |
| `err.server.group.cannot_target_self` | `http.StatusConflict` | 来源: pkg/errcode/group.go#L187-L187 |  |
| `err.server.group.category_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L131-L131 |  |
| `err.server.group.category_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/group.go#L169-L169 |  |
| `err.server.group.category_space_mismatch` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L37-L37 |  |
| `err.server.group.creator_only` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L66-L66 |  |
| `err.server.group.creator_or_manager_only` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L76-L76 |  |
| `err.server.group.daily_create_limit` | `http.StatusTooManyRequests` | 来源: pkg/errcode/group.go#L213-L213 |  |
| `err.server.group.external_cannot_be_admin` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L106-L106 |  |
| `err.server.group.external_cannot_be_owner` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L111-L111 |  |
| `err.server.group.external_join_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L116-L116 |  |
| `err.server.group.file_helper_not_allowed` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L32-L32 |  |
| `err.server.group.group_md_content_too_large` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L47-L47 | SafeDetailKeys: []string{"field", "max_size"} |
| `err.server.group.invite_expired` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L58-L58 |  |
| `err.server.group.invite_mode_cannot_add` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L121-L121 |  |
| `err.server.group.invite_mode_cannot_join` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L126-L126 |  |
| `err.server.group.invite_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/group.go#L179-L179 |  |
| `err.server.group.invite_status_invalid` | `http.StatusConflict` | 来源: pkg/errcode/group.go#L197-L197 |  |
| `err.server.group.manager_only` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L71-L71 |  |
| `err.server.group.member_cannot_remove` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L91-L91 |  |
| `err.server.group.member_not_friend` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L27-L27 |  |
| `err.server.group.member_not_in_group` | `http.StatusNotFound` | 来源: pkg/errcode/group.go#L164-L164 |  |
| `err.server.group.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/group.go#L159-L159 |  |
| `err.server.group.not_group_member` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L81-L81 |  |
| `err.server.group.notify_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/group.go#L241-L241 | Internal: true |
| `err.server.group.qrcode_member_only` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L151-L151 |  |
| `err.server.group.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/group.go#L223-L223 | Internal: true |
| `err.server.group.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L21-L21 | SafeDetailKeys: []string{"field"} |
| `err.server.group.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/group.go#L232-L232 | Internal: true |
| `err.server.group.target_not_bot` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L42-L42 |  |
| `err.server.group.too_large_to_sync` | `http.StatusBadRequest` | 来源: pkg/errcode/group.go#L205-L205 |  |
| `err.server.group.transfer_target_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/group.go#L174-L174 |  |
| `err.server.group.view_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/group.go#L86-L86 |  |
| `err.server.incomingwebhook.mgmt_creator_left` | `http.StatusConflict` | 来源: pkg/errcode/incomingwebhook.go#L184-L184 |  |
| `err.server.incomingwebhook.mgmt_creator_quota_exceeded` | `http.StatusConflict` | 来源: pkg/errcode/incomingwebhook.go#L161-L161 |  |
| `err.server.incomingwebhook.mgmt_disabled` | `http.StatusForbidden` | 来源: pkg/errcode/incomingwebhook.go#L213-L213 |  |
| `err.server.incomingwebhook.mgmt_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/incomingwebhook.go#L102-L102 |  |
| `err.server.incomingwebhook.mgmt_group_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/incomingwebhook.go#L121-L121 |  |
| `err.server.incomingwebhook.mgmt_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/incomingwebhook.go#L141-L141 |  |
| `err.server.incomingwebhook.mgmt_operation_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/incomingwebhook.go#L202-L202 | Internal: true |
| `err.server.incomingwebhook.mgmt_query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/incomingwebhook.go#L192-L192 | Internal: true |
| `err.server.incomingwebhook.mgmt_quota_exceeded` | `http.StatusConflict` | 来源: pkg/errcode/incomingwebhook.go#L151-L151 |  |
| `err.server.incomingwebhook.mgmt_request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/incomingwebhook.go#L111-L111 | SafeDetailKeys: []string{"reason"} |
| `err.server.incomingwebhook.mgmt_thread_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/incomingwebhook.go#L133-L133 |  |
| `err.server.incomingwebhook.mgmt_total_quota_exceeded` | `http.StatusConflict` | 来源: pkg/errcode/incomingwebhook.go#L170-L170 |  |
| `err.server.incomingwebhook.push_delivery_failed` | `http.StatusBadGateway` | 来源: pkg/errcode/incomingwebhook.go#L71-L71 | Internal: true |
| `err.server.incomingwebhook.push_disabled` | `http.StatusNotFound` | 来源: pkg/errcode/incomingwebhook.go#L82-L82 |  |
| `err.server.incomingwebhook.push_payload_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/incomingwebhook.go#L50-L50 | SafeDetailKeys: []string{"reason"} |
| `err.server.incomingwebhook.push_payload_too_large` | `http.StatusRequestEntityTooLarge` | 来源: pkg/errcode/incomingwebhook.go#L63-L63 |  |
| `err.server.incomingwebhook.push_rate_limited` | `http.StatusTooManyRequests` | 来源: pkg/errcode/incomingwebhook.go#L36-L36 |  |
| `err.server.incomingwebhook.push_unauthorized` | `http.StatusUnauthorized` | 来源: pkg/errcode/incomingwebhook.go#L28-L28 |  |
| `err.server.integration.disabled` | `http.StatusForbidden` | 来源: pkg/errcode/integration.go#L15-L15 |  |
| `err.server.integration.idempotency_conflict` | `http.StatusConflict` | 来源: pkg/errcode/integration.go#L49-L49 |  |
| `err.server.integration.idempotency_in_flight` | `http.StatusConflict` | 来源: pkg/errcode/integration.go#L41-L41 |  |
| `err.server.integration.user_not_linked` | `http.StatusForbidden` | 来源: pkg/errcode/integration.go#L23-L23 |  |
| `err.server.message.banword_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/message.go#L121-L121 |  |
| `err.server.message.cannot_delete_self_conversation` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L52-L52 |  |
| `err.server.message.card_action_denied` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L203-L203 |  |
| `err.server.message.card_action_in_progress` | `http.StatusConflict` | 来源: pkg/errcode/message.go#L212-L212 |  |
| `err.server.message.card_action_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L196-L196 |  |
| `err.server.message.card_edit_forbidden` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L188-L188 |  |
| `err.server.message.card_revision_denied` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L226-L226 |  |
| `err.server.message.card_revision_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L219-L219 |  |
| `err.server.message.card_send_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L181-L181 |  |
| `err.server.message.channel_access_denied` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L57-L57 |  |
| `err.server.message.conversation_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L47-L47 |  |
| `err.server.message.delete_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L78-L78 |  |
| `err.server.message.edit_own_only` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L93-L93 |  |
| `err.server.message.group_disbanded` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L73-L73 |  |
| `err.server.message.group_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/message.go#L111-L111 |  |
| `err.server.message.id_seq_mismatch` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L29-L29 |  |
| `err.server.message.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/message.go#L106-L106 |  |
| `err.server.message.not_friend` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L37-L37 |  |
| `err.server.message.not_group_member` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L62-L62 |  |
| `err.server.message.notify_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/message.go#L162-L162 | Internal: true |
| `err.server.message.peer_not_in_space` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L42-L42 |  |
| `err.server.message.pinned_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L88-L88 |  |
| `err.server.message.pinned_limit_exceeded` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L129-L129 | SafeDetailKeys: []string{"max"} |
| `err.server.message.proxy_send_unsupported` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L98-L98 |  |
| `err.server.message.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/message.go#L145-L145 | Internal: true |
| `err.server.message.reaction_unsupported_type` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L234-L234 |  |
| `err.server.message.recall_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/message.go#L83-L83 |  |
| `err.server.message.recall_time_exceeded` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L135-L135 |  |
| `err.server.message.receiver_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/message.go#L116-L116 |  |
| `err.server.message.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/message.go#L23-L23 | SafeDetailKeys: []string{"field"} |
| `err.server.message.search_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/message.go#L170-L170 | Internal: true |
| `err.server.message.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/message.go#L154-L154 | Internal: true |
| `err.server.messages_search.depth_exceeded` | `http.StatusBadRequest` | 来源: pkg/errcode/messages_search.go#L76-L76 | SafeDetailKeys: []string{"max_depth"} |
| `err.server.messages_search.disabled` | `http.StatusServiceUnavailable` | 来源: pkg/errcode/messages_search.go#L63-L63 |  |
| `err.server.messages_search.internal` | `http.StatusInternalServerError` | 来源: pkg/errcode/messages_search.go#L34-L34 | Internal: true |
| `err.server.messages_search.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/messages_search.go#L50-L50 | SafeDetailKeys: []string{"resource"} |
| `err.server.messages_search.rate_limited` | `http.StatusTooManyRequests` | 来源: pkg/errcode/messages_search.go#L42-L42 | SafeDetailKeys: []string{"retry_after"} |
| `err.server.messages_search.upstream_unavailable` | `http.StatusServiceUnavailable` | 来源: pkg/errcode/messages_search.go#L26-L26 | Internal: true |
| `err.server.messages_search.validation_failed` | `http.StatusBadRequest` | 来源: pkg/errcode/messages_search.go#L18-L18 | SafeDetailKeys: []string{"field", "reason", "max_length"} |
| `err.server.notification.pause.invalid_time` | `http.StatusBadRequest` | 来源: pkg/errcode/notification.go#L10-L10 |  |
| `err.server.notification.pause.update_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/notification.go#L15-L15 | Internal: true |
| `err.server.notify.card_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/notify.go#L15-L15 |  |
| `err.server.notify.card_mutate_failed` | `http.StatusConflict` | 来源: pkg/errcode/notify.go#L31-L31 |  |
| `err.server.notify.card_mutate_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/notify.go#L41-L41 |  |
| `err.server.notify.card_mutate_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/notify.go#L23-L23 |  |
| `err.server.notify.card_not_allowed` | `http.StatusBadRequest` | 来源: pkg/errcode/notify.go#L9-L9 |  |
| `err.server.oidc.bind_already_bound` | `http.StatusConflict` | 来源: pkg/errcode/oidc.go#L112-L112 |  |
| `err.server.oidc.bind_already_verified` | `http.StatusConflict` | 来源: pkg/errcode/oidc.go#L97-L97 |  |
| `err.server.oidc.bind_claims_incomplete` | `http.StatusUnprocessableEntity` | 来源: pkg/errcode/oidc.go#L142-L142 |  |
| `err.server.oidc.bind_conflict_need_manual` | `http.StatusConflict` | 来源: pkg/errcode/oidc.go#L120-L120 |  |
| `err.server.oidc.bind_invalid_credentials` | `http.StatusUnauthorized` | 来源: pkg/errcode/oidc.go#L79-L79 |  |
| `err.server.oidc.bind_method_disabled` | `http.StatusBadRequest` | 来源: pkg/errcode/oidc.go#L68-L68 |  |
| `err.server.oidc.bind_request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/oidc.go#L52-L52 |  |
| `err.server.oidc.bind_service_unavailable` | `http.StatusServiceUnavailable` | 来源: pkg/errcode/oidc.go#L40-L40 | Internal: true |
| `err.server.oidc.bind_sms_unavailable` | `http.StatusBadRequest` | 来源: pkg/errcode/oidc.go#L60-L60 |  |
| `err.server.oidc.bind_status_conflict` | `http.StatusConflict` | 来源: pkg/errcode/oidc.go#L104-L104 |  |
| `err.server.oidc.bind_token_invalid` | `http.StatusGone` | 来源: pkg/errcode/oidc.go#L131-L131 |  |
| `err.server.oidc.bind_verify_required` | `http.StatusUnauthorized` | 来源: pkg/errcode/oidc.go#L87-L87 |  |
| `err.server.oidc.exchange_request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/oidc.go#L153-L153 |  |
| `err.server.oidc.exchange_token_rejected` | `http.StatusUnauthorized` | 来源: pkg/errcode/oidc.go#L165-L165 |  |
| `err.server.opanalytics.etl_already_running` | `http.StatusConflict` | 来源: pkg/errcode/opanalytics.go#L35-L35 |  |
| `err.server.opanalytics.etl_trigger_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/opanalytics.go#L40-L40 | Internal: true |
| `err.server.opanalytics.forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/opanalytics.go#L13-L13 |  |
| `err.server.opanalytics.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/opanalytics.go#L24-L24 |  |
| `err.server.opanalytics.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/opanalytics.go#L29-L29 | Internal: true |
| `err.server.opanalytics.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/opanalytics.go#L18-L18 | SafeDetailKeys: []string{"reason"} |
| `err.server.qrcode.group_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/qrcode.go#L38-L38 |  |
| `err.server.qrcode.group_space_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/qrcode.go#L43-L43 |  |
| `err.server.qrcode.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/qrcode.go#L28-L28 |  |
| `err.server.qrcode.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/qrcode.go#L48-L48 | Internal: true |
| `err.server.qrcode.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/qrcode.go#L11-L11 | SafeDetailKeys: []string{"field"} |
| `err.server.qrcode.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/qrcode.go#L54-L54 | Internal: true |
| `err.server.qrcode.token_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/qrcode.go#L23-L23 |  |
| `err.server.qrcode.token_required` | `http.StatusBadRequest` | 来源: pkg/errcode/qrcode.go#L17-L17 | SafeDetailKeys: []string{"field"} |
| `err.server.qrcode.user_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/qrcode.go#L33-L33 |  |
| `err.server.report.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/report.go#L23-L23 | Internal: true |
| `err.server.report.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/report.go#L12-L12 | SafeDetailKeys: []string{"field"} |
| `err.server.report.session_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/report.go#L18-L18 |  |
| `err.server.report.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/report.go#L29-L29 | Internal: true |
| `err.server.robot.auth_check_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/robot.go#L186-L186 | Internal: true |
| `err.server.robot.auth_failed` | `http.StatusUnauthorized` | 来源: pkg/errcode/robot.go#L119-L119 |  |
| `err.server.robot.card_edit_forbidden` | `http.StatusBadRequest` | 来源: pkg/errcode/robot.go#L204-L204 |  |
| `err.server.robot.channel_send_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/robot.go#L85-L85 |  |
| `err.server.robot.content_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/robot.go#L31-L31 | SafeDetailKeys: []string{"field"} |
| `err.server.robot.content_type_unsupported` | `http.StatusBadRequest` | 来源: pkg/errcode/robot.go#L38-L38 | SafeDetailKeys: []string{"type"} |
| `err.server.robot.creator_only` | `http.StatusForbidden` | 来源: pkg/errcode/robot.go#L72-L72 |  |
| `err.server.robot.file_too_large` | `http.StatusBadRequest` | 来源: pkg/errcode/robot.go#L52-L52 | SafeDetailKeys: []string{"max_size_kb", "max_mb"} |
| `err.server.robot.file_type_unsupported` | `http.StatusBadRequest` | 来源: pkg/errcode/robot.go#L45-L45 |  |
| `err.server.robot.group_disbanded` | `http.StatusForbidden` | 来源: pkg/errcode/robot.go#L197-L197 |  |
| `err.server.robot.inline_query_timeout` | `http.StatusRequestTimeout` | 来源: pkg/errcode/robot.go#L130-L130 |  |
| `err.server.robot.message_edit_forbidden` | `http.StatusForbidden` | 来源: pkg/errcode/robot.go#L79-L79 |  |
| `err.server.robot.message_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/robot.go#L102-L102 |  |
| `err.server.robot.no_fields_to_update` | `http.StatusBadRequest` | 来源: pkg/errcode/robot.go#L61-L61 |  |
| `err.server.robot.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/robot.go#L96-L96 |  |
| `err.server.robot.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/robot.go#L141-L141 | Internal: true |
| `err.server.robot.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/robot.go#L20-L20 | SafeDetailKeys: []string{"field"} |
| `err.server.robot.send_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/robot.go#L158-L158 | Internal: true |
| `err.server.robot.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/robot.go#L150-L150 | Internal: true |
| `err.server.robot.token_gen_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/robot.go#L175-L175 | Internal: true |
| `err.server.robot.upload_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/robot.go#L167-L167 | Internal: true |
| `err.server.search.group_query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/search.go#L23-L23 | Internal: true |
| `err.server.search.message_query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/search.go#L17-L17 | Internal: true |
| `err.server.search.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/search.go#L11-L11 | SafeDetailKeys: []string{"field"} |
| `err.server.search.user_query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/search.go#L29-L29 | Internal: true |
| `err.server.space.already_member` | `http.StatusConflict` | 来源: pkg/errcode/space.go#L120-L120 |  |
| `err.server.space.apply_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/space.go#L78-L78 |  |
| `err.server.space.apply_processed` | `http.StatusConflict` | 来源: pkg/errcode/space.go#L127-L127 |  |
| `err.server.space.batch_too_large` | `http.StatusBadRequest` | 来源: pkg/errcode/space.go#L37-L37 | SafeDetailKeys: []string{"max"} |
| `err.server.space.creation_disabled` | `http.StatusForbidden` | 来源: pkg/errcode/space.go#L61-L61 |  |
| `err.server.space.email_invite_email_mismatch` | `http.StatusForbidden` | 来源: pkg/errcode/space.go#L181-L181 |  |
| `err.server.space.email_invite_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/space.go#L167-L167 |  |
| `err.server.space.email_invite_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/space.go#L158-L158 |  |
| `err.server.space.email_invite_processed` | `http.StatusConflict` | 来源: pkg/errcode/space.go#L174-L174 |  |
| `err.server.space.field_too_long` | `http.StatusBadRequest` | 来源: pkg/errcode/space.go#L30-L30 | SafeDetailKeys: []string{"field", "max_chars"} |
| `err.server.space.full` | `http.StatusConflict` | 来源: pkg/errcode/space.go#L133-L133 |  |
| `err.server.space.immutable` | `http.StatusConflict` | 来源: pkg/errcode/space.go#L140-L140 |  |
| `err.server.space.invite_code_exhausted` | `http.StatusConflict` | 来源: pkg/errcode/space.go#L113-L113 |  |
| `err.server.space.invite_code_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/space.go#L103-L103 |  |
| `err.server.space.invite_code_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/space.go#L84-L84 |  |
| `err.server.space.member_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/space.go#L91-L91 |  |
| `err.server.space.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/space.go#L70-L70 |  |
| `err.server.space.not_member` | `http.StatusForbidden` | 来源: pkg/errcode/space.go#L55-L55 |  |
| `err.server.space.owner_constraint` | `http.StatusConflict` | 来源: pkg/errcode/space.go#L148-L148 |  |
| `err.server.space.permission_denied` | `http.StatusForbidden` | 来源: pkg/errcode/space.go#L49-L49 |  |
| `err.server.space.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/space.go#L192-L192 | Internal: true |
| `err.server.space.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/space.go#L21-L21 | SafeDetailKeys: []string{"field"} |
| `err.server.space.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/space.go#L201-L201 | Internal: true |
| `err.server.statistics.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/statistics.go#L17-L17 | Internal: true |
| `err.server.statistics.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/statistics.go#L11-L11 | SafeDetailKeys: []string{"field"} |
| `err.server.sticker.format_unsupported` | `http.StatusBadRequest` | 来源: pkg/errcode/sticker.go#L29-L29 | SafeDetailKeys: []string{"field", "format"} |
| `err.server.sticker.keywords_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/sticker.go#L41-L41 | SafeDetailKeys: []string{"field"} |
| `err.server.sticker.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/sticker.go#L52-L52 |  |
| `err.server.sticker.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/sticker.go#L81-L81 | Internal: true |
| `err.server.sticker.quota_exceeded` | `http.StatusConflict` | 来源: pkg/errcode/sticker.go#L64-L64 | SafeDetailKeys: []string{"max"} |
| `err.server.sticker.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/sticker.go#L20-L20 | SafeDetailKeys: []string{"field"} |
| `err.server.sticker.shortcode_conflict` | `http.StatusConflict` | 来源: pkg/errcode/sticker.go#L70-L70 | SafeDetailKeys: []string{"field"} |
| `err.server.sticker.shortcode_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/sticker.go#L35-L35 | SafeDetailKeys: []string{"field"} |
| `err.server.sticker.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/sticker.go#L89-L89 | Internal: true |
| `err.server.thread.creator_cannot_leave` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L82-L82 |  |
| `err.server.thread.deleted` | `http.StatusGone` | 来源: pkg/errcode/server.go#L67-L67 |  |
| `err.server.thread.group_disbanded` | `http.StatusForbidden` | 来源: pkg/errcode/server.go#L52-L52 |  |
| `err.server.thread.group_md_content_empty` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L92-L92 | SafeDetailKeys: []string{"field"} |
| `err.server.thread.group_md_content_too_large` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L98-L98 | SafeDetailKeys: []string{"field", "max_size"} |
| `err.server.thread.group_md_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/server.go#L87-L87 |  |
| `err.server.thread.group_no_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L11-L11 | SafeDetailKeys: []string{"field"} |
| `err.server.thread.name_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L29-L29 | SafeDetailKeys: []string{"field", "max_length"} |
| `err.server.thread.not_active` | `http.StatusConflict` | 来源: pkg/errcode/server.go#L72-L72 |  |
| `err.server.thread.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/server.go#L62-L62 |  |
| `err.server.thread.not_group_member` | `http.StatusForbidden` | 来源: pkg/errcode/server.go#L47-L47 |  |
| `err.server.thread.permission_denied` | `http.StatusForbidden` | 来源: pkg/errcode/server.go#L57-L57 |  |
| `err.server.thread.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L23-L23 | SafeDetailKeys: []string{"field", "max_size"} |
| `err.server.thread.setting_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L104-L104 | SafeDetailKeys: []string{"field"} |
| `err.server.thread.short_id_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L17-L17 | SafeDetailKeys: []string{"field"} |
| `err.server.thread.source_message_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L35-L35 | SafeDetailKeys: []string{"field", "max_size"} |
| `err.server.thread.status_changed` | `http.StatusConflict` | 来源: pkg/errcode/server.go#L77-L77 |  |
| `err.server.thread.status_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/server.go#L41-L41 | SafeDetailKeys: []string{"field"} |
| `err.server.thread.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/server.go#L110-L110 | Internal: true |
| `err.server.user.account_banned` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L73-L73 |  |
| `err.server.user.account_destroyed` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L147-L147 |  |
| `err.server.user.account_destroying` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L152-L152 |  |
| `err.server.user.account_state_changed` | `http.StatusConflict` | 来源: pkg/errcode/user.go#L483-L483 |  |
| `err.server.user.account_unavailable` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L565-L565 |  |
| `err.server.user.already_exists` | `http.StatusConflict` | 来源: pkg/errcode/user.go#L111-L111 |  |
| `err.server.user.already_friend` | `http.StatusConflict` | 来源: pkg/errcode/user.go#L437-L437 |  |
| `err.server.user.api_key_invalid` | `http.StatusUnauthorized` | 来源: pkg/errcode/user.go#L63-L63 |  |
| `err.server.user.auth_code_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/user.go#L179-L179 |  |
| `err.server.user.auth_code_wrong_type` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L184-L184 |  |
| `err.server.user.auth_info_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L189-L189 | SafeDetailKeys: []string{"missing_field"} |
| `err.server.user.auth_scanner_mismatch` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L195-L195 |  |
| `err.server.user.bot_not_in_space` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L442-L442 |  |
| `err.server.user.cannot_add_self` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L432-L432 |  |
| `err.server.user.cannot_delete_super_admin` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L369-L369 |  |
| `err.server.user.channel_access_denied` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L511-L511 |  |
| `err.server.user.chat_pwd_update_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L229-L229 | Internal: true |
| `err.server.user.code_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L68-L68 |  |
| `err.server.user.current_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/user.go#L101-L101 |  |
| `err.server.user.dashboard_reader_target_ineligible` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L374-L374 |  |
| `err.server.user.decode_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L274-L274 | Internal: true |
| `err.server.user.demo_lock_unsupported` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L171-L171 |  |
| `err.server.user.destroy_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L292-L292 | Internal: true |
| `err.server.user.device_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/user.go#L106-L106 |  |
| `err.server.user.email_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L547-L547 |  |
| `err.server.user.email_login_disabled` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L557-L557 |  |
| `err.server.user.email_rate_limited` | `http.StatusTooManyRequests` | 来源: pkg/errcode/user.go#L579-L579 |  |
| `err.server.user.email_register_disabled` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L552-L552 |  |
| `err.server.user.email_send_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L570-L570 | Internal: true |
| `err.server.user.file_operation_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L280-L280 | Internal: true |
| `err.server.user.friend_apply_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L460-L460 |  |
| `err.server.user.friend_apply_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/user.go#L447-L447 |  |
| `err.server.user.friend_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/user.go#L452-L452 |  |
| `err.server.user.im_call_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L268-L268 | Internal: true |
| `err.server.user.invalid_credentials` | `http.StatusUnauthorized` | 来源: pkg/errcode/user.go#L54-L54 |  |
| `err.server.user.invite_code_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/user.go#L139-L139 |  |
| `err.server.user.language_set_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L304-L304 | Internal: true |
| `err.server.user.language_unsupported` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L40-L40 |  |
| `err.server.user.list_filter_conflict` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L396-L396 | SafeDetailKeys: []string{"filter", "conflicts_with"} |
| `err.server.user.local_login_disabled` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L124-L124 |  |
| `err.server.user.lock_minute_out_of_range` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L29-L29 | SafeDetailKeys: []string{"field", "min", "max"} |
| `err.server.user.lock_screen_pwd_update_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L241-L241 | Internal: true |
| `err.server.user.login_device_expired` | `http.StatusUnauthorized` | 来源: pkg/errcode/user.go#L78-L78 |  |
| `err.server.user.login_locked` | `http.StatusTooManyRequests` | 来源: pkg/errcode/user.go#L88-L88 |  |
| `err.server.user.login_pwd_update_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L235-L235 | Internal: true |
| `err.server.user.manager_email_mfa_enable_email_required` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L625-L625 |  |
| `err.server.user.manager_mfa_challenge_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L599-L599 |  |
| `err.server.user.manager_mfa_code_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L604-L604 |  |
| `err.server.user.manager_mfa_misconfigured` | `http.StatusServiceUnavailable` | 来源: pkg/errcode/user.go#L593-L593 | Internal: true |
| `err.server.user.manager_mfa_rate_limited` | `http.StatusTooManyRequests` | 来源: pkg/errcode/user.go#L609-L609 | SafeDetailKeys: []string{"retry_after"} |
| `err.server.user.manager_mfa_settings_unavailable` | `http.StatusServiceUnavailable` | 来源: pkg/errcode/user.go#L587-L587 | Internal: true |
| `err.server.user.manager_mfa_verify_locked` | `http.StatusTooManyRequests` | 来源: pkg/errcode/user.go#L619-L619 | SafeDetailKeys: []string{"retry_after"} |
| `err.server.user.manager_permission_required` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L321-L321 |  |
| `err.server.user.manager_role_changed` | `http.StatusConflict` | 来源: pkg/errcode/user.go#L388-L388 |  |
| `err.server.user.manager_role_target_ineligible` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L383-L383 |  |
| `err.server.user.new_password_same_as_old` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L357-L357 |  |
| `err.server.user.not_admin_account` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L364-L364 |  |
| `err.server.user.not_destroying` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L488-L488 |  |
| `err.server.user.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/user.go#L96-L96 |  |
| `err.server.user.oauth_exchange_failed` | `http.StatusBadGateway` | 来源: pkg/errcode/user.go#L529-L529 | Internal: true |
| `err.server.user.oauth_profile_failed` | `http.StatusBadGateway` | 来源: pkg/errcode/user.go#L535-L535 | Internal: true |
| `err.server.user.oauth_state_expired` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L524-L524 |  |
| `err.server.user.old_password_incorrect` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L352-L352 |  |
| `err.server.user.password_incorrect` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L475-L475 |  |
| `err.server.user.password_mismatch` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L347-L347 |  |
| `err.server.user.password_not_set` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L470-L470 |  |
| `err.server.user.password_process_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L247-L247 | Internal: true |
| `err.server.user.password_too_long` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L342-L342 |  |
| `err.server.user.password_too_short` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L326-L326 |  |
| `err.server.user.password_too_weak` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L334-L334 |  |
| `err.server.user.phone_region_unsupported` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L134-L134 |  |
| `err.server.user.pinned_already_exists` | `http.StatusConflict` | 来源: pkg/errcode/user.go#L496-L496 |  |
| `err.server.user.pinned_limit_exceeded` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L501-L501 | SafeDetailKeys: []string{"max"} |
| `err.server.user.pinned_sort_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L516-L516 |  |
| `err.server.user.public_key_already_exists` | `http.StatusConflict` | 来源: pkg/errcode/user.go#L653-L653 |  |
| `err.server.user.public_key_not_found` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L648-L648 |  |
| `err.server.user.qr_ver_code_missing` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L200-L200 |  |
| `err.server.user.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L256-L256 | Internal: true |
| `err.server.user.register_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L298-L298 | Internal: true |
| `err.server.user.registration_closed` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L119-L119 |  |
| `err.server.user.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L23-L23 | SafeDetailKeys: []string{"field"} |
| `err.server.user.role_cache_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L413-L413 | Internal: true |
| `err.server.user.scan_login_disabled` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L129-L129 |  |
| `err.server.user.short_no_already_changed` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L166-L166 |  |
| `err.server.user.short_no_format_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L35-L35 |  |
| `err.server.user.short_no_gen_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L419-L419 | Internal: true |
| `err.server.user.signature_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L665-L665 |  |
| `err.server.user.signature_not_found` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L660-L660 |  |
| `err.server.user.sms_send_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L286-L286 | Internal: true |
| `err.server.user.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L262-L262 | Internal: true |
| `err.server.user.token_cache_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/user.go#L407-L407 | Internal: true |
| `err.server.user.token_required` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L45-L45 | SafeDetailKeys: []string{"field"} |
| `err.server.user.update_not_allowed` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L160-L160 | SafeDetailKeys: []string{"field"} |
| `err.server.user.username_format_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L643-L643 |  |
| `err.server.user.username_register_disabled` | `http.StatusForbidden` | 来源: pkg/errcode/user.go#L638-L638 |  |
| `err.server.user.verify_type_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/user.go#L670-L670 |  |
| `err.server.user.wechat_exchange_failed` | `http.StatusBadGateway` | 来源: pkg/errcode/user.go#L208-L208 | Internal: true |
| `err.server.user.wechat_profile_failed` | `http.StatusBadGateway` | 来源: pkg/errcode/user.go#L214-L214 | Internal: true |
| `err.server.user.wechat_response_invalid` | `http.StatusBadGateway` | 来源: pkg/errcode/user.go#L220-L220 | Internal: true |
| `err.server.usersecret.ambiguous` | `http.StatusUnprocessableEntity` | 来源: pkg/errcode/usersecret.go#L64-L64 | SafeDetailKeys: []string{"candidates"} |
| `err.server.usersecret.duplicate_name` | `http.StatusConflict` | 来源: pkg/errcode/usersecret.go#L53-L53 |  |
| `err.server.usersecret.not_found` | `http.StatusNotFound` | 来源: pkg/errcode/usersecret.go#L44-L44 |  |
| `err.server.usersecret.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/usersecret.go#L23-L23 | SafeDetailKeys: []string{"field"} |
| `err.server.usersecret.resolve_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/usersecret.go#L75-L75 | Internal: true |
| `err.server.usersecret.unauthorized` | `http.StatusUnauthorized` | 来源: pkg/errcode/usersecret.go#L34-L34 |  |
| `err.server.workplace.app_name_exists` | `http.StatusConflict` | 来源: pkg/errcode/workplace.go#L45-L45 |  |
| `err.server.workplace.app_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/workplace.go#L32-L32 |  |
| `err.server.workplace.category_name_exists` | `http.StatusConflict` | 来源: pkg/errcode/workplace.go#L50-L50 |  |
| `err.server.workplace.category_not_found` | `http.StatusNotFound` | 来源: pkg/errcode/workplace.go#L37-L37 |  |
| `err.server.workplace.query_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/workplace.go#L60-L60 | Internal: true |
| `err.server.workplace.request_invalid` | `http.StatusBadRequest` | 来源: pkg/errcode/workplace.go#L21-L21 | SafeDetailKeys: []string{"field"} |
| `err.server.workplace.store_failed` | `http.StatusInternalServerError` | 来源: pkg/errcode/workplace.go#L68-L68 | Internal: true |
| `err.shared.auth.forbidden` | `http.StatusForbidden` | 来源: pkg/i18n/codes/shared.go#L58-L58 |  |
| `err.shared.auth.required` | `http.StatusUnauthorized` | 来源: pkg/i18n/codes/shared.go#L22-L22 |  |
| `err.shared.auth.token_expired` | `http.StatusUnauthorized` | 来源: pkg/i18n/codes/shared.go#L49-L49 |  |
| `err.shared.auth.token_invalid` | `http.StatusUnauthorized` | 来源: pkg/i18n/codes/shared.go#L40-L40 |  |
| `err.shared.auth.token_missing` | `http.StatusUnauthorized` | 来源: pkg/i18n/codes/shared.go#L31-L31 |  |
| `err.shared.internal` | `http.StatusInternalServerError` | 来源: pkg/i18n/codes/shared.go#L98-L98 | Internal: true |
| `err.shared.not_found` | `http.StatusNotFound` | 来源: pkg/i18n/codes/shared.go#L87-L87 |  |
| `err.shared.param.invalid` | `http.StatusBadRequest` | 来源: pkg/i18n/codes/shared.go#L77-L77 | SafeDetailKeys: []string{"field"} |
| `err.shared.rate.limited` | `http.StatusTooManyRequests` | 来源: pkg/i18n/codes/shared.go#L67-L67 | SafeDetailKeys: []string{"retry_after"} |
