#if defined _cromchat_included
    #endinput
#endif

#define _cromchat_included

#if !defined ColorChat
	#define ColorChat CC_SendMessage
#endif

#if !defined client_print_color
	#define client_print_color CC_SendMessage
#endif

#define CromChat CC_SendMessage

#define CC_VERSION 1.3
#define CC_MAX_TEAM_SIZE 10
#define CC_MAX_PLAYERS 32
#define CC_MAX_PREFIX_SIZE 64
#define CC_MAX_MESSAGE_SIZE 188

#if !defined CC_COLORS_TYPE
	#define CC_COLORS_TYPE CC_COLORS_CROMCHAT
#endif

enum
{
	CC_COLOR_TEAM = 0,
	CC_COLOR_GREY = -1,
	CC_COLOR_WHITE = -1,
	CC_COLOR_BLUE = -2,
	CC_COLOR_RED = -3
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

new CC_PREFIX[CC_MAX_PREFIX_SIZE], bool:CC_FIRST_TIME = true, CC_MSG_SAYTEXT, CC_MSG_TEAMINFO
new const CC_MENU_COLORS[][] = { "\y", "\r", "\w", "\d", "\R" }

#if CC_COLORS_TYPE != CC_COLORS_CUSTOM
	#if CC_COLORS_TYPE == CC_COLORS_CROMCHAT
	new const CC_REPLACE_COLORS[][] = { "&x04", "^x04", "&x03", "^x03", "&x01", "^x01" }
	new const CC_PLUS_COLORS[][] = { "&x07", "TERRORIST", "&x06", "CT", "&x05", "SPECTATOR" }
	new const CC_COLORS_LIST[][] = { "&x07", "&x06", "&x05", "&x04", "&x03", "&x01", "&x00" }
	new const CC_NO_PREFIX[] = "&x00"
	#elseif CC_COLORS_TYPE == CC_COLORS_SHORT
	new const CC_REPLACE_COLORS[][] = { "!g", "^x04", "!t", "^x03", "!n", "^x01" }
	new const CC_PLUS_COLORS[][] = { "!r", "TERRORIST", "!b", "CT", "!w", "SPECTATOR" }
	new const CC_COLORS_LIST[][] = { "!r", "!b", "!w", "!g", "!t", "!n", "!p" }
	new const CC_NO_PREFIX[] = "!p"
	#elseif CC_COLORS_TYPE == CC_COLORS_NAMED
	new const CC_REPLACE_COLORS[][] = { "{green}", "^x04", "{team}", "^x03", "{normal}", "^x01" }
	new const CC_PLUS_COLORS[][] = { "{red}", "TERRORIST", "{blue}", "CT", "{white}", "SPECTATOR" }
	new const CC_COLORS_LIST[][] = { "{red}", "{blue}", "{white}", "{green}", "{team}", "{normal}", "{nopref}" }
	new const CC_NO_PREFIX[] = "{nopref}"
	#elseif CC_COLORS_TYPE == CC_COLORS_NAMED_SHORT
	new const CC_REPLACE_COLORS[][] = { "{g}", "^x04", "{t}", "^x03", "{n}", "^x01" }
	new const CC_PLUS_COLORS[][] = { "{r}", "TERRORIST", "{b}", "CT", "{w}", "SPECTATOR" }
	new const CC_COLORS_LIST[][] = { "{r}", "{b}", "{w}", "{g}", "{t}", "{n}", "{p}" }
	new const CC_NO_PREFIX[] = "{p}"
	#elseif CC_COLORS_TYPE == CC_COLORS_STANDARD
	new const CC_REPLACE_COLORS[][] = { "^4", "^x04", "^3", "^x03", "^1", "^x01" }
	new const CC_PLUS_COLORS[][] = { "^7", "TERRORIST", "^6", "CT", "^5", "SPECTATOR" }
	new const CC_COLORS_LIST[][] = { "^7", "^6", "^5", "^4", "^3", "^1", "^0" }
	new const CC_NO_PREFIX[] = "^2"
	#endif
#endif
	
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
		get_players(iPlayers, iPnum, "ch")
		
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
		format(szMessage, charsmax(szMessage), "^x01%s ^x01%s", CC_PREFIX, szMessage)
	
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
			replace_all(szMessage, charsmax(szMessage), CC_COLORS_LIST[i], "^x03")
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

stock CC_SendMatched(const id, const iPlayer, const szInput[], any:...)
{
	static szMessage[CC_MAX_MESSAGE_SIZE]
	vformat(szMessage[1], charsmax(szMessage), szInput, 4)
	szMessage[0] = 0x01
	
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
	
	return CC_SendMessage(id, szMessage)
}

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

stock CC_SendTeamInfo(const id, const szTeam[CC_MAX_TEAM_SIZE])
{
	message_begin(MSG_ONE, CC_MSG_TEAMINFO, _, id)
	write_byte(id)
	write_string(szTeam)
	message_end()
}

stock CC_SetPrefix(const szPrefix[])
	copy(CC_PREFIX, charsmax(CC_PREFIX), szPrefix)