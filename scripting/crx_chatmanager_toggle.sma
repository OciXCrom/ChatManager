#include <amxmodx>
#include <chatmanager>
#include <cromchat>

#define PLUGIN_VERSION "3.6.*"

public plugin_init()
{
	register_plugin("CM: Toggle Chat", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXCMToggleChat", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_clcmd("say /prefix", "Cmd_TogglePrefix")
	register_clcmd("say_team /prefix", "Cmd_TogglePrefix")
	register_clcmd("say /colorchat", "Cmd_ToggleColorchat")
	register_clcmd("say_team /colorchat", "Cmd_ToggleColorchat")
	CC_SetPrefix("&x04[Chat Manager]")
}

public Cmd_TogglePrefix(id)
{
	new bool:bOld = cm_get_prefix_status(id)
	cm_set_prefix_status(id, !bOld)
	CC_SendMessage(id, "Prefix %s&x01.", bOld ? "&x07disabled" : "&x06enabled")
	return PLUGIN_HANDLED
}

public Cmd_ToggleColorchat(id)
{
	new bool:bOld = cm_get_colorchat_status(id)
	cm_set_colorchat_status(id, !bOld)
	CC_SendMessage(id, "Colorchat %s&x01.", bOld ? "&x07disabled" : "&x06enabled")	
	return PLUGIN_HANDLED
}