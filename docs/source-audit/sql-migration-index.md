# SQL Migration 全量索引

- Target commit: `49dc9fd97b49c6c9bad9a0abaefb0b48241e9601`
- SQL migration count: 202

## app_bot

- `modules/app_bot/sql/20260505000001_app_bot_legacy01.sql`
- `modules/app_bot/sql/20260508000001_app_bot_legacy01.sql`
- `modules/app_bot/sql/20260509000001_app_bot_legacy01.sql`
- `modules/app_bot/sql/20260510000001_app_bot_legacy01.sql`
- `modules/app_bot/sql/20260510000002_app_bot_legacy02.sql`

## backup

- `modules/backup/sql/20260331000001_backup_legacy01.sql`
- `modules/backup/sql/20260401000001_backup_legacy01.sql`

## base

- `modules/base/sql/20191106000001_event_legacy01.sql`
- `modules/base/sql/20201103000001_app_legacy01.sql`
- `modules/base/sql/20230912000001_app_legacy01.sql`
- `modules/base/sql/20250423000001_event_legacy01.sql`
- `modules/base/sql/20260512000001_base_oss_compat_repair.sql`
- `modules/base/sql/20260614000001_searchetl_init.sql`

## bot_api

- `modules/bot_api/sql/20260505000002_bot_api.sql`
- `modules/bot_api/sql/20260519000001_obo_v0.sql`
- `modules/bot_api/sql/20260521000001_obo_v2_persona_prompt.sql`

## botfather

- `modules/botfather/sql/20260226000001_botfather_legacy01.sql`
- `modules/botfather/sql/20260318000001_botfather_legacy01.sql`
- `modules/botfather/sql/20260318000002_botfather_legacy02.sql`
- `modules/botfather/sql/20260324000001_botfather_legacy01.sql`
- `modules/botfather/sql/20260326000001_botfather_legacy01.sql`
- `modules/botfather/sql/20260417000001_botfather_legacy01.sql`
- `modules/botfather/sql/20260603000001_botfather_legacy01.sql`
- `modules/botfather/sql/20260603000002_botfather_legacy01.sql`
- `modules/botfather/sql/20260604000003_user_api_key_hash.sql`
- `modules/botfather/sql/20260903000001_botfather_agent_hosting.sql`

## card_template_catalog

- `modules/card_template_catalog/sql/20260728000001_card_template_catalog.sql`
- `modules/card_template_catalog/sql/20260728000002_card_template_catalog_activation.sql`

## category

- `modules/category/sql/20260403000001_category_legacy01.sql`
- `modules/category/sql/20260415000001_category_legacy01.sql`
- `modules/category/sql/20260416000001_category_legacy01.sql`
- `modules/category/sql/20260418000001_category_legacy01.sql`
- `modules/category/sql/20260428000001_category_legacy01.sql`

## channel

- `modules/channel/sql/20221124000001_channel_legacy01.sql`
- `modules/channel/sql/20230920000001_channel_legacy01.sql`
- `modules/channel/sql/20240515000001_channel_legacy01.sql`

## common

- `modules/common/sql/20210421000001_common_legacy01.sql`
- `modules/common/sql/20210818000001_common_legacy01.sql`
- `modules/common/sql/20211108000001_common_legacy01.sql`
- `modules/common/sql/20220908000001_common_legacy01.sql`
- `modules/common/sql/20220916000001_common_legacy01.sql`
- `modules/common/sql/20220917000001_common_legacy01.sql`
- `modules/common/sql/20221111000001_common_legacy01.sql`
- `modules/common/sql/20221114000001_common_legacy01.sql`
- `modules/common/sql/20230203000001_common_legacy01.sql`
- `modules/common/sql/20240418000001_common_legacy01.sql`
- `modules/common/sql/20240506000001_common_legacy01.sql`
- `modules/common/sql/20240510000001_common_legacy01.sql`
- `modules/common/sql/20240528000001_common_legacy01.sql`
- `modules/common/sql/20260408000001_common_legacy01.sql`
- `modules/common/sql/20260427000001_common_legacy01.sql`
- `modules/common/sql/20260518000001_common_legacy01.sql`
- `modules/common/sql/20260720000001_add_octo_space_welcome_config.sql`
- `modules/common/sql/20260723000001_add_octo_group_welcome_config.sql`

