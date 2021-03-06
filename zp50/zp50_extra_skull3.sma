//=========================================================================
#define CSW_WEAPON		CSW_UMP45
new const g_weapon_entity[]=	"weapon_ump45"
new const g_weaponbox_model[]=	"models/w_ump45.mdl"
#define CSW_WEAPON_2		CSW_AUG
new const g_weapon_entity_2[]=	"weapon_aug"

#define WEAPON_NAME		"Skull-3"
#define WEAPON_COST		0

#define DAMAGE			35.0
#define RECOIL			0.5
#define RATE_OF_FIRE		0.12
#define CLIP			35
#define CLIP_2		70
#define AMMO			240
#define TIME_RELOAD		3.4

#define ANIM_IDLE		0
#define ANIM_SHOOT_1		random_num(1,2)
#define ANIM_RELOAD		3
#define ANIM_DRAW		4
#define ANIM_CHANGE		5
#define ANIM_SHOOT_EX		7

#define BODY_NUMBER		0
new const MODELS[][]={
				"models/csobc/v_skull3.mdl",
				"models/csobc/p_skull3.mdl",
				"models/csobc/w_skull3.mdl"
}
new const SOUNDS[][]= {
				"weapons/skull3-1.wav",
				"weapons/skull3_boltpull.wav",
				"weapons/skull3_clipin.wav",
				"weapons/skull3_clipout.wav",
				"weapons/skull3_idle.wav"
}
#define WEAPONLIST		"csobc_skull3d"
#define WEAPONLIST_2	"csobc_skull3"
new const SPRITES[][]=	{
				"sprites/csobc/640hud2.spr",
				"sprites/csobc/640hud68.spr"
}
//=========================================================================
#include <amxmodx>
#include <engine>
#include <xs>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <zp50_items>
native zp_tattoo_get(id)
new g_msgWeaponList,g_wpn_variables[10],g_wpn_variables_2[10],g_iszWeaponKey,g_index_smoke,g_index_shell,g_itemid
#define is_valid_weapon(%1) (pev_valid(%1)&&pev(%1, pev_impulse) == g_iszWeaponKey)
#define SHOOT_LEFT		(1<<1)
#define SKULL3_MODE		(1<<3)
public plugin_precache() {
		for(new i;i<=charsmax(MODELS);i++)precache_model(MODELS[i])
		for(new i;i<=charsmax(SOUNDS);i++)precache_sound(SOUNDS[i])
		for(new i;i<=charsmax(SPRITES);i++) precache_generic(SPRITES[i])
		new tmp[64];formatex(tmp,charsmax(tmp),"sprites/%s.txt",WEAPONLIST)
		precache_generic(tmp)
		formatex(tmp,charsmax(tmp),"sprites/%s.txt",WEAPONLIST_2)
		precache_generic(tmp)
		for(new i;i<=charsmax(SPRITES);i++)precache_generic(SPRITES[i])
		g_index_smoke=precache_model("sprites/wall_puff1.spr")
		g_index_shell=precache_model("models/pshell.mdl")
		g_iszWeaponKey = engfunc(EngFunc_AllocString, WEAPON_NAME)
		register_clcmd(WEAPONLIST, "clcmd_weapon")
		register_clcmd(WEAPONLIST_2, "clcmd_weapon_2")
		register_message(78, "message_weaponlist")
}
public plugin_init() {
		register_forward(FM_SetModel, "fm_setmodel")
		register_forward(FM_UpdateClientData, "fm_updateclientdata_post", 1)
		register_forward(FM_PlaybackEvent, "fm_playbackevent")
		RegisterHam(Ham_Item_Deploy, g_weapon_entity, "ham_item_deploy_post",1)
		RegisterHam(Ham_Weapon_PrimaryAttack, g_weapon_entity, "ham_weapon_primaryattack")
		RegisterHam(Ham_Weapon_Reload, g_weapon_entity, "ham_weapon_reload")
		RegisterHam(Ham_Weapon_WeaponIdle, g_weapon_entity, "ham_weapon_idle")
		RegisterHam(Ham_Item_PostFrame, g_weapon_entity, "ham_item_postframe")
		RegisterHam(Ham_Item_AddToPlayer, g_weapon_entity, "ham_item_addtoplayer")
		RegisterHam(Ham_Item_AttachToPlayer, g_weapon_entity, "ham_item_attachtoplayer_p", 1)
		RegisterHam(Ham_RemovePlayerItem, "player", "ham_player_removeitem_p", 1)
		RegisterHam(Ham_TraceAttack, "player", "ham_traceattack_post",1)
		RegisterHam(Ham_TraceAttack, "worldspawn", "ham_traceattack_post",1)
		RegisterHam(Ham_TraceAttack, "func_breakable", "ham_traceattack_post",1)
		g_msgWeaponList=get_user_msgid("WeaponList")
		g_iszWeaponKey=engfunc(EngFunc_AllocString, WEAPON_NAME)
		g_itemid=zp_items_register(WEAPON_NAME,WEAPON_COST)
}
public clcmd_weapon(id)
{	
	engclient_cmd(id, g_weapon_entity)
	
	static weapon_entity; weapon_entity=get_pdata_cbase(id,373,5)
	if(!is_valid_weapon(weapon_entity))return HAM_HANDLED
	
	if(get_pdata_float(id,83,5)>0.0)return HAM_HANDLED
	
	new weapstate = get_pdata_int(weapon_entity, 74, 4)
	
	if(!(weapstate&SKULL3_MODE)){
		play_weapon_animation(id, ANIM_CHANGE)
		set_pdata_int(weapon_entity, 74, weapstate|SKULL3_MODE, 4)
		set_pdata_float(weapon_entity, 46, 3.0, 4)
		set_pdata_float(weapon_entity, 48, 3.0, 4)
		set_pdata_int(weapon_entity,54,1,4)
		set_pdata_float(id,83,3.0,5)
	}
	return HAM_HANDLED
}
public clcmd_weapon_2(id)
{
	engclient_cmd(id, g_weapon_entity)
	
	static weapon_entity; weapon_entity=get_pdata_cbase(id,373,5)
	if(!is_valid_weapon(weapon_entity))return HAM_HANDLED
	
	if(get_pdata_float(id,83,5)>0.0)return HAM_HANDLED
	
	new weapstate = get_pdata_int(weapon_entity, 74, 4)
	
	if(weapstate&SKULL3_MODE){
		play_weapon_animation(id, ANIM_CHANGE+6)
		set_pdata_int(weapon_entity, 74, weapstate&~SKULL3_MODE, 4)
		set_pdata_float(weapon_entity, 46, 3.0, 4)
		set_pdata_float(weapon_entity, 48, 3.0, 4)
		set_pdata_int(weapon_entity,54,1,4)
		set_pdata_float(id,83,3.0,5)
	}
	
	return HAM_HANDLED
}
public message_weaponlist(msg_id,msg_dest,id){
	if(get_msg_arg_int(8)==CSW_WEAPON)for(new i=2;i<=9;i++)g_wpn_variables[i]=get_msg_arg_int(i)
	if(get_msg_arg_int(8)==CSW_WEAPON_2)for(new i=2;i<=9;i++)g_wpn_variables_2[i]=get_msg_arg_int(i)
}
public fm_setmodel(model_entity,model[]){
	if(!pev_valid(model_entity)||!equal(model,g_weaponbox_model))return FMRES_IGNORED			
	static weap;weap=fm_find_ent_by_owner(-1,g_weapon_entity,model_entity)	
	if(!is_valid_weapon(weap))return FMRES_IGNORED	
	fm_entity_set_model(model_entity,MODELS[2])
	set_pev(model_entity,pev_body,BODY_NUMBER)
	
	return FMRES_SUPERCEDE
}
public fm_updateclientdata_post(id,SendWeapons,CD_Handle){
	if(!is_user_alive(id))return
	static weapon_ent; weapon_ent=get_pdata_cbase(id,373,5)
	if(is_valid_weapon(weapon_ent))set_cd(CD_Handle, CD_flNextAttack, get_gametime()+0.001)
}
public fm_playbackevent(flags,id){
	if(!is_user_alive(id))return FMRES_IGNORED
	static weapon_ent;weapon_ent=get_pdata_cbase(id, 373, 5)
	if(!is_valid_weapon(weapon_ent))return FMRES_IGNORED
	return FMRES_SUPERCEDE
}
public ham_item_deploy_post(weapon_ent){
	if(!is_valid_weapon(weapon_ent))return
	static id;id=get_pdata_cbase(weapon_ent,41,4)
	set_pev(id, pev_viewmodel2, MODELS[0]),set_pev(id, pev_weaponmodel2, MODELS[1])
	play_weapon_animation(id,(get_pdata_int(weapon_ent, 74, 4)&SKULL3_MODE)?ANIM_DRAW+6:ANIM_DRAW)
	set_pdata_float(id, 83, 0.5, 5),set_pdata_float(weapon_ent, 48, 1.4, 4)
}
public ham_weapon_primaryattack(weapon_entity) {
	if(!is_valid_weapon(weapon_entity))return HAM_IGNORED
	if(get_pdata_float(weapon_entity,46,4)>0.0||!get_pdata_int(weapon_entity,51,4))return HAM_IGNORED
	static id; id = get_pdata_cbase(weapon_entity, 41, 4)
	static clip;clip=get_pdata_int(weapon_entity,51,4)
	ExecuteHam(Ham_Weapon_PrimaryAttack, weapon_entity)
	if(clip<=get_pdata_int(weapon_entity,51,4))return HAM_IGNORED
	emit_sound(id, CHAN_WEAPON, SOUNDS[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	new weapstate = get_pdata_int(weapon_entity, 74, 4)
	
	if((weapstate&SHOOT_LEFT)&&(weapstate&SKULL3_MODE)){
		play_weapon_animation(id, ANIM_SHOOT_EX)
		set_pdata_int(weapon_entity, 74, weapstate&~SHOOT_LEFT, 4)
	}else if((weapstate&SKULL3_MODE)){
		play_weapon_animation(id, ANIM_SHOOT_EX+1)
		set_pdata_int(weapon_entity, 74, weapstate|SHOOT_LEFT, 4)
	}else play_weapon_animation(id, ANIM_SHOOT_1)
		
	set_pdata_float(weapon_entity,46,RATE_OF_FIRE,4)
	set_pdata_float(weapon_entity, 48, RATE_OF_FIRE+0.5, 4)
	set_pdata_int(weapon_entity, 64,get_pdata_int(weapon_entity, 64, 4)+1,4)
	set_pdata_int(weapon_entity,57,g_index_shell,4) 
	set_pdata_float(id,111,get_gametime())
	set_pdata_float(weapon_entity,62,RECOIL,4)
	return HAM_SUPERCEDE
}
public ham_weapon_reload(weapon_entity) {
	if(!is_valid_weapon(weapon_entity))return HAM_IGNORED
	static id; id = get_pdata_cbase(weapon_entity,41,4)
	static bpammo;bpammo=get_pdata_int(id,376+get_pdata_int(weapon_entity,49,4),5)
	static clip;clip=get_pdata_int(weapon_entity,51,4)
	if(!bpammo||clip==CLIP)return HAM_SUPERCEDE
	ExecuteHam(Ham_Weapon_Reload,weapon_entity)
	play_weapon_animation(id,(get_pdata_int(weapon_entity, 74, 4)&SKULL3_MODE)?ANIM_RELOAD+6:ANIM_RELOAD)
	set_pdata_int(id,363,90,5)
	set_pdata_float(id,83,TIME_RELOAD,5)
	set_pdata_int(weapon_entity,54,1,4)
	return HAM_SUPERCEDE
}
public ham_weapon_idle(ent) {
	if(!is_valid_weapon(ent))return HAM_IGNORED
	static id; id = get_pdata_cbase(ent, 41, 4)
	if(get_pdata_float(ent, 48, 4)>0.0)return HAM_IGNORED
	play_weapon_animation(id,(get_pdata_int(ent, 74, 4)&SKULL3_MODE)?ANIM_IDLE+6:ANIM_IDLE)
	set_pdata_float(ent, 48, 5.0, 4)
	return HAM_SUPERCEDE
}
public ham_item_postframe(weapon_entity)  {
	if(!is_valid_weapon(weapon_entity)) return
	static id; id = get_pdata_cbase(weapon_entity,41,4)
	if(get_pdata_int(weapon_entity, 54, 4)&&get_pdata_float(id, 83, 5)<=0.0){		
		static bpammo;bpammo=get_pdata_int(id, 376 + get_pdata_int(weapon_entity, 49, 4), 5)
		static clip;clip=get_pdata_int(weapon_entity, 51, 4)
		if(get_pdata_int(weapon_entity, 74, 4)&SKULL3_MODE){
		for(new i=clip; i<CLIP_2;i++)if(bpammo)bpammo--,clip++	
		} else {
		if(clip>CLIP){
		bpammo+=clip-CLIP,clip=CLIP
		}
		else for(new i=clip; i<CLIP;i++)if(bpammo)bpammo--,clip++	
		}
		set_pdata_int(weapon_entity,54,0,4)
		set_pdata_int(weapon_entity,51,clip,4)
		set_pdata_int(id,376+get_pdata_int(weapon_entity,49,4),bpammo,5)
	}
}
public ham_item_addtoplayer(weapon_entity,id){
	if(is_valid_weapon(weapon_entity)){
		set_weaponlist(id,1),set_weaponlist_2(id,1)
	}
}
public ham_item_attachtoplayer_p(weapon_entity,id){
	if(is_valid_weapon(weapon_entity)){
		give_weapon2(id)
	}
}
public ham_player_removeitem_p(id,weapon_entity) if(is_valid_weapon(weapon_entity)) fm_strip_user_gun(id, CSW_WEAPON_2, g_weapon_entity_2)
public ham_traceattack_post(pEntity,attacker,Float:flDamage,Float:direction[3],ptr,damage_type) {
	if(!is_user_connected(attacker)||!(damage_type&DMG_BULLET))return
	static weapon_entity;weapon_entity=get_pdata_cbase(attacker, 373, 5)
	if(!is_valid_weapon(weapon_entity))return
	new Float:vecEnd[3],Float:vecPlane[3]
	get_tr2(ptr,TR_vecEndPos,vecEnd)
	get_tr2(ptr,TR_vecPlaneNormal,vecPlane)
	xs_vec_mul_scalar(vecPlane,5.0,vecPlane)
        if(!is_user_alive(pEntity)){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord,vecEnd[0])
		engfunc(EngFunc_WriteCoord,vecEnd[1])
		engfunc(EngFunc_WriteCoord,vecEnd[2])
		write_short(pEntity)
		write_byte(random_num(41,45))
		message_end()
		xs_vec_add(vecEnd,vecPlane,vecEnd)
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_EXPLOSION)
		engfunc(EngFunc_WriteCoord,vecEnd[0])
		engfunc(EngFunc_WriteCoord,vecEnd[1])
		engfunc(EngFunc_WriteCoord,vecEnd[2]-10.0)
		write_short(g_index_smoke)
		write_byte(3)
		write_byte(50)
		write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS|TE_EXPLFLAG_NOPARTICLES)
		message_end()
	}
}
public zp_fw_items_select_post(id,itemid) {
	if(itemid!=g_itemid)return
	new Ent=give_weapon(id)
	set_pdata_int(id,376+get_pdata_int(Ent,49,4),AMMO,5)
}
public plugin_natives()
	register_native("zp_give_item_skull3", "zp_give_item_skull3", 1);
