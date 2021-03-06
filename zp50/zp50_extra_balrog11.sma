//=========================================================================
#define CSW_WEAPON		CSW_XM1014
new const g_weapon_entity[]=	"weapon_xm1014"
new const g_weaponbox_model[]=	"models/w_xm1014.mdl"

#define WEAPON_NAME		"Balrog-11"
#define WEAPON_COST		0

#define DAMAGE			85.0
#define RECOIL			0.5
#define RATE_OF_FIRE		0.25
#define CLIP			7
#define AMMO			28
#define TIME_RELOAD		2.4

#define ANIM_IDLE		0
#define ANIM_SHOOT_1		random_num(1,2)
#define ANIM_SHOOT_EX		3
#define ANIM_DRAW		7

#define BODY_NUMBER		0
new const MODELS[][]={
				"models/csobc/v_balrog11.mdl",
				"models/csobc/p_balrog11.mdl",
				"models/csobc/w_balrog11.mdl"
}
new const SOUNDS[][]= {
				"weapons/balrog11-1.wav",
				"weapons/balrog11-2.wav",
				"weapons/balrog11_charge.wav",
				"weapons/balrog11_draw.wav",
				"weapons/balrog11_insert.wav"
}
#define WEAPONLIST		"csobc_balrog11"
new const SPRITES[][]=	{
				"sprites/csobc/640hud3.spr",
				"sprites/csobc/640hud89.spr"
}
new const GrenadeModel[]="sprites/csobc/flame_puff.spr"
//=========================================================================
#include <amxmodx>
#include <engine>
#include <xs>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <zp50_items>
native zp_tattoo_get(id)
native zp_grenade_fire_set(id)
new g_msgWeaponList,g_wpn_variables[10],g_iszWeaponKey,g_index_smoke,g_index_shell,g_itemid,g_iSecClip[33]
#define is_valid_weapon(%1) (pev_valid(%1)&&pev(%1, pev_impulse) == g_iszWeaponKey)
public plugin_precache() {
		for(new i;i<=charsmax(MODELS);i++)precache_model(MODELS[i])
		for(new i;i<=charsmax(SOUNDS);i++)precache_sound(SOUNDS[i])
		for(new i;i<=charsmax(SPRITES);i++) precache_generic(SPRITES[i])
		new tmp[32];formatex(tmp,charsmax(tmp),"sprites/%s.txt",WEAPONLIST)
		precache_generic(tmp)
		for(new i;i<=charsmax(SPRITES);i++)precache_generic(SPRITES[i])
		g_index_smoke=precache_model("sprites/wall_puff1.spr")
		g_index_shell=precache_model("models/csobc/s_balrog11.mdl")
		g_iszWeaponKey = engfunc(EngFunc_AllocString, WEAPON_NAME)
		register_clcmd(WEAPONLIST, "clcmd_weapon")
		register_message(78, "message_weaponlist")
		precache_model(GrenadeModel) 
}
public plugin_init() {
		register_forward(FM_CmdStart, "fm_cmdstart")
		register_forward(FM_SetModel, "fm_setmodel")
		register_forward(FM_UpdateClientData, "fm_updateclientdata_post", 1)
		register_forward(FM_PlaybackEvent, "fm_playbackevent")
		RegisterHam(Ham_Item_Deploy, g_weapon_entity, "ham_item_deploy_post",1)
		RegisterHam(Ham_Weapon_PrimaryAttack, g_weapon_entity, "ham_weapon_primaryattack")
		RegisterHam(Ham_Weapon_Reload, g_weapon_entity, "ham_weapon_reload")
		RegisterHam(Ham_Weapon_WeaponIdle, g_weapon_entity, "ham_weapon_idle")
		RegisterHam(Ham_Item_PostFrame, g_weapon_entity, "ham_item_postframe")
		RegisterHam(Ham_Item_AddToPlayer, g_weapon_entity, "ham_item_addtoplayer")
		RegisterHam(Ham_TraceAttack, "player", "ham_traceattack_post",1)
		RegisterHam(Ham_TraceAttack, "worldspawn", "ham_traceattack_post",1)
		RegisterHam(Ham_TraceAttack, "func_breakable", "ham_traceattack_post",1)
		g_msgWeaponList=get_user_msgid("WeaponList")
		g_iszWeaponKey=engfunc(EngFunc_AllocString, WEAPON_NAME)
		g_itemid=zp_items_register(WEAPON_NAME,WEAPON_COST)
		register_touch("balrog11 flame", "*", "fwTouch")
		register_think("balrog11 flame", "fwThink")	
}
public clcmd_weapon(id)engclient_cmd(id, g_weapon_entity)
public message_weaponlist(msg_id,msg_dest,id)if(get_msg_arg_int(8)==CSW_WEAPON)for(new i=2;i<=9;i++)g_wpn_variables[i]=get_msg_arg_int(i)
public fm_cmdstart(id,uc_handle,seed){
	if(!is_user_alive(id))return
	static weapon_entity;weapon_entity=get_pdata_cbase(id,373,5)
	if(!is_valid_weapon(weapon_entity)) return
	if((get_uc(uc_handle,UC_Buttons)&IN_ATTACK2)&&get_pdata_float(id,83,5)<=0.0&&get_pdata_float(weapon_entity,46,4)<=0.0){
		if(!g_iSecClip[id]) return
		CreateFlame(id)
		emit_sound(id, CHAN_WEAPON, SOUNDS[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		play_weapon_animation(id, ANIM_SHOOT_EX)
		set_pdata_float(weapon_entity,46,0.45,4)
		set_pdata_float(weapon_entity, 48, 2.2, 4)
		set_pdata_int(weapon_entity,57,g_index_shell,4) 
		set_pdata_float(id,111,get_gametime())
		g_iSecClip[id]--
	}
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
	play_weapon_animation(id, ANIM_DRAW)
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
	set_pdata_int(weapon_entity, 64, get_pdata_int(weapon_entity, 64, 4)+1,4)
	if(get_pdata_int(weapon_entity, 64, 4)==4){
		g_iSecClip[id]++
		emit_sound(id, CHAN_ITEM, SOUNDS[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		set_pdata_int(weapon_entity, 64, 0,4)
	}
	play_weapon_animation(id, ANIM_SHOOT_1)
	set_pdata_float(weapon_entity,46,RATE_OF_FIRE,4)
	
	if(get_pdata_int(weapon_entity,51,4)) set_pdata_float(weapon_entity, 48, 2.25, 4)
	else set_pdata_float(weapon_entity, 48, 0.75, 4)
	
	set_pdata_int(weapon_entity, 55, 0, 4)
	
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
	//ExecuteHam(Ham_Weapon_Reload,weapon_entity)
	Reload(id, weapon_entity)
	return HAM_SUPERCEDE
}
public ham_weapon_idle(ent) {
	if(!is_valid_weapon(ent))return HAM_IGNORED
	static id; id = get_pdata_cbase(ent, 41, 4)
	if(get_pdata_float(ent, 48, 4)>0.0)return HAM_IGNORED
	if(get_pdata_int(ent, 55, 4)){
		if(get_pdata_int(ent, 55, 4)==1) Reload(id, ent) 
		return HAM_IGNORED
	}else{
		play_weapon_animation(id, ANIM_IDLE)
		set_pdata_float(ent, 48, 5.0, 4)
		return HAM_SUPERCEDE
	}
	return HAM_SUPERCEDE
}
public ham_item_postframe(weapon_entity)  {
	if(!is_valid_weapon(weapon_entity)) return
	static id; id = get_pdata_cbase(weapon_entity,41,4)
	static bpammo;bpammo=get_pdata_int(id,376+get_pdata_int(weapon_entity,49,4),5)
	static clip;clip=get_pdata_int(weapon_entity,51,4)
	if(clip==7&&bpammo&&get_pdata_float(weapon_entity, 48, 4)<=0.0&&get_pdata_int(weapon_entity, 55, 4)) Reload(id, weapon_entity)
	if(get_pdata_int(weapon_entity, 54, 4)&&get_pdata_float(id, 83, 5)<=0.0){		
		static bpammo;bpammo=get_pdata_int(id, 376 + get_pdata_int(weapon_entity, 49, 4), 5)
		static clip;clip=get_pdata_int(weapon_entity, 51, 4)
		for(new i=clip; i<CLIP;i++)if(bpammo)bpammo--,clip++	
		set_pdata_int(weapon_entity,54,0,4)
		set_pdata_int(weapon_entity,51,clip,4)
		set_pdata_int(id,376+get_pdata_int(weapon_entity,49,4),bpammo,5)
	}
}
public ham_item_addtoplayer(weapon_entity,id)if(is_valid_weapon(weapon_entity))set_weaponlist(id,1)
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
	register_native("zp_give_item_balrog11", "zp_give_item_balrog11", 1);
public zp_give_item_balrog11(id)
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
	if(pev(iWeapon, pev_solid)!=save)return iWeapon
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
public Reload(id, ent){	
	static bpammo;bpammo=get_pdata_int(id, 376 + get_pdata_int(ent, 49, 4), 5)
	static clip;clip=get_pdata_int(ent, 51, 4)
	switch(get_pdata_int(ent, 55, 4)){
		case 0:{
			play_weapon_animation(id, 6)
			set_pdata_int(ent, 55, 1, 4)	
			set_pdata_float(id, 83, 0.55, 5)
			set_pdata_float(ent, 48, 0.55, 4)
		}
		case 1:{
			if(get_pdata_float(ent, 48, 4)>0.0)return
			if(clip>=CLIP||!bpammo){		
				play_weapon_animation(id, 5)
				set_pdata_int(ent, 55, 0, 4)
				set_pdata_float(ent, 48, 0.9, 4)
				return
			}
			play_weapon_animation(id, 4)
			set_pdata_int(ent, 55, 2, 4)
			set_pdata_float(ent, 48, 0.35, 4)
		}
		case 2:{
			clip++,bpammo--
			set_pdata_int(ent,51,clip,4)
			set_pdata_int(id,376+get_pdata_int(ent,49,4),bpammo,5)
			set_pdata_int(ent, 55, 1, 4)	
		}
	}		
}

public CreateFlame(id)
{	
	static Float:fVec[3], Float:fVec2[3], Float:fVec3[3], Float:fOrigin[3], Float:Angles[3], Float:pVel[3]
	
	static Float:right, Float:dist_add, ent, num
	
	num=5
		
	pev(id, pev_v_angle, Angles)
	pev(id, pev_velocity, pVel)
	
	get_weapon_position(id, fOrigin, .add_forward=10.0, .add_right=3.0, .add_up=-2.5)
	
	dist_add=650.0
	
	right=dist_add/-2.0
	
	for(new i; i<num; i++)
	{
		ent=CreateAnimationSprite(id)
			
		angle_vector(Angles, ANGLEVECTOR_FORWARD, fVec)
		angle_vector(Angles, ANGLEVECTOR_RIGHT, fVec2)
		angle_vector(Angles, ANGLEVECTOR_UP, fVec3)
		
		xs_vec_mul_scalar(fVec, 900.0, fVec)
		xs_vec_mul_scalar(fVec2, right, fVec2)	
		
		fVec[0]=fVec[0]+fVec2[0]+fVec3[0]+pVel[0]
		fVec[1]=fVec[1]+fVec2[1]+fVec3[1]+pVel[1]
		fVec[2]=fVec[2]+fVec2[2]+fVec3[2]+pVel[2]
		
		set_pev(ent, pev_origin, fOrigin)
		set_pev(ent, pev_velocity, fVec)
		
		right+=dist_add/num
	}
}

public CreateAnimationSprite(owner)
{
	new ent=fm_create_entity("info_target")

	set_pev(ent, pev_owner, owner)
	set_pev(ent, pev_classname, "balrog11 flame")
	
	fm_entity_set_model(ent, GrenadeModel)
	fm_set_rendering(ent, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 250)
	
	new Float:angles[3]
	angles[2]=random_float(0.0, 360.0)
	set_pev(ent, pev_angles, angles)

	set_pev(ent, pev_scale, 0.1)

	set_pev(ent, pev_movetype, MOVETYPE_FLY)
	set_pev(ent, pev_solid, SOLID_BBOX)
	
	set_pev(ent, pev_fuser1, 0.0)
	
	entity_set_size(ent, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0})
	
	set_pev(ent, pev_nextthink, get_gametime())
	
	return ent
}

public fwThink(iEnt){
	if(!pev_valid(iEnt)) 
		return
	
	new Float:fFrame, Float:fScale, Float:fNextThink
	pev(iEnt, pev_frame, fFrame)
	pev(iEnt, pev_scale, fScale)
	
	if (fFrame >= 21.0)
	{
		engfunc(EngFunc_RemoveEntity, iEnt)
		return
	}
	
	set_pev(iEnt, pev_renderamt, pev(iEnt, pev_renderamt)-5.0)

	fNextThink = 0.025
	if(fScale>=0.6)
		fScale += 0.085
	else fScale += 0.08
	fScale = floatmin(fScale, 1.6)
	fFrame += 1.0
	
	set_pev(iEnt, pev_fuser1, pev(iEnt, pev_fuser1)+0.1)
	
	new Float:mins[3], Float:maxs[3]
	maxs[0]=maxs[1]=maxs[2]=float(pev(iEnt, pev_fuser1))
	mins[0]=mins[1]=mins[2]=float(pev(iEnt, pev_fuser1)*-1)
	
	engfunc(EngFunc_SetSize, iEnt, mins, maxs)

	set_pev(iEnt, pev_frame, fFrame)
	set_pev(iEnt, pev_scale, fScale)
	set_pev(iEnt, pev_nextthink, get_gametime() + fNextThink)
}

public fwTouch(ent, id)
{
	if(pev(ent, pev_owner)==id) return
		
	new iMoveType = pev(ent, pev_movetype)
	if (iMoveType == MOVETYPE_NONE) return
		
	if(is_user_alive(id)&&zp_core_is_zombie(id)){
		ExecuteHamB(Ham_TakeDamage, id, pev(ent, pev_owner), pev(ent, pev_owner), random_float(350.0, 550.0), DMG_BULLET|DMG_NEVERGIB)
		zp_grenade_fire_set(id)
	}
			
	set_pev(ent, pev_movetype, MOVETYPE_NONE)
}

stock get_weapon_position(id, Float:fOrigin[3], Float:add_forward=0.0, Float:add_right=0.0, Float:add_up=0.0)
{
	static Float:Angles[3],Float:ViewOfs[3], Float:vAngles[3]
	static Float:Forward[3], Float:Right[3], Float:Up[3]
	
	pev(id, pev_v_angle, vAngles)
	pev(id, pev_origin, fOrigin)
	pev(id, pev_view_ofs, ViewOfs)
	xs_vec_add(fOrigin, ViewOfs, fOrigin)
	
	pev(id, pev_v_angle, Angles)
	
	engfunc(EngFunc_MakeVectors, Angles)
	
	global_get(glb_v_forward, Forward)
	global_get(glb_v_right, Right)
	global_get(glb_v_up,  Up)
	
	xs_vec_mul_scalar(Forward, add_forward, Forward)
	xs_vec_mul_scalar(Right, add_right, Right)
	xs_vec_mul_scalar(Up, add_up, Up)
	
	fOrigin[0]=fOrigin[0]+Forward[0]+Right[0]+Up[0]
	fOrigin[1]=fOrigin[1]+Forward[1]+Right[1]+Up[1]
	fOrigin[2]=fOrigin[2]+Forward[2]+Right[2]+Up[2]
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