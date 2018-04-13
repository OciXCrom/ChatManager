#include <amxmodx>
#include <chatmanager>

#define PLUGIN_VERSION "4.1"

enum
{
	CM_MENU_ITEM_PREFIX,
	CM_MENU_ITEM_CHAT_COLOR,
	CM_MENU_ITEM_CUSTOM_NAME
}

public plugin_init()
{
	register_plugin("CM: Toggle Chat", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXCMToggleChat", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_dictionary("ChatManager.txt")
	register_clcmd("say /cm", "Menu_Display")
	register_clcmd("say_team /cm", "Menu_Display")
}

public Menu_Display(id)
{
	new szText[128]
	formatex(szText, charsmax(szText), "%L", id, "CM_MENU_TITLE")
	
	new iMenu = menu_create(szText, "Menu_Handler")

	formatex(szText, charsmax(szText), "%L %L", id, "CM_MENU_PREFIX", id, cm_get_user_prefix_status(id) ? "CM_MENU_ENABLED" : "CM_MENU_DISABLED")
	menu_additem(iMenu, szText)
	
	formatex(szText, charsmax(szText), "%L %L", id, "CM_MENU_CHAT_COLOR", id, cm_get_user_chat_color_status(id) ? "CM_MENU_ENABLED" : "CM_MENU_DISABLED")
	menu_additem(iMenu, szText)
	
	formatex(szText, charsmax(szText), "%L %L", id, "CM_MENU_CUSTOM_NAME", id, cm_get_user_custom_name_status(id) ? "CM_MENU_ENABLED" : "CM_MENU_DISABLED")
	menu_additem(iMenu, szText)
	
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public Menu_Handler(id, iMenu, iItem)
{
	switch(iItem)
	{
		case MENU_EXIT:
		{
			menu_destroy(iMenu)
			return PLUGIN_HANDLED
		}
		case CM_MENU_ITEM_PREFIX: cm_set_user_prefix_status(id, !cm_get_user_prefix_status(id))
		case CM_MENU_ITEM_CHAT_COLOR: cm_set_user_chat_color_status(id, !cm_get_user_chat_color_status(id))
		case CM_MENU_ITEM_CUSTOM_NAME: cm_set_user_custom_name_status(id, !cm_get_user_custom_name_status(id))
	}
	
	menu_destroy(iMenu)
	Menu_Display(id)
	return PLUGIN_HANDLED
}