#include <amxmodx>
#include <amxmisc>
#include <cromchat>
#include <cstrike>

#define PLUGIN_VERSION "3.6.3"
#define DELAY_ON_REGISTER 1.0
#define DELAY_ON_CONNECT 1.0
#define DELAY_ON_CHANGE 0.1
#define PLACEHOLDER_LENGTH 64

/* 	You can comment placeholders you don't need from the lines below and that will completely deactivate them.
	You can also activate the additional ones if you want to use them.
	Feel free to experiment in making your custom ones as well. */
	
#define ARG_ADMIN_PREFIX 		"%admin_prefix%"
#define ARG_DEAD_PREFIX 		"%dead_prefix%"
#define ARG_TEAM 				"%team%"
#define ARG_NAME 				"%name%"
#define ARG_IP 					"%ip%"
#define ARG_STEAM 				"%steam%"
#define ARG_USERID 				"%userid%"
#define ARG_CHAT_COLOR 			"%chat_color%"
#define ARG_MESSAGE 			"%message%"
#define ARG_TIME 				"%time%"
//#define ARG_HEALTH 			"%health%"
//#define ARG_ARMOR 			"%armor%"
//#define ARG_FRAGS 			"%frags%"
//#define ARG_DEATHS 			"%deaths%"
//#define ARG_CITY 				"%city%"
//#define ARG_COUNTRY 			"%country%"
//#define ARG_COUNTRY_CODE 		"%country_code%"
//#define ARG_CONTINENT 		"%continent%"
//#define ARG_CONTINENT_CODE 	"%continent_code%"

/*	The settings end here. Don't modify anything below this if you don't know what you're doing. */

#if defined ARG_CITY || defined ARG_COUNTRY || defined ARG_COUNTRY_CODE || defined ARG_CONTINENT || defined ARG_CONTINENT_CODE
	#include <geoip>
#endif

enum
{
	SECTION_NONE,
	SECTION_SETTINGS,
	SECTION_ADMIN_PREFIXES,
	SECTION_CHAT_COLORS,
	SECTION_NAME_IP_STEAM
}

enum _:Settings
{
	ADMIN_LISTEN_FLAGS[32],
	DEAD_PREFIX[32],
	ALIVE_PREFIX[32],
	TEAM_PREFIX_T[32],
	TEAM_PREFIX_CT[32],
	TEAM_PREFIX_SPEC[32],
	ERROR_TEXT[32],
	FORMAT_TIME[64],
	FORMAT_SAY[160],
	FORMAT_SAY_TEAM[160],
	bool:ALL_CHAT
}

enum _:PlayerData
{
	PDATA_NAME[32],
	PDATA_NAME_LOWER[32],
	PDATA_IP[16],
	PDATA_STEAM[35],
	PDATA_USERID[10],
	PDATA_PREFIX[32],
	PDATA_CHAT_COLOR[6],
	bool:PDATA_ADMIN_LISTEN
}

new g_eSettings[Settings],
	g_ePlayerData[33][PlayerData],
	Array:g_aAdminFlags,
	Array:g_aAdminPrefixes,
	Array:g_aChatColors,
	Array:g_aChatColorsFlags,
	Trie:g_tName,
	Trie:g_tIP,
	Trie:g_tSteam,
	Trie:g_tBlockFirst,
	g_iAdminPrefixes,
	g_iChatColors

