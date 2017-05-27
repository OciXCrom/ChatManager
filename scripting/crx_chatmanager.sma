#include <amxmodx>
#include <amxmisc>
#include <cromchat>
#include <cstrike>

#define PLUGIN_VERSION "3.0"
#define DELAY_ON_CONNECT 1.0
#define DELAY_ON_CHANGE 0.1
#define MAX_ARG_SIZE 20

enum
{
	SECTION_NONE,
	SECTION_SETTINGS,
	SECTION_ADMIN_PREFIXES,
	SECTION_CHAT_COLORS
}

enum _:Settings
{
	ADMIN_LISTEN_FLAGS[32],
	DEAD_PREFIX[32],
	ALIVE_PREFIX[32],
	TEAM_PREFIX_T[32],
	TEAM_PREFIX_CT[32],
	TEAM_PREFIX_SPEC[32],
	FORMAT_SAY[128],
	FORMAT_SAY_TEAM[128]
}

enum _:Args
{
	ARG_ADMIN_PREFIX[MAX_ARG_SIZE],
	ARG_DEAD_PREFIX[MAX_ARG_SIZE],
	ARG_TEAM[MAX_ARG_SIZE],
	ARG_NAME[MAX_ARG_SIZE],
	ARG_CHAT_COLOR[MAX_ARG_SIZE],
	ARG_MESSAGE[MAX_ARG_SIZE]
}

new const g_eArgs[Args] = { "%admin_prefix%", "%dead_prefix%", "%team%", "%name%", "%chat_color%", "%message%" }

new g_eSettings[Settings],
	g_szAdminPrefix[33][32],
	g_szChatColor[33][6],
	bool:g_bAdminListen[33],
	Array:g_aAdminFlags,
	Array:g_aAdminPrefixes,
	Array:g_aChatColors,
	Array:g_aChatColorsFlags,
	Trie:g_tBlockFirst,
	g_iAdminPrefixes,
	g_iChatColors