public zp_give_item_skull3(id)
{
	new Ent=give_weapon(id)
	set_pdata_int(id,376+get_pdata_int(Ent,49,4),AMMO,5)
}
public give_weapon(id){
	new Float:Origin[3]; pev(id, pev_origin, Origin)
	new wName[32],iItem=get_pdata_cbase(id, 367+1, 5);
	while (pev_valid(iItem)==2)pev(iItem,pev_classname,wName,31),engclient_cmd(id,"drop",wName),iItem=get_pdata_cbase(iItem, 42, 4)
	new iWeapon=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,g_weapon_entity))
	if(!pev_valid(iWeapon)) return 0
	dllfunc(DLLFunc_Spawn, iWeapon)
	engfunc(EngFunc_SetOrigin, iWeapon, Origin)
	set_pev(iWeapon, pev_impulse, g_iszWeaponKey)
	set_pdata_int(iWeapon, 51, CLIP, 4)
	new save = pev(iWeapon,pev_solid)
	dllfunc(DLLFunc_Touch,iWeapon,id)
	if(pev(iWeapon, pev_solid)!=save){
		return iWeapon
	}
	engfunc(EngFunc_RemoveEntity,iWeapon)
	return 0
}
public give_weapon2(id){
	new Float:Origin[3]; pev(id, pev_origin, Origin)
	new iWeapon=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,g_weapon_entity_2))
	if(!pev_valid(iWeapon)) return 0
	dllfunc(DLLFunc_Spawn, iWeapon)
	engfunc(EngFunc_SetOrigin, iWeapon, Origin)
	set_pev(iWeapon, pev_impulse, g_iszWeaponKey)
	new save = pev(iWeapon,pev_solid)
	dllfunc(DLLFunc_Touch,iWeapon,id)
	if(pev(iWeapon, pev_solid)!=save) {
		engclient_cmd(id, g_weapon_entity)
		return iWeapon
	}
	engfunc(EngFunc_RemoveEntity,iWeapon)
	return 0
}
stock play_weapon_animation(id,sequence)message_begin(MSG_ONE,SVC_WEAPONANIM,_,id),write_byte(sequence),write_byte(zp_tattoo_get(id)),message_end()
stock set_weaponlist(id,num=0){
	message_begin(MSG_ONE,g_msgWeaponList,_,id)
	write_string(num?WEAPONLIST:g_weapon_entity) 
	for(new i=2;i<=9;i++)write_byte(g_wpn_variables[i]) 
	message_end()
}
stock set_weaponlist_2(id,num=0){
	message_begin(MSG_ONE,g_msgWeaponList,_,id)
	write_string(num?WEAPONLIST_2:g_weapon_entity_2) 
	for(new i=2;i<=9;i++)write_byte(g_wpn_variables_2[i]) 
	message_end()
}
forward damage_pre(id)
native damage_set(id, Float:dmg)
public damage_pre(attacker)
{
	static weapon_ent; weapon_ent=get_pdata_cbase(attacker,373,5)
	if(is_valid_weapon(weapon_ent)) {
		damage_set(attacker, DAMAGE)
		return 1
	}
	return 0
}