public plugin_init()
{
	register_plugin("Chat Manager", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXChatManager", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	set_task(DELAY_ON_REGISTER, "RegisterCommands")
	g_aAdminFlags = ArrayCreate(32)
	g_aAdminPrefixes = ArrayCreate(32)
	g_aChatColors = ArrayCreate(6)
	g_aChatColorsFlags = ArrayCreate(32)
	g_tBlockFirst = TrieCreate()
	g_tName = TrieCreate()
	g_tIP = TrieCreate()
	g_tSteam = TrieCreate()
	ReadFile()
}

public plugin_end()
{
	ArrayDestroy(g_aAdminFlags)
	ArrayDestroy(g_aAdminPrefixes)
	ArrayDestroy(g_aChatColors)
	ArrayDestroy(g_aChatColorsFlags)
	TrieDestroy(g_tBlockFirst)
	TrieDestroy(g_tName)
	TrieDestroy(g_tIP)
	TrieDestroy(g_tSteam)
}

public RegisterCommands()
{
	register_clcmd("say", "Hook_Say")
	register_clcmd("say_team", "Hook_Say")
}

public client_putinserver(id)
{
	get_user_name(id, g_ePlayerData[id][PDATA_NAME], charsmax(g_ePlayerData[][PDATA_NAME]))
	copy(g_ePlayerData[id][PDATA_NAME_LOWER], charsmax(g_ePlayerData[][PDATA_NAME_LOWER]), g_ePlayerData[id][PDATA_NAME])
	strtolower(g_ePlayerData[id][PDATA_NAME_LOWER])
	get_user_ip(id, g_ePlayerData[id][PDATA_IP], charsmax(g_ePlayerData[][PDATA_IP]), 1)
	get_user_authid(id, g_ePlayerData[id][PDATA_STEAM], charsmax(g_ePlayerData[][PDATA_STEAM]))
	num_to_str(get_user_userid(id), g_ePlayerData[id][PDATA_USERID], charsmax(g_ePlayerData[][PDATA_USERID]))
	set_task(DELAY_ON_CONNECT, "UpdateData", id)
}
	
public client_infochanged(id)
{
	if(!is_user_connected(id))
		return
		
	static szNewName[32]
	get_user_info(id, "name", szNewName, charsmax(szNewName))
	
	if(!equal(szNewName, g_ePlayerData[id][PDATA_NAME]))
	{
		copy(g_ePlayerData[id][PDATA_NAME], charsmax(g_ePlayerData[][PDATA_NAME]), szNewName)
		copy(g_ePlayerData[id][PDATA_NAME_LOWER], charsmax(g_ePlayerData[][PDATA_NAME_LOWER]), szNewName)
		strtolower(g_ePlayerData[id][PDATA_NAME_LOWER])
		set_task(DELAY_ON_CHANGE, "UpdateData", id)
	}
}
	
public UpdateData(id)
{
	if(g_iChatColors)
	{
		g_ePlayerData[id][PDATA_CHAT_COLOR][0] = EOS
		
		for(new szFlags[32], i; i < g_iChatColors; i++)
		{
			ArrayGetString(g_aChatColorsFlags, i, szFlags, charsmax(szFlags))
			
			if(has_all_flags(id, szFlags))
			{
				ArrayGetString(g_aChatColors, i, g_ePlayerData[id][PDATA_CHAT_COLOR], charsmax(g_ePlayerData[][PDATA_CHAT_COLOR]))
				break
			}
		}
	}
	
	if(g_eSettings[ADMIN_LISTEN_FLAGS][0])
		g_ePlayerData[id][PDATA_ADMIN_LISTEN] = bool:has_all_flags(id, g_eSettings[ADMIN_LISTEN_FLAGS])
		
	g_ePlayerData[id][PDATA_PREFIX][0] = EOS
		
	if(TrieKeyExists(g_tSteam, g_ePlayerData[id][PDATA_STEAM]))
		TrieGetString(g_tSteam, g_ePlayerData[id][PDATA_STEAM], g_ePlayerData[id][PDATA_PREFIX], charsmax(g_ePlayerData[][PDATA_PREFIX]))
	else if(TrieKeyExists(g_tIP, g_ePlayerData[id][PDATA_IP]))
		TrieGetString(g_tIP, g_ePlayerData[id][PDATA_IP], g_ePlayerData[id][PDATA_PREFIX], charsmax(g_ePlayerData[][PDATA_PREFIX]))
	else if(TrieKeyExists(g_tName, g_ePlayerData[id][PDATA_NAME_LOWER]))
		TrieGetString(g_tName, g_ePlayerData[id][PDATA_NAME_LOWER], g_ePlayerData[id][PDATA_PREFIX], charsmax(g_ePlayerData[][PDATA_PREFIX]))
	else if(g_iAdminPrefixes)
	{
		for(new szFlags[32], i; i < g_iAdminPrefixes; i++)
		{
			ArrayGetString(g_aAdminFlags, i, szFlags, charsmax(szFlags))
			
			if(has_all_flags(id, szFlags))
			{
				ArrayGetString(g_aAdminPrefixes, i, g_ePlayerData[id][PDATA_PREFIX], charsmax(g_ePlayerData[][PDATA_PREFIX]))
				break
			}
		}
	}
}

public Hook_Say(id)
{
	new szArgs[192]
	read_args(szArgs, charsmax(szArgs)); remove_quotes(szArgs)
	CC_RemoveColors(szArgs, charsmax(szArgs))
	
	new szFirstChar[2]
	szFirstChar[0] = szArgs[0]
	
	if(!szArgs[0] || TrieKeyExists(g_tBlockFirst, szFirstChar))
		return PLUGIN_HANDLED
		
	new szCommand[5]
	read_argv(0, szCommand, charsmax(szCommand))
	
	new szMessage[192], iPlayers[32], iPnum, bool:bTeam = szCommand[3] == '_', iAlive = is_user_alive(id), CsTeams:iTeam = cs_get_user_team(id)
	format_chat_message(bTeam, id, iAlive, iTeam, szArgs, szMessage, charsmax(szMessage))
	get_players(iPlayers, iPnum, "ch")
	
	for(new i, iPlayer; i < iPnum; i++)
	{
		iPlayer = iPlayers[i]
		
		if(g_ePlayerData[iPlayer][PDATA_ADMIN_LISTEN] || (bTeam && iTeam == cs_get_user_team(iPlayer) && iAlive == is_user_alive(iPlayer)) || (!bTeam && (g_eSettings[ALL_CHAT] || iAlive == is_user_alive(iPlayer))))
			CC_SendMatched(iPlayer, id, szMessage)
	}
	
	return PLUGIN_HANDLED
}

ReadFile()
{
	new szConfigsName[256], szFilename[256]
	get_configsdir(szConfigsName, charsmax(szConfigsName))
	formatex(szFilename, charsmax(szFilename), "%s/ChatManager.ini", szConfigsName)
	
	new iFilePointer = fopen(szFilename, "rt")
	
	if(iFilePointer)
	{
		new szData[192], szValue[160], szKey[32], szInfo[32], szPrefix[32], iSection = SECTION_NONE, iSize
		
		while(!feof(iFilePointer))
		{
			fgets(iFilePointer, szData, charsmax(szData))
			trim(szData)
			
			switch(szData[0])
			{
				case EOS, ';': continue
				case '[':
				{
					iSize = strlen(szData)
					
					if(szData[iSize - 1] == ']')
					{
						switch(szData[1])
						{
							case 'S', 's': iSection = SECTION_SETTINGS
							case 'A', 'a': iSection = SECTION_ADMIN_PREFIXES
							case 'C', 'c': iSection = SECTION_CHAT_COLORS
							case 'N', 'n': iSection = SECTION_NAME_IP_STEAM
							default: iSection = SECTION_NONE
						}
					}
					else continue
				}
				default:
				{
					if(iSection == SECTION_NONE)
						continue
						
					switch(iSection)
					{
						case SECTION_SETTINGS:
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
							trim(szKey); trim(szValue)
									
							if(!szValue[0])
								continue
								
							if(equal(szKey, "ADMIN_LISTEN_FLAGS"))
								copy(g_eSettings[ADMIN_LISTEN_FLAGS], charsmax(g_eSettings[ADMIN_LISTEN_FLAGS]), szValue)
							else if(equal(szKey, "BLOCK_FIRST_SYMBOLS"))
							{
								while(szValue[0] != 0 && strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ','))
								{
									trim(szKey); trim(szValue)
									TrieSetCell(g_tBlockFirst, szKey, 1)
								}
							}
							else if(equal(szKey, "DEAD_PREFIX"))
								copy(g_eSettings[DEAD_PREFIX], charsmax(g_eSettings[DEAD_PREFIX]), szValue)
							else if(equal(szKey, "ALIVE_PREFIX"))
								copy(g_eSettings[ALIVE_PREFIX], charsmax(g_eSettings[ALIVE_PREFIX]), szValue)
							else if(equal(szKey, "TEAM_PREFIX_T"))
								copy(g_eSettings[TEAM_PREFIX_T], charsmax(g_eSettings[TEAM_PREFIX_T]), szValue)
							else if(equal(szKey, "TEAM_PREFIX_CT"))
								copy(g_eSettings[TEAM_PREFIX_CT], charsmax(g_eSettings[TEAM_PREFIX_CT]), szValue)
							else if(equal(szKey, "TEAM_PREFIX_SPEC"))
								copy(g_eSettings[TEAM_PREFIX_SPEC], charsmax(g_eSettings[TEAM_PREFIX_SPEC]), szValue)
							else if(equal(szKey, "ERROR_TEXT"))
								copy(g_eSettings[ERROR_TEXT], charsmax(g_eSettings[ERROR_TEXT]), szValue)
							else if(equal(szKey, "FORMAT_TIME"))
								copy(g_eSettings[FORMAT_TIME], charsmax(g_eSettings[FORMAT_TIME]), szValue)
							else if(equal(szKey, "FORMAT_SAY"))
								copy(g_eSettings[FORMAT_SAY], charsmax(g_eSettings[FORMAT_SAY]), szValue)
							else if(equal(szKey, "FORMAT_SAY_TEAM"))
								copy(g_eSettings[FORMAT_SAY_TEAM], charsmax(g_eSettings[FORMAT_SAY_TEAM]), szValue)
							else if(equal(szKey, "ALL_CHAT"))
								g_eSettings[ALL_CHAT] = _:clamp(str_to_num(szValue), false, true)
						}
						case SECTION_ADMIN_PREFIXES:
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
							trim(szKey); trim(szValue)
									
							if(!szValue[0])
								continue
								
							ArrayPushString(g_aAdminFlags, szKey)
							ArrayPushString(g_aAdminPrefixes, szValue)
							g_iAdminPrefixes++
						}
						case SECTION_CHAT_COLORS:
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
							trim(szKey); trim(szValue)
									
							if(!szValue[0])
								continue
								
							ArrayPushString(g_aChatColorsFlags, szKey)
							ArrayPushString(g_aChatColors, szValue)
							g_iChatColors++
						}
						case SECTION_NAME_IP_STEAM:
						{
							parse(szData, szKey, charsmax(szKey), szInfo, charsmax(szInfo), szPrefix, charsmax(szPrefix))
							{
								switch(szKey[0])
								{
									case 'N', 'n': { strtolower(szInfo); TrieSetString(g_tName, szInfo, szPrefix); }
									case 'I', 'i': TrieSetString(g_tIP, szInfo, szPrefix)
									case 'S', 's': TrieSetString(g_tSteam, szInfo, szPrefix)
								}
							}
						}
					}
				}
			}
		}
		
		fclose(iFilePointer)
	}
}

