#if defined _cromchat_included
    #endinput
#endif

#define _cromchat_included

#if !defined CC_DONT_OVERWRITE_183_PRINT
	#define client_print_color CC_SendMatched
	#define print_team_default CC_COLOR_TEAM
	#define print_team_grey CC_COLOR_GREY
	#define print_team_blue CC_COLOR_BLUE
	#define print_team_red CC_COLOR_RED
#endif

#if !defined CC_DONT_OVERWRITE_COLORCHAT
	#define ColorChat CC_SendMatched
	#define NORMAL CC_COLOR_TEAM
	#define TEAM_COLOR CC_COLOR_TEAM
	#define GREEN CC_COLOR_TEAM
	#define GREY CC_COLOR_GREY
	#define BLUE CC_COLOR_BLUE
	#define RED CC_COLOR_RED
#endif

#define CC_VERSION 					2.0
#define CC_MAX_TEAM_SIZE 			10
#define CC_MAX_PLAYERS 				32
#define CC_MAX_PREFIX_SIZE 			64
#define CC_MAX_MESSAGE_SIZE 		188
#define CC_FILTERING_FLAGS			"ch"
#define CromChat 					CC_SendMessage

#if !defined CC_COLORS_TYPE
	#define CC_COLORS_TYPE CC_COLORS_CROMCHAT
#endif

enum
{
	CC_COLOR_TEAM 		= 0,
	CC_COLOR_GREY 		= -1,
	CC_COLOR_WHITE 		= -1,
	CC_COLOR_BLUE 		= -2,
	CC_COLOR_RED 		= -3
}

enum
{
	CC_COLORS_CROMCHAT,
	CC_COLORS_SHORT,
	CC_COLORS_NAMED,
	CC_COLORS_NAMED_SHORT,
	CC_COLORS_STANDARD,
	CC_COLORS_CUSTOM
}

#define CC_SYM_MENU_YELLOW 			"\y"
#define CC_SYM_MENU_WHITE 			"\w"
#define CC_SYM_MENU_GREY 			"\d"
#define CC_SYM_MENU_RIGHT 			"\R"

#define CC_SYM_CHAT_DEF_NORMAL 		"^x01"
#define CC_SYM_CHAT_DEF_TEAM 		"^x03"
#define CC_SYM_CHAT_DEF_GREEN 		"^x04"

#define CC_SYM_TEAM_T 				"TERRORIST"
#define CC_SYM_TEAM_CT 				"CT"
#define CC_SYM_TEAM_SPEC 			"SPECTATOR"

new CC_PREFIX[CC_MAX_PREFIX_SIZE], bool:CC_FIRST_TIME = true, CC_MSG_SAYTEXT, CC_MSG_TEAMINFO
new const CC_MENU_COLORS[][] = { CC_SYM_MENU_YELLOW, CC_SYM_MENU_WHITE, CC_SYM_MENU_GREY, CC_SYM_MENU_RIGHT }

#if CC_COLORS_TYPE == CC_COLORS_CUSTOM
	#if !defined CC_SYM_CHAT_NORMAL
		#define CC_SYM_CHAT_NORMAL 		"&x01"
	#endif
	
	#if !defined CC_SYM_CHAT_TEAM
		#define CC_SYM_CHAT_TEAM 		"&x03"
	#endif
	
	#if !defined CC_SYM_CHAT_GREEN
		#define CC_SYM_CHAT_GREEN		"&x04"
	#endif
	
	#if !defined CC_SYM_CHAT_WHITE
		#define CC_SYM_CHAT_WHITE		"&x05"
	#endif
	
	#if !defined CC_SYM_CHAT_BLUE
		#define CC_SYM_CHAT_BLUE 		"&x06"
	#endif
	
	#if !defined CC_SYM_CHAT_RED
		#define CC_SYM_CHAT_RED			"&x07"
	#endif
	
	#if !defined CC_SYM_CHAT_NOPREF
		#define CC_SYM_CHAT_NOPREF		"&x00"
	#endif