## conversation_ext

- `modules/conversation_ext/sql/20260513000001_conversation_ext_legacy01.sql`
- `modules/conversation_ext/sql/20260513000002_user_follow_version.sql`
- `modules/conversation_ext/sql/20260513000004_conversation_ext_indexes.sql`
- `modules/conversation_ext/sql/20260514000001_dm_category_id_to_varchar.sql`
- `modules/conversation_ext/sql/20260514000002_drop_user_conversation_ext_version.sql`
- `modules/conversation_ext/sql/20260522000001_user_conv_ext_auto_follow_threads.sql`
- `modules/conversation_ext/sql/20260522000002_user_conv_ext_auto_follow_covering.sql`

## group

- `modules/group/sql/20191106000002_group_legacy01.sql`
- `modules/group/sql/20211202000001_group_legacy02.sql`
- `modules/group/sql/20220411000001_group_legacy01.sql`
- `modules/group/sql/20220815000001_group_legacy01.sql`
- `modules/group/sql/20220818000001_group_legacy01.sql`
- `modules/group/sql/20220830000001_group_legacy01.sql`
- `modules/group/sql/20231123000001_group_legacy01.sql`
- `modules/group/sql/20240510000002_group_legacy01.sql`
- `modules/group/sql/20260318000003_group_legacy01.sql`
- `modules/group/sql/20260424000001_group_legacy01.sql`
- `modules/group/sql/20260425000001_group_legacy01.sql`
- `modules/group/sql/20260604000001_group_legacy01.sql`
- `modules/group/sql/20260605000002_group_avatar_version.sql`
- `modules/group/sql/20260615000001_group_name_widen.sql`
- `modules/group/sql/20260625000001_group_avatar_custom.sql`
- `modules/group/sql/20260629000001_group_is_named.sql`
- `modules/group/sql/20260629000002_refresh_avatar_comments.sql`

## incomingwebhook

- `modules/incomingwebhook/sql/20260514000003_incomingwebhook_init.sql`
- `modules/incomingwebhook/sql/20260604000001_incomingwebhook_audit_created_at_index.sql`
- `modules/incomingwebhook/sql/20260604000002_incomingwebhook_status_comment.sql`
- `modules/incomingwebhook/sql/20260606000001_incomingwebhook_audit_outcome.sql`
- `modules/incomingwebhook/sql/20260610000001_incomingwebhook_adapter_comment.sql`
- `modules/incomingwebhook/sql/20260618000001_incomingwebhook_no_event_comment.sql`
- `modules/incomingwebhook/sql/20260622000001_incomingwebhook_multica_adapter_comment.sql`
- `modules/incomingwebhook/sql/20260622000002_incomingwebhook_phase4_adapter_comment.sql`
- `modules/incomingwebhook/sql/20260623000001_incomingwebhook_mention_switches.sql`
- `modules/incomingwebhook/sql/20260624000001_incomingwebhook_thread.sql`
- `modules/incomingwebhook/sql/20260625000001_incomingwebhook_mention_uids.sql`

## integration

- `modules/integration/sql/20260604000002_integration_client.sql`

## message