format_chat_message(const bool:bTeam, const id, const iAlive, const CsTeams:iTeam, const szArgs[], szMessage[], const iLen)
{
	static szPlaceHolder[PLACEHOLDER_LENGTH]
	copy(szMessage, iLen, g_eSettings[bTeam ? FORMAT_SAY_TEAM : FORMAT_SAY])
	
	#if defined ARG_ADMIN_PREFIX
	replace_all(szMessage, iLen, ARG_ADMIN_PREFIX, g_ePlayerData[id][PDATA_PREFIX])
	#endif
	
	#if defined ARG_DEAD_PREFIX
	replace_all(szMessage, iLen, ARG_DEAD_PREFIX, g_eSettings[iAlive ? ALIVE_PREFIX : DEAD_PREFIX])
	#endif
	
	#if defined ARG_TEAM
	replace_all(szMessage, iLen, ARG_TEAM, g_eSettings[iTeam == CS_TEAM_CT ? TEAM_PREFIX_CT : iTeam == CS_TEAM_T ? TEAM_PREFIX_T : TEAM_PREFIX_SPEC])
	#endif
	
	#if defined ARG_NAME
	replace_all(szMessage, iLen, ARG_NAME, g_ePlayerData[id][PDATA_NAME])
	#endif
	
	#if defined ARG_IP
	replace_all(szMessage, iLen, ARG_IP, g_ePlayerData[id][PDATA_IP])
	#endif
	
	#if defined ARG_STEAM
	replace_all(szMessage, iLen, ARG_STEAM, g_ePlayerData[id][PDATA_STEAM])
	#endif
	
	#if defined ARG_USERID
	replace_all(szMessage, iLen, ARG_USERID, g_ePlayerData[id][PDATA_USERID])
	#endif
	
	#if defined ARG_CHAT_COLOR
	replace_all(szMessage, iLen, ARG_CHAT_COLOR, g_ePlayerData[id][PDATA_CHAT_COLOR])
	#endif
	
	#if defined ARG_MESSAGE
	replace_all(szMessage, iLen, ARG_MESSAGE, szArgs)	
	#endif
	
	#if defined ARG_TIME
	if(has_argument(szMessage, ARG_TIME))
	{
		get_time(g_eSettings[FORMAT_TIME], szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_TIME, szPlaceHolder)
	}
	#endif
	
	#if defined ARG_HEALTH
	if(has_argument(szMessage, ARG_HEALTH))
	{
		num_to_str(iAlive ? get_user_health(id) : 0, szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_HEALTH, szPlaceHolder)
	}
	#endif
	
	#if defined ARG_ARMOR
	if(has_argument(szMessage, ARG_ARMOR))
	{
		num_to_str(iAlive ? get_user_armor(id) : 0, szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_ARMOR, szPlaceHolder)
	}
	#endif
	
	#if defined ARG_FRAGS
	if(has_argument(szMessage, ARG_FRAGS))
	{
		num_to_str(get_user_frags(id), szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_FRAGS, szPlaceHolder)
	}
	#endif
	
	#if defined ARG_DEATHS
	if(has_argument(szMessage, ARG_DEATHS))
	{
		num_to_str(cs_get_user_deaths(id), szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_DEATHS, szPlaceHolder)
	}
	#endif
	
	#if defined ARG_CITY
	if(has_argument(szMessage, ARG_CITY))
	{
		geoip_city(g_ePlayerData[id][PDATA_IP], szPlaceHolder, charsmax(szPlaceHolder))
		check_validity(szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_CITY, szPlaceHolder)
	}
	#endif
	
	#if defined ARG_COUNTRY
	if(has_argument(szMessage, ARG_COUNTRY))
	{
		#if defined geoip_country_ex
		geoip_country_ex(g_ePlayerData[id][PDATA_IP], szPlaceHolder, charsmax(szPlaceHolder))
		#else
		geoip_country(g_ePlayerData[id][PDATA_IP], szPlaceHolder, charsmax(szPlaceHolder))
		#endif
		
		check_validity(szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_COUNTRY, szPlaceHolder)
	}
	#endif
	
	#if defined ARG_COUNTRY_CODE
	if(has_argument(szMessage, ARG_COUNTRY_CODE))
	{
		new szCountryCode[3]
		
		#if defined geoip_code2_ex
		geoip_code2_ex(g_ePlayerData[id][PDATA_IP], szCountryCode)
		#else
		geoip_code2(g_ePlayerData[id][PDATA_IP], szCountryCode)
		#endif
		
		check_validity(szCountryCode, charsmax(szCountryCode))
		replace_all(szMessage, iLen, ARG_COUNTRY_CODE, szCountryCode)
	}
	#endif
	
	#if defined ARG_CONTINENT
	if(has_argument(szMessage, ARG_CONTINENT))
	{
		geoip_continent_name(g_ePlayerData[id][PDATA_IP], szPlaceHolder, charsmax(szPlaceHolder))
		check_validity(szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_CONTINENT, szPlaceHolder)
	}
	#endif
	
	#if defined ARG_CONTINENT_CODE
	if(has_argument(szMessage, ARG_CONTINENT_CODE))
	{
		new szContinentCode[3]
		geoip_continent_code(g_ePlayerData[id][PDATA_IP], szContinentCode)
		check_validity(szContinentCode, charsmax(szContinentCode))
		replace_all(szMessage, iLen, ARG_CONTINENT_CODE, szContinentCode)
	}
	#endif
	
	replace_all(szMessage, iLen, "  ", "")
	trim(szMessage)
}