#else	
	#if CC_COLORS_TYPE == CC_COLORS_CROMCHAT
		#define CC_SYM_CHAT_NORMAL 		"&x01"
		#define CC_SYM_CHAT_TEAM 		"&x03"
		#define CC_SYM_CHAT_GREEN 		"&x04"
		#define CC_SYM_CHAT_WHITE 		"&x05"
		#define CC_SYM_CHAT_BLUE 		"&x06"
		#define CC_SYM_CHAT_RED 		"&x07"
		#define CC_SYM_CHAT_NOPREF 		"&x00"
	#endif
	
	#if CC_COLORS_TYPE == CC_COLORS_SHORT
		#define CC_SYM_CHAT_NORMAL 		"!n"
		#define CC_SYM_CHAT_TEAM 		"!t"
		#define CC_SYM_CHAT_GREEN 		"!g"
		#define CC_SYM_CHAT_WHITE 		"!w"
		#define CC_SYM_CHAT_BLUE 		"!b"
		#define CC_SYM_CHAT_RED 		"!r"
		#define CC_SYM_CHAT_NOPREF 		"!p"
	#endif
	
	#if CC_COLORS_TYPE == CC_COLORS_NAMED
		#define CC_SYM_CHAT_NORMAL 		"{normal}"
		#define CC_SYM_CHAT_TEAM 		"{team}"
		#define CC_SYM_CHAT_GREEN 		"{green}"
		#define CC_SYM_CHAT_WHITE 		"{white}"
		#define CC_SYM_CHAT_BLUE 		"{blue}"
		#define CC_SYM_CHAT_RED 		"{red}"
		#define CC_SYM_CHAT_NOPREF 		"{nopref}"
	#endif
	
	#if CC_COLORS_TYPE == CC_COLORS_NAMED_SHORT
		#define CC_SYM_CHAT_NORMAL 		"{n}"
		#define CC_SYM_CHAT_TEAM 		"{t}"
		#define CC_SYM_CHAT_GREEN 		"{g}"
		#define CC_SYM_CHAT_WHITE 		"{w}"
		#define CC_SYM_CHAT_BLUE 		"{b}"
		#define CC_SYM_CHAT_RED 		"{r}"
		#define CC_SYM_CHAT_NOPREF 		"{p}"
	#endif
	
	#if CC_COLORS_TYPE == CC_COLORS_STANDARD
		#define CC_SYM_CHAT_NORMAL 		"^1"
		#define CC_SYM_CHAT_TEAM 		"^3"
		#define CC_SYM_CHAT_GREEN 		"^4"
		#define CC_SYM_CHAT_WHITE 		"^5"
		#define CC_SYM_CHAT_BLUE 		"^6"
		#define CC_SYM_CHAT_RED 		"^7"
		#define CC_SYM_CHAT_NOPREF 		"^0"
	#endif
#endif

new const CC_REPLACE_COLORS[][] = { CC_SYM_CHAT_GREEN, CC_SYM_CHAT_DEF_GREEN, CC_SYM_CHAT_TEAM, CC_SYM_CHAT_DEF_TEAM, CC_SYM_CHAT_NORMAL, CC_SYM_CHAT_DEF_NORMAL }
new const CC_PLUS_COLORS[][] = { CC_SYM_CHAT_RED, CC_SYM_TEAM_T, CC_SYM_CHAT_BLUE, CC_SYM_TEAM_CT, CC_SYM_CHAT_WHITE, CC_SYM_TEAM_SPEC }
new const CC_COLORS_LIST[][] = { CC_SYM_CHAT_RED, CC_SYM_CHAT_BLUE, CC_SYM_CHAT_WHITE, CC_SYM_CHAT_GREEN, CC_SYM_CHAT_TEAM, CC_SYM_CHAT_NORMAL, CC_SYM_CHAT_NOPREF }
new const CC_NO_PREFIX[] = CC_SYM_CHAT_NOPREF

/**
 * Sends a colored chat message.
 *
 * @param id     	Client index (use 0 to send to all players)
 * @param szInput	The message to send
 * @param ... 		Variable number of formatting parameters
 *
 * @return          Length of the printed message
 */
stock CC_SendMessage(const id, const szInput[], any:...)
{
	static iPlayers[CC_MAX_PLAYERS], iPnum
	
	if(id)
	{
		if(!is_user_connected(id))
			return 0
	}
	else
	{
		get_players(iPlayers, iPnum, CC_FILTERING_FLAGS)
		
		if(!iPnum)
			return 0
	}
	
	static szMessage[CC_MAX_MESSAGE_SIZE], szTeam[CC_MAX_TEAM_SIZE], bool:bNoPrefix, i
	vformat(szMessage[1], charsmax(szMessage), szInput, 3)
	szMessage[0] = 0x01
	szTeam[0] = EOS
	
	bNoPrefix = bool:equal(szMessage[1], CC_NO_PREFIX, charsmax(CC_NO_PREFIX))
	
	if(bNoPrefix)
		replace(szMessage, charsmax(szMessage), CC_NO_PREFIX, "")
	else if(CC_PREFIX[0])
		format(szMessage, charsmax(szMessage), "%s%s %s%s", CC_SYM_CHAT_DEF_NORMAL, CC_PREFIX, CC_SYM_CHAT_DEF_NORMAL, szMessage)
	
	for(i = 0; i < sizeof(CC_REPLACE_COLORS) - 1; i += 2)
		replace_all(szMessage, charsmax(szMessage), CC_REPLACE_COLORS[i], CC_REPLACE_COLORS[i + 1])
		
	for(i = 0; i < sizeof(CC_PLUS_COLORS) - 1; i += 2)
	{
		if(contain(szMessage, CC_PLUS_COLORS[i]) != -1)
		{
			copy(szTeam, charsmax(szTeam), CC_PLUS_COLORS[i + 1])
			break
		}
	}
	
	if(szTeam[0])
	{
		for(i = 0; i < 3; i++)
			replace_all(szMessage, charsmax(szMessage), CC_COLORS_LIST[i], CC_SYM_CHAT_DEF_TEAM)
	}
	
	if(id)
		CC_WriteMessage(id, szMessage, szTeam)
	else
	{
		for(i = 0; i < iPnum; i++)
			CC_WriteMessage(iPlayers[i], szMessage, szTeam)
	}
	
	return strlen(szMessage)
}