- `modules/message/sql/20210305000001_message_legacy01.sql`
- `modules/message/sql/20210407000001_message_legacy01.sql`
- `modules/message/sql/20210416000001_message_legacy01.sql`
- `modules/message/sql/20210813000001_message_legacy01.sql`
- `modules/message/sql/20211027000001_message_legacy01.sql`
- `modules/message/sql/20220414000001_message_legacy01.sql`
- `modules/message/sql/20220418000001_message_legacy01.sql`
- `modules/message/sql/20220422000001_message_legacy01.sql`
- `modules/message/sql/20220801000001_message_legacy01.sql`
- `modules/message/sql/20220810000001_message_legacy01.sql`
- `modules/message/sql/20221122000001_message_legacy01.sql`
- `modules/message/sql/20240510000003_message_legacy01.sql`
- `modules/message/sql/20250624000001_message_legacy01.sql`
- `modules/message/sql/20250708000001_message_legacy01.sql`
- `modules/message/sql/20250708000002_message_legacy01.sql`
- `modules/message/sql/20260711000001_reminders_channel_mention_index.sql`
- `modules/message/sql/20260712000001_message_legacy01.sql`
- `modules/message/sql/20260721000001_message_extra_version.sql`
- `modules/message/sql/20260722000001_message_reaction_emoji_binary.sql`

## notification

- `modules/notification/sql/20260812000001_notification_pause.sql`
- `modules/notification/sql/20260814000001_notification_pause_mode.sql`

## notify

- `modules/notify/sql/20260716000001_add_octo_space_welcome_delivery.sql`
- `modules/notify/sql/20260720000001_add_welcome_delivery_sweep_index.sql`
- `modules/notify/sql/20260723000001_add_octo_group_welcome_delivery.sql`

## oidc

- `modules/oidc/sql/20260427000002_oidc_legacy01.sql`
- `modules/oidc/sql/20260428000002_oidc_legacy01.sql`
- `modules/oidc/sql/20260515000001_oidc_bind_uniques.sql`

## opanalytics

- `modules/opanalytics/sql/20260608000001_opanalytics_init.sql`
- `modules/opanalytics/sql/20260617000001_opanalytics_widen_dim_cols.sql`
- `modules/opanalytics/sql/20260830000001_opanalytics_add_thread_parent.sql`

## report

- `modules/report/sql/20201222000001_report_legacy01.sql`
- `modules/report/sql/20221129000001_report_legacy01.sql`

## robot

- `modules/robot/sql/20210926000001_robot_legacy01.sql`
- `modules/robot/sql/20211026000001_robot_legacy01.sql`
- `modules/robot/sql/20211105000001_robot_legacy01.sql`
- `modules/robot/sql/20260226000002_robot_legacy01.sql`
- `modules/robot/sql/20260307000001_robot_legacy01.sql`
- `modules/robot/sql/20260308000001_robot_legacy01.sql`
- `modules/robot/sql/20260309000001_robot_legacy01.sql`
- `modules/robot/sql/20260603000001_bot_mention_pref.sql`
- `modules/robot/sql/20260805000001_bot_event_seq_state.sql`
- `modules/robot/sql/20260806000001_bot_setting.sql`

## space

- `modules/space/sql/20260307000002_space_legacy01.sql`
- `modules/space/sql/20260307000003_space_legacy02.sql`
- `modules/space/sql/20260307000004_space_legacy03.sql`
- `modules/space/sql/20260308000002_space_legacy01.sql`
- `modules/space/sql/20260308000003_space_legacy02.sql`
- `modules/space/sql/20260308000004_space_legacy03.sql`
- `modules/space/sql/20260310000001_space_legacy01.sql`
- `modules/space/sql/20260310000002_space_legacy02.sql`
- `modules/space/sql/20260410000001_space_legacy01.sql`
- `modules/space/sql/20260410000002_space_legacy02.sql`
- `modules/space/sql/20260423000001_space_legacy01.sql`
- `modules/space/sql/20260424000002_space_legacy01.sql`
- `modules/space/sql/20260627000001_dm_space_presence.sql`
- `modules/space/sql/20260821000001_space_member_removal_cleanup.sql`

## sticker

- `modules/sticker/sql/20260629000001_sticker.sql`
- `modules/sticker/sql/20260630000001_sticker_metadata.sql`
- `modules/sticker/sql/20260703000001_sticker_collect.sql`

