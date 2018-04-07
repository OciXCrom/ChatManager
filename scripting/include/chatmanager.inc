#if defined _chatmanager_included
    #endinput
#endif

#define _chatmanager_included

/** 
 * Returns the flags needed to see all chats.
 * 
 * @param buffer 		Buffer to store the flags in.
 * @param len 			Maximum buffer length.
 * @noreturn
 */
native cm_get_admin_listen_flags(buffer[], len)

/** 
 * Returns the client's admin prefix.
 * 
 * @param id 			Player's index.
 * @param buffer 		Buffer to store the prefix in.
 * @param len 			Maximum buffer length.
 * @noreturn
 */
native cm_get_admin_prefix(id, buffer[], len)

/** 
 * Returns the client's chat color.
 * 
 * @param id 			Player's index.
 * @param buffer 		Buffer to store the chat color in.
 * @param len 			Maximum buffer length.
 * @noreturn
 */
native cm_get_chat_color(id, buffer[], len)

/** 
 * Finds a chat color by a specified number.
 * 
 * @param num 			Color number.
 * @param buffer 		Buffer to store the chat color in.
 * @param len 			Maximum buffer length.
 * @return				1 if found, 0 otherwise.
 */
native cm_get_chat_color_by_num(num, buffer[], len)

/** 
 * Checks whether the client's color chat is enabled or disabled.
 * 
 * @param id 			Player's index.
 * @return				True if it's enabled, false otherwise.
 */
native bool:cm_get_colorchat_status(id)

/** 
 * Finds a prefix by a specified number.
 * 
 * @param num 			Prefix number.
 * @param buffer 		Buffer to store the prefix in.
 * @param len 			Maximum buffer length.
 * @return				1 if found, 0 otherwise.
 */
native cm_get_prefix_by_num(num, buffer[], len)

/** 
 * Checks whether the client's prefix is enabled or disabled.
 * 
 * @param id 			Player's index.
 * @return				True if it's enabled, false otherwise.
 */
native bool:cm_get_prefix_status(id)

/** 
 * Checks if the client has admin listen (can see all chats).
 * 
 * @param id 			Player's index.
 * @return				True if he has, false otherwise.
 */
native bool:cm_has_user_admin_listen(id)

/** 
 * Reloads the configuration file.
 *
 * @noreturn
 */
native cm_reload_config_file()

/** 
 * Enables/Disables the client's color chat.
 * 
 * @param id 			Player's index.
 * @noreturn
 */
native cm_set_colorchat_status(id, bool:status)

/** 
 * Enables/Disables the client's prefix.
 * 
 * @param id 			Player's index.
 * @noreturn
 */
native cm_set_prefix_status(id, bool:status)

/** 
 * Sets a temporary chat color on the client.
 * 
 * @note The chat color set with this native won't get saved in the .ini file, so it will be gone after the client's data is updated.
 *
 * @param id 			Player's index.
 * @param color 		Temporary chat color.
 * @noreturn
 */
native cm_set_user_chat_color(id, color[])

/** 
 * Sets a temporary prefix on the client.
 * 
 * @note The prefix set with this native won't get saved in the .ini file, so it will be gone after the client's data is updated.
 *
 * @param id 			Player's index.
 * @param prefix 		Temporary prefix.
 * @noreturn
 */
native cm_set_user_prefix(id, prefix[])

/** 
 * Sets a temporary say format on the client.
 * 
 * @note The say format set with this native won't get saved in the .ini file, so it will be gone after the client's data is updated.
 *
 * @param id 			Player's index.
 * @param say 			Temporary say format.
 * @param say_team 		Temporary say_team format.
 * @noreturn
 */
native cm_set_user_say_format(id, say[], say_team[])

/** 
 * Returns the number ot total chat colors added in the .ini file.
 * 
 * @return				Number ot total chat colors added in the .ini file.
 */
native cm_total_chat_colors()

/** 
 * Returns the number ot total prefixes added in the .ini file.
 * 
 * @return				Number ot total prefixes added in the .ini file.
 */
native cm_total_prefixes()

/** 
 * Returns the number ot total say formats registered for players in the .ini file.
 * 
 * @return				Number ot total say formats registered for players in the .ini file.
 */
native cm_total_say_formats()

/** 
 * Updates the client's prefix and chat color according to the data stored in the plugin.
 * 
 * @note This can be used if you changed the player's admin flags and you want
 *       to immediately update the player's prefix and chat color.
 *
 * @param id 			Player's index.
 * @noreturn
 */
native cm_update_player_data(id)