/**
 * Sends a colored chat message matching a specific player's color.
 *
 * @note 	You can use the iPlayer argument to set a specific color instead of matching it automtaically.
			To do this, you can use one of the following color arguments:
			CC_COLOR_TEAM, CC_COLOR_GREY (or CC_COLOR_WHITE), CC_COLOR_BLUE, CC_COLOR_RED.
 *
 * @param id     	Client index (use 0 to send to all players)
 * @param iPlayer   Matching player's index
 * @param szInput	The message to send
 * @param ... 		Variable number of formatting parameters
 *
 * @return          Length of the printed message
 */
stock CC_SendMatched(const id, const iPlayer, const szInput[], any:...)
{
	static szMessage[CC_MAX_MESSAGE_SIZE], bool:bPlus, i
	vformat(szMessage[1], charsmax(szMessage), szInput, 4)
	szMessage[0] = 0x01
	bPlus = false
	
	for(i = 0; i < sizeof(CC_PLUS_COLORS) - 1; i += 2)
	{
		if(contain(szMessage, CC_PLUS_COLORS[i]) != -1)
		{
			bPlus = true
			break
		}
	}
	
	if(!bPlus)
	{
		static iColor
		
		if(is_user_connected(iPlayer))
		{
			switch(get_user_team(iPlayer))
			{
				case 1: iColor = CC_COLOR_RED
				case 2: iColor = CC_COLOR_BLUE
				default: iColor = CC_COLOR_GREY
			}
		}
		else
			iColor = iPlayer
			
		switch(iColor)
		{
			case CC_COLOR_RED: add(szMessage, charsmax(szMessage), CC_COLORS_LIST[0])
			case CC_COLOR_BLUE: add(szMessage, charsmax(szMessage), CC_COLORS_LIST[1])
			case CC_COLOR_GREY: add(szMessage, charsmax(szMessage), CC_COLORS_LIST[2])
		}
	}
	
	return CC_SendMessage(id, szMessage)
}

/**
 * Sends a colored chat message to a group of players matching the flags from the get_players() function.
 *
 * @note 	You can see all the available filtering flags here: https://www.amxmodx.org/api/amxmodx/get_players
 *
 * @param szFlags   Filtering flags
 * @param szParams  String to match against if the flags require it
 * @param szInput	The message to send
 * @param ... 		Variable number of formatting parameters
 *
 * @return          Length of the printed message or 0 if no players were matched
 */
stock CC_GroupMessage(const szFlags[] = "", const szParams[] = "", const szInput[], any:...)
{
	static szMessage[CC_MAX_MESSAGE_SIZE], iPlayers[CC_MAX_PLAYERS], iPnum
	vformat(szMessage, charsmax(szMessage), szInput, 4)
	get_players(iPlayers, iPnum, szFlags, szParams)
	
	if(!iPnum)
		return 0
	
	static i
	
	for(i = 0; i < iPnum; i++)
		CC_SendMessage(iPlayers[i], szMessage)
	
	return strlen(szMessage)
}

/**
 * Sends a colored chat message to all players who have the specified admin flags.
 *
 * @param szFlags	Admin flags
 * @param bAllFlags If set to true it will match players who have ALL of the specified admin flags, otherwise it will match players with ANY of the flags
 * @param szInput	The message to send
 * @param ... 		Variable number of formatting parameters
 *
 * @return          Length of the printed message or 0 if no players were matched
 */