stock bool:has_argument(const szMessage[], const szArgument[])
	return contain(szMessage, szArgument) != -1

stock check_validity(szText[], const iLen)
{
	if(!szText[0])
		copy(szText, iLen, g_eSettings[ERROR_TEXT])
}

public plugin_natives()
{
	register_library("chatmanager")
	register_native("cm_get_admin_listen_flags", "_cm_get_admin_listen_flags")
	register_native("cm_get_admin_prefix", "_cm_get_admin_prefix")
	register_native("cm_get_chat_color", "_cm_get_chat_color")
	register_native("cm_get_chat_color_by_num", "_cm_get_chat_color_by_num")
	register_native("cm_get_prefix_by_num", "_cm_get_prefix_by_num")
	register_native("cm_has_user_admin_listen", "_cm_has_user_admin_listen")
	register_native("cm_total_chat_colors", "_cm_total_chat_colors")
	register_native("cm_total_prefixes", "_cm_total_chat_colors")
	register_native("cm_update_player_data", "_cm_update_player_data")
}

public _cm_get_admin_prefix(iPlugin, iParams)
	set_string(2, g_ePlayerData[get_param(1)][PDATA_PREFIX], get_param(3))
	
public _cm_get_chat_color(iPlugin, iParams)
	set_string(2, g_ePlayerData[get_param(1)][PDATA_CHAT_COLOR], get_param(3))
	
