/* Plugin generated by AMXX-Studio */
#include <amxmodx>
#include <hamsandwich>
#include <ColorChat>

#define PLUGIN "Poprawne Rate i Interp"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define TASK_CHECK 765

new MinInterp, MaxInterp, MinRate, MaxRate, MinUpdateRate, MaxUpdateRate, MinCmdRate, MaxCmdRate, Choosed[33];
new bool:SteamValid[33];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("say /interp", "MenuChoose");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	MinInterp =	register_cvar("amx_mininterp","0.01");
	MaxInterp = register_cvar("amx_maxinterp","0.03");
	MinRate = register_cvar("amx_minrate","20000");
	MaxRate = register_cvar("amx_maxrate","99999");
	MinUpdateRate = register_cvar("amx_minupdaterate","70");
	MaxUpdateRate = register_cvar("amx_maxupdaterate","101");
	MinCmdRate = register_cvar("amx_mincmdrate","70");
	MaxCmdRate = register_cvar("amx_maxcmdrate","101");
}

public client_disconnect(id)
	remove_task(id+TASK_CHECK)

public client_putinserver(id) {
	if(is_user_steam(id))
		SteamValid[id] = true;
	Choosed[id] = 0;
}
	
public Spawn(id) {
	if(is_user_alive(id)) {
		if(task_exists(id+TASK_CHECK))
			remove_task(id+TASK_CHECK);
		set_task(0.1, "Check", id+TASK_CHECK);
	}
}

public Check(id) {
	id -= TASK_CHECK;
	if(is_user_alive(id)) {
		if(Choosed[id]) {
			switch(Choosed[id]) {
			case 1: {
				client_cmd(id,"ex_interp 0.01");
				client_cmd(id,"rate 25000");
				client_cmd(id,"cl_updaterate 101");
				client_cmd(id,"cl_cmdrate 101");
				}
			case 2: {
				client_cmd(id, "ex_interp 0.02");
				client_cmd(id, "cl_updaterate 85");
				client_cmd(id, "cl_cmdrate 85");
				client_cmd(id, "rate 22500");
				}
			case 3: {
				client_cmd(id, "ex_interp 0.03");
				client_cmd(id, "cl_updaterate 70");
				client_cmd(id, "cl_cmdrate 70");
				client_cmd(id, "rate 20000");
				}
			}
			set_hudmessage(255, 10, 0, 0.05, 0.35, 2, 0.1, 1.0, 0.1, 0.5, -1)
			show_hudmessage(id, "Serwer ustawil poprawne rate i interp!")
		}
		else {
			Choose(id);
		}
	}
	set_task(60.0, "Check", id+TASK_CHECK); 
}

public Choose(id) {
	if(SteamValid[id]) {
		query_client_cvar(id,"ex_interp","CheckInterp");
		query_client_cvar(id,"rate","CheckRate");
		query_client_cvar(id,"cl_updaterate","CheckUpdateRate");
		query_client_cvar(id,"cl_cmdrate","CheckCmdRate");
	}
	else
		MenuChoose(id);
}

public MenuChoose(id) {
	new menu = menu_create("Wybierz Interp", "MenuChoose_Handler")
	menu_additem(menu, "Interp - 0.01");
	menu_additem(menu, "Interp - 0.02");
	menu_additem(menu, "Interp - 0.03");
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0);
}

public MenuChoose_Handler(id, menu, item) {
	switch(item){
	case 0: {
		Choosed[id] = 1;	
		client_cmd(id,"ex_interp 0.01");
		client_cmd(id,"rate 25000");
		client_cmd(id,"cl_updaterate 101");
		client_cmd(id,"cl_cmdrate 101");
		ColorChat(id, GREEN, "[INTERP]^x01 Wybrales interp 0.01, rate 25000, cl_updaterate 101, cl_cmdrate 101.");
		ColorChat(id, GREEN, "[INTERP]^x01 Jesli chcesz zmienic interp wpisz^x03 /interp^x01.");
		}
	case 1: {
		Choosed[id] = 2;
		client_cmd(id, "ex_interp 0.02");
		client_cmd(id, "cl_updaterate 85");
		client_cmd(id, "cl_cmdrate 85");
		client_cmd(id, "rate 22500");
		ColorChat(id, GREEN, "[INTERP]^x01 Wybrales interp 0.02, rate 22500, cl_updaterate 85, cl_cmdrate 85.");
		ColorChat(id, GREEN, "[INTERP]^x01 Jesli chcesz zmienic interp wpisz^x03 /interp^x01.");
		}
	case 2: {
		Choosed[id] = 3;
		client_cmd(id, "ex_interp 0.03");
		client_cmd(id, "cl_updaterate 70");
		client_cmd(id, "cl_cmdrate 70");
		client_cmd(id, "rate 20000");
		ColorChat(id, GREEN, "[INTERP]^x01 Wybrales interp 0.03, rate 20000, cl_updaterate 70, cl_cmdrate 70.");
		ColorChat(id, GREEN, "[INTERP]^x01 Jesli chcesz zmienic interp wpisz^x03 /interp^x01.");
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
} 

public CheckInterp(id, const cvar[], const value[]) {
	new Float:Interp = str_to_float(value);
	new Float:Min_Interp = get_pcvar_float(MinInterp);
	new Float:Max_Interp = get_pcvar_float(MaxInterp);
	if(Interp < Min_Interp-0.001 || Interp > Max_Interp+0.001)
		client_cmd(id,"ex_interp 0.01");
}

public CheckRate(id, const cvar[], const value[]) {
	new Float:Rate = str_to_float(value);
	new Float:Min_Rate = get_pcvar_float(MinRate);
	new Float:Max_Rate = get_pcvar_float(MaxRate);
	if(Rate < Min_Rate-0.001 || Rate > Max_Rate+0.001)
		MenuChoose(id);
}

public CheckUpdateRate(id, const cvar[], const value[]) {
	new Float:UpdateRate = str_to_float(value);
	new Float:Min_UpdateRate = get_pcvar_float(MinUpdateRate);
	new Float:Max_UpdateRate = get_pcvar_float(MaxUpdateRate);
	if(UpdateRate < Min_UpdateRate-0.001 || UpdateRate > Max_UpdateRate+0.001)
		MenuChoose(id);
}

public CheckCmdRate(id, const cvar[], const value[]) {
	new Float:CmdRate = str_to_float(value);
	new Float:Min_CmdRate = get_pcvar_float(MinCmdRate);
	new Float:Max_CmdRate = get_pcvar_float(MaxCmdRate);
	if(CmdRate < Min_CmdRate-0.001 || CmdRate > Max_CmdRate+0.001)
		MenuChoose(id);
}

stock is_user_steam(id) {
	new g_Steam[35];
	get_user_authid(id, g_Steam, charsmax(g_Steam));
	return bool:(contain(g_Steam, "STEAM_0:0:") != -1 || contain(g_Steam, "STEAM_0:1:") != -1);
}