stock CC_SendAdminMessage(const szFlags[] = "", const bool:bAllFlags = true, const szInput[], any:...)
{
	static szMessage[CC_MAX_MESSAGE_SIZE], iPlayers[CC_MAX_PLAYERS], iPnum
	vformat(szMessage, charsmax(szMessage), szInput, 4)
	get_players(iPlayers, iPnum, CC_FILTERING_FLAGS)
	
	if(!iPnum)
		return 0
	
	static iCount, iFlags, iPlayer, i
	iFlags = read_flags(szFlags)
	iCount = 0
	
	for(i = 0; i < iPnum; i++)
	{
		iPlayer = iPlayers[i]
		
		switch(bAllFlags)
		{
			case true:
			{
				if(get_user_flags(iPlayer) & iFlags != iFlags)
					continue
			}
			case false:
			{
				if(!(get_user_flags(iPlayer) & iFlags))
					continue
			}
		}
		
		iCount++
		CC_SendMessage(iPlayer, szMessage)
	}
	
	if(!iCount)
		return 0
	
	return strlen(szMessage)
}

/**
 * Sends a colored chat message and logs it at the same time.
 *
 * @note 	If the file name is not set, the default log file will be used instead.
 *
 * @param id     	Client index (use 0 to send to all players)
 * @param szFile   	The log file that will be used
 * @param szInput	The message to send
 * @param ... 		Variable number of formatting parameters
 *
 * @return          Length of the printed message
 */
stock CC_LogMessage(const id, const szFile[] = "", const szInput[], any:...)
{
	static szMessage[CC_MAX_MESSAGE_SIZE]
	vformat(szMessage, charsmax(szMessage), szInput, 4)
	
	if(!CC_SendMessage(id, szMessage))
		return 0
		
	CC_RemoveColors(szMessage, charsmax(szMessage))
	szFile[0] ? log_to_file(szFile, szMessage) : log_amx(szMessage)
	return strlen(szMessage)
}

/**
 * This function is used by the other stocks to send a raw message.
 *
 * @param id     	Client index (use 0 to send to all players)
 * @param szMessage	The message to send
 * @param szTeam 	Message color according to the team
 *
 * @noreturn
 */
stock CC_WriteMessage(const id, const szMessage[], szTeam[CC_MAX_TEAM_SIZE])
{
	static bool:bRefresh
	bRefresh = true
	
	if(!szTeam[0])
	{
		bRefresh = false
		get_user_team(id, szTeam, charsmax(szTeam))
	}
	
	if(CC_FIRST_TIME)
	{
		CC_FIRST_TIME = false
		CC_MSG_SAYTEXT = get_user_msgid("SayText")
		CC_MSG_TEAMINFO = get_user_msgid("TeamInfo")
	}
		
	CC_SendTeamInfo(id, szTeam)

	message_begin(MSG_ONE, CC_MSG_SAYTEXT, _, id)
	write_byte(id)
	//write_string("%s") -- Good Job, Valve!
	write_string(szMessage)
	message_end()
	
	if(bRefresh)
	{
		get_user_team(id, szTeam, charsmax(szTeam))
		CC_SendTeamInfo(id, szTeam)
	}
}

/**
 * Removes the color codes from a message.
 *
 * @param szMessage The message to work with
 * @param iLen		Maximum buffer length
 * @param bChat		If set to true, it will remove the chat color codes
 * @param bMenu		If set to true, it will remove the menu color codes
 *
 * @noreturn
 */
stock CC_RemoveColors(szMessage[], iLen, bool:bChat = true, bool:bMenu = false)
{
	static i
	
	if(bChat)
	{
		for(i = 0; i < sizeof(CC_COLORS_LIST); i++)
			replace_all(szMessage, iLen, CC_COLORS_LIST[i], "")
	}
	
	if(bMenu)
	{
		for(i = 0; i < sizeof(CC_MENU_COLORS); i++)
			replace_all(szMessage, iLen, CC_MENU_COLORS[i], "")
	}
}

/**
 * Updates the player's team info.
 *
 * @param id     	Client index
 * @param szTeam	Team to use
 *
 * @noreturn
 */
stock CC_SendTeamInfo(const id, const szTeam[CC_MAX_TEAM_SIZE])
{
	message_begin(MSG_ONE, CC_MSG_TEAMINFO, _, id)
	write_byte(id)
	write_string(szTeam)
	message_end()
}

/**
 * Sets a global prefix that will be used for all sent messages.
 *
 * @note 	The prefix can be removed in a given message if the prefix-removing symbol is used
			in the beginning of the message. By default, this symbol is equal to &x00.
 *
 * @param szPrefix  The prefix
 *
 * @noreturn
 */
stock CC_SetPrefix(const szPrefix[])
	copy(CC_PREFIX, charsmax(CC_PREFIX), szPrefix)
	
/**
 * Removes the global message prefix.
 *
 * @noreturn
 */
stock CC_RemovePrefix()
	CC_PREFIX[0] = EOS