public plugin_init()
{
	register_plugin("Chat Manager", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXChatManager", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_clcmd("say", "Hook_Say")
	register_clcmd("say_team", "Hook_Say")
	g_aAdminFlags = ArrayCreate(32)
	g_aAdminPrefixes = ArrayCreate(32)
	g_aChatColors = ArrayCreate(6)
	g_aChatColorsFlags = ArrayCreate(32)
	g_tBlockFirst = TrieCreate()
	ReadFile()
}

public plugin_end()
{
	ArrayDestroy(g_aAdminFlags)
	ArrayDestroy(g_aAdminPrefixes)
	ArrayDestroy(g_aChatColors)
	ArrayDestroy(g_aChatColorsFlags)
	TrieDestroy(g_tBlockFirst)
}

public client_connect(id)
	set_task(DELAY_ON_CONNECT, "UpdateData", id)
	
public client_infochanged(id)
{
	if(!is_user_connected(id))
		return
		
	new szNewName[32], szOldName[32]
	get_user_info(id, "name", szNewName, charsmax(szNewName))
	get_user_name(id, szOldName, charsmax(szOldName))
	
	if(!equal(szNewName, szOldName))
		set_task(DELAY_ON_CHANGE, "UpdateData", id)
}
	
public UpdateData(id)
{
	new szFlags[32], i
	
	if(g_iAdminPrefixes)
	{
		g_szAdminPrefix[id][0] = EOS
		
		for(i = 0; i < g_iAdminPrefixes; i++)
		{
			ArrayGetString(g_aAdminFlags, i, szFlags, charsmax(szFlags))
			
			if(has_all_flags(id, szFlags))
			{
				ArrayGetString(g_aAdminPrefixes, i, g_szAdminPrefix[id], charsmax(g_szAdminPrefix[]))
				break
			}
		}
	}
	
	if(g_iChatColors)
	{
		g_szChatColor[id][0] = EOS
		
		for(i = 0; i < g_iChatColors; i++)
		{
			ArrayGetString(g_aChatColorsFlags, i, szFlags, charsmax(szFlags))
			
			if(has_all_flags(id, szFlags))
			{
				ArrayGetString(g_aChatColors, i, g_szChatColor[id], charsmax(g_szChatColor[]))
				break
			}
		}
	}
	
	if(g_eSettings[ADMIN_LISTEN_FLAGS][0])
		g_bAdminListen[id] = bool:has_all_flags(id, g_eSettings[ADMIN_LISTEN_FLAGS])
}

public Hook_Say(id)
{
	new szArgs[192]
	read_args(szArgs, charsmax(szArgs)); remove_quotes(szArgs)
	CC_RemoveColors(szArgs, charsmax(szArgs))
	
	if(!szArgs[0] || TrieKeyExists(g_tBlockFirst, szArgs[0]))
		return PLUGIN_HANDLED
		
	new szCommand[5]
	read_argv(0, szCommand, charsmax(szCommand))
	
	new szMessage[192], iPlayers[32], iPnum, bool:bTeam = szCommand[3] == '_', iAlive = is_user_alive(id), CsTeams:iTeam = cs_get_user_team(id)
	format_chat_message(bTeam, id, iAlive, iTeam, szArgs, szMessage, charsmax(szMessage))
	get_players(iPlayers, iPnum, "ch")
	
	for(new i, iPlayer; i < iPnum; i++)
	{
		iPlayer = iPlayers[i]
		
		if(g_bAdminListen[iPlayer] || iAlive == is_user_alive(iPlayer) || (bTeam && iTeam == cs_get_user_team(iPlayer)))
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
		new szData[192], szValue[160], szKey[32], iSection = SECTION_NONE, iSize
		
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
							default: iSection = SECTION_NONE
						}
					}
					else continue
				}
				default:
				{
					if(iSection == SECTION_NONE)
						continue
						
					strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
					trim(szKey); trim(szValue)
							
					if(!szValue[0])
						continue
						
					switch(iSection)
					{
						case SECTION_SETTINGS:
						{
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
							else if(equal(szKey, "FORMAT_SAY"))
								copy(g_eSettings[FORMAT_SAY], charsmax(g_eSettings[FORMAT_SAY]), szValue)
							else if(equal(szKey, "FORMAT_SAY_TEAM"))
								copy(g_eSettings[FORMAT_SAY_TEAM], charsmax(g_eSettings[FORMAT_SAY_TEAM]), szValue)
						}
						case SECTION_ADMIN_PREFIXES:
						{
							ArrayPushString(g_aAdminFlags, szKey)
							ArrayPushString(g_aAdminPrefixes, szValue)
							g_iAdminPrefixes++
						}
						case SECTION_CHAT_COLORS:
						{
							ArrayPushString(g_aChatColorsFlags, szKey)
							ArrayPushString(g_aChatColors, szValue)
							g_iChatColors++
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
	copy(szMessage, iLen, g_eSettings[bTeam ? FORMAT_SAY_TEAM : FORMAT_SAY])
	replace_all(szMessage, iLen, g_eArgs[ARG_ADMIN_PREFIX], g_szAdminPrefix[id])
	replace_all(szMessage, iLen, g_eArgs[ARG_DEAD_PREFIX], g_eSettings[iAlive ? ALIVE_PREFIX : DEAD_PREFIX])
	replace_all(szMessage, iLen, g_eArgs[ARG_TEAM], g_eSettings[iTeam == CS_TEAM_CT ? TEAM_PREFIX_CT : iTeam == CS_TEAM_T ? TEAM_PREFIX_T : TEAM_PREFIX_SPEC])
	replace_all(szMessage, iLen, g_eArgs[ARG_CHAT_COLOR], g_szChatColor[id])
	replace_all(szMessage, iLen, g_eArgs[ARG_MESSAGE], szArgs)
	
	if(contain(szMessage, g_eArgs[ARG_NAME]))
	{
		new szName[32]
		get_user_name(id, szName, charsmax(szName))	
		replace_all(szMessage, iLen, g_eArgs[ARG_NAME], szName)
	}
	
	replace_all(szMessage, iLen, "  ", " "); trim(szMessage)
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
}

public _cm_get_admin_prefix(iPlugin, iParams)
	set_string(2, g_szAdminPrefix[get_param(1)], get_param(3))
	
public _cm_get_chat_color(iPlugin, iParams)
	set_string(2, g_szChatColor[get_param(1)], get_param(3))
	
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
	return g_bAdminListen[get_param(1)]