## thread

- `modules/thread/sql/20260402000001_thread_legacy01.sql`
- `modules/thread/sql/20260402000002_thread_legacy02.sql`
- `modules/thread/sql/20260410000003_thread_legacy01.sql`
- `modules/thread/sql/20260413000001_thread_legacy01.sql`
- `modules/thread/sql/20260422000001_thread_legacy01.sql`
- `modules/thread/sql/20260511000001_thread_legacy01.sql`
- `modules/thread/sql/20260522000002_thread_group_status_created_index.sql`
- `modules/thread/sql/20260711000002_thread_unarchive_pending_mention_backfill.sql`

## user

- `modules/user/sql/20191106000003_user_legacy01.sql`
- `modules/user/sql/20210204000001_user_legacy01.sql`
- `modules/user/sql/20210405000001_user_legacy01.sql`
- `modules/user/sql/20210413000001_user_legacy01.sql`
- `modules/user/sql/20210907000001_user_legacy01.sql`
- `modules/user/sql/20210916000001_user_legacy01.sql`
- `modules/user/sql/20211115000001_user_legacy01.sql`
- `modules/user/sql/20220222000001_user_legacy01.sql`
- `modules/user/sql/20220609000001_user_legacy01.sql`
- `modules/user/sql/20220713000001_user_legacy01.sql`
- `modules/user/sql/20220816000001_user_legacy01.sql`
- `modules/user/sql/20220906000001_user_legacy01.sql`
- `modules/user/sql/20220919000001_user_legacy01.sql`
- `modules/user/sql/20230611000001_user_legacy01.sql`
- `modules/user/sql/20230911000001_user_legacy01.sql`
- `modules/user/sql/20230924000001_user_legacy01.sql`
- `modules/user/sql/20231127000001_user_legacy01.sql`
- `modules/user/sql/20260228000001_user_legacy01.sql`
- `modules/user/sql/20260305000001_user_legacy01.sql`
- `modules/user/sql/20260424000003_user_legacy01.sql`
- `modules/user/sql/20260427000003_user_legacy01.sql`
- `modules/user/sql/20260505000003_user_legacy01.sql`
- `modules/user/sql/20260510000003_user_legacy01.sql`
- `modules/user/sql/20260516000001_user_legacy01.sql`
- `modules/user/sql/20260522000001_user_space_setting.sql`
- `modules/user/sql/20260523000001_voice_feedback_default_off.sql`
- `modules/user/sql/20260526000001_voice_input_enabled.sql`
- `modules/user/sql/20260527000001_user_language.sql`
- `modules/user/sql/20260605000001_user_avatar_version.sql`
- `modules/user/sql/20260809000001_user_session_revocation_intent.sql`
- `modules/user/sql/20260810000001_user_phone_encrypted_columns.sql`
- `modules/user/sql/20260810000002_login_log_status_index.sql`
- `modules/user/sql/20260810000003_user_login_lookup_indexes.sql`
- `modules/user/sql/20260810000004_user_phone_encrypted_width.sql`
- `modules/user/sql/20260811000001_session_rollout_control.sql`
- `modules/user/sql/20260811000001_session_rollout_marker.sql`
- `modules/user/sql/20260812000001_session_rollout_control.sql`

## usersecret

- `modules/usersecret/sql/20260607000001_user_secret_alias.sql`

## voice_adapter

- `modules/voice_adapter/sql/20260409000001_voice_legacy01.sql`

## webhook

- `modules/webhook/sql/20210226000001_webhook_legacy01.sql`
- `modules/webhook/sql/20230920000002_webhook_legacy01.sql`
- `modules/webhook/sql/20241217000001_webhook_legacy01.sql`

## workplace

- `modules/workplace/sql/20230823000001_workplace_legacy01.sql`
- `modules/workplace/sql/20230906000001_workplace_legacy01.sql`
- `modules/workplace/sql/20240113000001_workplace_legacy01.sql`
