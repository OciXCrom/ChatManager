#if defined _chatmanager_included
    #endinput
#endif

#define _chatmanager_included

native bool:cm_has_user_admin_listen(id)
native cm_get_admin_listen_flags(buffer[], len)
native cm_get_admin_prefix(id, buffer[], len)
native cm_get_chat_color(id, buffer[], len)
native cm_get_chat_color_by_num(num, buffer[], len)
native cm_get_prefix_by_num(num, buffer[], len)
native cm_total_chat_colors()
native cm_total_prefixes()
native cm_update_player_data(id)
native cm_set_user_prefix(id, prefix[])
native bool:cm_get_prefix_status(id)
native cm_set_prefix_status(id, bool:status)
native bool:cm_get_colorchat_status(id)
native cm_set_colorchat_status(id, bool:status)