public _cm_total_prefixes(iPlugin, iParams)
	return g_iAdminPrefixes

public _cm_total_chat_colors(iPlugin, iParams)
	return g_iChatColors
	
public _cm_get_prefix_by_num(iPlugin, iParams)
{
	new iNum = get_param(1)
	
	if(iNum < 0 || iNum >= g_iAdminPrefixes)
		return 0
	
	new szPrefix[32]
	ArrayGetString(g_aAdminPrefixes, iNum, szPrefix, charsmax(szPrefix))
	set_string(2, szPrefix, get_param(3))
	return 1
}

public _cm_get_chat_color_by_num(iPlugin, iParams)
{
	new iNum = get_param(1)
	
	if(iNum < 0 || iNum >= g_iChatColors)
		return 0
	
	new szColor[32]
	ArrayGetString(g_aChatColors, iNum, szColor, charsmax(szColor))
	set_string(2, szColor, get_param(3))
	return 1
}

public _cm_get_admin_listen_flags(iPlugin, iParams)
	set_string(1, g_eSettings[ADMIN_LISTEN_FLAGS], get_param(2))
	
public bool:_cm_has_user_admin_listen(iPlugin, iParams)
	return g_ePlayerData[get_param(1)][PDATA_ADMIN_LISTEN]
	
public _cm_update_player_data(iPlugin, iParams)
	UpdateData(get_param(1))