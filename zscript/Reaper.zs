// ------------------------------------------------------------
// SMG
// ------------------------------------------------------------
const RILD_REAP="RPR";

class RIReaper:HDWeapon{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "REAPR"
		//$Sprite "ASHTA0"

		obituary "%k called a %o harvest.";
		weapon.selectionorder 351;
		weapon.slotnumber 3;
		weapon.kickback 30;
		weapon.bobrangex 0.3;
		weapon.bobrangey 0.8;
		weapon.bobspeed 2.5;
		scale 0.50;
		inventory.pickupmessage "You got the Reaper Automatic Shotgun!";
		hdweapon.barrelsize 29,1,3;
		inventory.icon "ASHTA0";
		hdweapon.refid RILD_REAP;
		tag "Reaper Automatic Shotgun";
	}
//=========================================
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	override double gunmass(){
		return 8+weaponstatus[ASHTS_MAG]*0.2;
	}

	override double weaponbulk(){
		double blx=130;
		int mgg=weaponstatus[ASHTS_MAG];
		if(weaponstatus[ASHTS_BOXER]==1){return blx+(mgg<0?0:(ENC_AST_STK_LOADED+mgg*ENC_SHELLLOADED));
		}else{
		return blx+(mgg<0?0:(ENC_AST_DRM_LOADED+mgg*ENC_SHELLLOADED));
		}
	}
	double shotpower;
	override void loadoutconfigure(string input){
		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>=0)weaponstatus[ASHTS_AUTO]=clamp(firemode,0,2);
		int choke=min(getloadoutvar(input,"choke",1),7);
		if(choke>=0)weaponstatus[ASHTS_CHOKE]=choke;
		int sight=min(getloadoutvar(input,"sight",0),1);
		if(sight>=0)weaponstatus[ASHTS_SIGHTS]=sight;
	}
//===============================================
	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=7.;
		double speedfactor=1.;
		let hhh=RIreaper(caller.findinventory("RIReaper"));
		if(hhh)choke=hhh.weaponstatus[ASHTS_CHOKE];

		choke=clamp(choke,0,7);
		spread=6.5-0.5*choke;
		speedfactor=1.+0.02857*choke;

		double shotpower=frandom(0.9,1.05);
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");
		let p=HDBulletActor.FireBullet(caller,"HDB_00",
			spread:spread,speedfactor:speedfactor,amount:7
		);
		distantnoise.make(p,"world/shotgunfar");
		caller.A_PlaySound("weapons/rprbang",CHAN_WEAPON);
		return shotpower;
	}
	action void A_FireReaper(){
		double shotpower=invoker.Fire(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-1,1)*1.4,-3.4);
		if(invoker.weaponstatus[ASHTS_AUTO]>0)shotrecoil=(randompick(-1,1)*1.4,-3.4);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[ASHTS_CHAMBER]=2;
		invoker.shotpower=shotpower;
	}

	override void failedpickupunload(){
		failedpickupunloadmag(ASHTS_MAG,"RIReapD20");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HDShellAmmo"))owner.A_DropInventory("HDShellAmmo",amt*20);
			else if(weaponstatus[ASHTS_BOXER]==1)owner.A_DropInventory("RIReapM8",amt);
			else owner.A_DropInventory("RIReapD20",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HDShellAmmo");
		owner.A_TakeInventory("RIReapD20");
		owner.A_GiveInventory("RIReapD20");
	}

	override string,double getpickupsprite(){
		string spr;
		int wepstat0=weaponstatus[0];
		spr="ASHT";
		//set to no-mag frame
		if(weaponstatus[ASHTS_BOXER]==1){
			if(weaponstatus[ASHTS_MAG]<0)spr=spr.."B";
				else spr=spr.."E";
			}else{
				if(weaponstatus[ASHTS_MAG]<0)spr=spr.."B";
				else spr=spr.."A";
			}
		return spr.."0",1.;
	}
//================================================
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextdrumloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("RIReapD20")));
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("RIReapM8")));
			
			if(weaponstatus[ASHTS_BOXER]==0){
//	================================
			if(nextdrumloaded>=20){
				sb.drawimage("ASDMB0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextdrumloaded<1){
				sb.drawimage("ASDMA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextdrumloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"ASDMNORM","ASDMGREY",
				nextdrumloaded,20,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("RIReapD20"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
// ++++++++++++++++++++++++++
		if(nextmagloaded>=8){
				sb.drawimage("ASSMB0",(-61,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("ASSMA0",(-61,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"ASSMNORM","ASSMGREY",
				nextmagloaded,20,
				(-61,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("RIReapM8"),-58,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
			
			sb.drawwepcounter(hdw.weaponstatus[ASHTS_AUTO],
				-20,-12,"RBRSA3A7","STFULAUT"
			);
			
		if(hdw.weaponstatus[ASHTS_CHAMBER]==2){
			for(int i=hdw.weaponstatus[ASHTS_MAG]-1;i>0;i--){
			double RIrad=13; //circle radius
			double RIx=(RIrad-0)*cos((18*i)-95);
			double RIy=(RIrad-0)*sin((18*i)-95);
			sb.drawwepdot(-27-(-RIx*1),-18-(-RIy*1),(2,2));
			}
		}else{
			for(int i=hdw.weaponstatus[ASHTS_MAG];i>0;i--){
			double RIrad=13; //circle radius
			double RIx=(RIrad-0)*cos((18*i)-90);
			double RIy=(RIrad-0)*sin((18*i)-90);
			sb.drawwepdot(-27-(-RIx*1),-18-(-RIy*1),(2,2));
			}
		}
		if(hdw.weaponstatus[ASHTS_CHAMBER]==3){
				sb.drawwepdot(-26,-20,(3,5));
				sb.drawwepdot(-26,-17,(3,2));
			}else if(hdw.weaponstatus[ASHTS_CHAMBER]==2){
				sb.drawwepdot(-26,-20,(3,2));
				sb.drawwepdot(-26,-17,(3,2));
			}else if(hdw.weaponstatus[ASHTS_CHAMBER]==1)
				{sb.drawwepdot(-26,-17,(3,2));}

//	================================
		}else{
//	================================
		if(nextmagloaded>=8){
				sb.drawimage("ASSMB0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("ASSMA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"ASSMNORM","ASSMGREY",
				nextmagloaded,20,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("RIReapM8"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
//	+++++++++++++++++++++++++++++++++++++
			if(nextdrumloaded>=20){
				sb.drawimage("ASDMB0",(-61,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextdrumloaded<1){
				sb.drawimage("ASDMA0",(-61,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextdrumloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"ASDMNORM","ASDMGREY",
				nextdrumloaded,20,
				(-61,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("RIReapD20"),-58,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);

			sb.drawwepcounter(hdw.weaponstatus[ASHTS_AUTO],
				-24,-12,"RBRSA3A7","STFULAUT"
			);
			//straight
		if(hdw.weaponstatus[ASHTS_CHAMBER]==2){
			for(int i=hdw.weaponstatus[ASHTS_MAG];i>0;i--){
			double RIrad=37; //circle radius
			double RIx=(RIrad-0)*cos((3*i)-0);
			double RIy=(3*i)-90;
			sb.drawwepdot(-51-(-RIx*1),63-(-RIy*1),(2,2));
			sb.drawwepdot(-54-(-RIx*1),63-(-RIy*1),(4,2));
			}
		}else{
			for(int i=hdw.weaponstatus[ASHTS_MAG];i>0;i--){
			double RIrad=37; //circle radius
			double RIx=(RIrad-0)*cos((3*i)-0);
			double RIy=(3*i)-90;
			sb.drawwepdot(-51-(-RIx*1),64-(-RIy*1),(2,2));
			sb.drawwepdot(-54-(-RIx*1),64-(-RIy*1),(4,2));
			}
		}

//	=====================================
			if(hdw.weaponstatus[ASHTS_CHAMBER]==3){
				sb.drawwepdot(-30,-20,(3,5));
				sb.drawwepdot(-30,-17,(3,2));
			}else if(hdw.weaponstatus[ASHTS_CHAMBER]==2){
				sb.drawwepdot(-30,-20,(3,2));
				sb.drawwepdot(-30,-17,(3,2));
			}else if(hdw.weaponstatus[ASHTS_CHAMBER]==1)
				{sb.drawwepdot(-30,-17,(3,2));}
			}
		}
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Cycle Bolt\n"
		..WEPHELP_RELOAD.."  Reload/Cycle bolt (Hold "..WEPHELP_FIREMODE.." to swap magazine types\)\n"
		..WEPHELP_FIREMODE.."Semi / Annhilate\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc,string whichdot
	){
		if(weaponstatus[ASHTS_SIGHTS]==0){
			int cx,cy,cw,ch;
			[cx,cy,cw,ch]=screen.GetClipRect();
			sb.SetClipRect(
				-16+bob.x,-4+bob.y,32,16,
				sb.DI_SCREEN_CENTER
			);
			vector2 bobb=bob*3;
			bobb.y=clamp(bobb.y,-8,8);
				sb.drawimage(
				"RPRFRNT",(0,-11)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
				alpha:0.9
			);
				sb.SetClipRect(cx,cy,cw,ch);
				sb.drawimage(
				"TmpSBCK",(0,-11)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
			);
		}else{
			int cx,cy,cw,ch;
			[cx,cy,cw,ch]=screen.GetClipRect();
			sb.SetClipRect(
				-16+bob.x,-4+bob.y,32,16,
				sb.DI_SCREEN_CENTER
			);
			vector2 bobb=bob*3;
			bobb.y=clamp(bobb.y,-8,8);
				sb.drawimage(
				"RPRFGRN",(0,-11)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
				alpha:0.9
			);
				sb.SetClipRect(cx,cy,cw,ch);
				sb.drawimage(
				"RPRSBCK",(0,-11)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
			);
		}
	}
	
	action void A_ReaperSpriteSelect(){
	    let psp = player.FindPSprite (PSP_Weapon);
        if (!psp)
               return;
        
		int ast=invoker.weaponstatus[ASHTS_MAG];
		if(ast>=19)psp.frame=9;
		else if(ast>=18)psp.frame=8;
		else if(ast>=17)psp.frame=7;
		else if(ast>=16)psp.frame=6;
		else if(ast>=6)psp.frame=5;
		else if(ast>=5)psp.frame=4;
		else if(ast>=4)psp.frame=3;
		else if(ast>=3)psp.frame=2;
		else if(ast>=0)psp.frame=1;
		else psp.frame=0;
		if(invoker.weaponstatus[ASHTS_BOXER]==1)psp.frame=0;
	}
	states{
	select0:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		goto select0big;
	deselect0:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		goto deselect0big;

//grenade selects
	select0rigren:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		goto select0big;
	deselect0rigren:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		goto deselect0big;
	ready:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1{
			A_SetCrosshair(21);
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
	user3:
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_BOXER]==1,"boxmagman");				
		#### # 0 A_MagManager("RIReapD20");
		goto ready;
	boxmagman:	
		#### # 0 A_MagManager("RIReapM8");
		goto ready;
	hold:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			if(
				//full auto
				invoker.weaponstatus[ASHTS_AUTO]==2
			)setweaponstate("fire2");
			else if(
				//burst
				invoker.weaponstatus[ASHTS_AUTO]<1
			)setweaponstate("nope");
		}goto fire;
	user2:
	firemode:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 3;
		#### # 0 { if(PressingReload())setweaponstate("reloadselect");
					}
		#### # 1{
			int aut=invoker.weaponstatus[ASHTS_AUTO];
			if(aut>=0){
				invoker.weaponstatus[ASHTS_AUTO]=aut==0?1:0;
			}
		}goto nope;
	hold:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			if(
				//full auto
				invoker.weaponstatus[ASHTS_AUTO]==2
			)setweaponstate("fire2");
			else if(
				//burst
				invoker.weaponstatus[ASHTS_AUTO]<1
			)setweaponstate("nope");
		}goto fire;
	fire:
	fire2:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 3;
		#### # 1{
			if(invoker.weaponstatus[ASHTS_CHAMBER]==3){
				A_FireReaper();
			}else{setweaponstate("nope");}
		}
		#### # 1 offset(0,40);
		#### # 0 {invoker.weaponstatus[ASHTS_CHAMBER]=1;}
		#### # 0{if(invoker.shotpower>0.901&&invoker.weaponstatus[ASHTS_BOXER]>0)setweaponstate("rechamber");
			}
		#### # 0{if(invoker.shotpower>0.903)setweaponstate("rechamber");
			}
		#### # 0 A_PlaySound("weapons/riflejam",CHAN_WEAPON);
		goto ready;
	rechamber:
		#### # 0{
			if(invoker.weaponstatus[ASHTS_CHAMBER]==1&&invoker.shotpower>0.901){ //hunter shotpower used as refrence here, and i'm keeping this redundant check just for this
				vector3 cockdir;
				cockdir*=frandom(-500.5,700.8);
				A_SpawnItemEx("RISpentShell",
					cos(pitch)*8,frandom(0.0,0.5),height-10-sin(pitch)*8,
				vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
				invoker.weaponstatus[ASHTS_CHAMBER]=0;
				if(invoker.weaponstatus[ASHTS_MAG]>0){
					invoker.weaponstatus[ASHTS_MAG]--;
					invoker.weaponstatus[ASHTS_CHAMBER]=3;
				}
			}
			if(invoker.weaponstatus[ASHTS_AUTO]==2)A_SetTics(1);
			A_WeaponReady(WRF_NOFIRE);
		}
		#### # 0 A_ReFire();
		goto ready;

	flash:
		ASTF JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1{
			A_Light2();
			HDFlashAlpha(-32);
		}
		TNT1 A 1 A_ZoomRecoil(0.9);
		TNT1 A 0 A_Light0();
		TNT1 A 0 A_AlertMonsters();

		goto lightdone;

//==========================================
// CHANGE THESE AT SOMEPOINT. I DON'T EVEN REMEMBER IF LOAD CHAMBER IS STILL USED
//======================================

	unloadchamber:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 A_JumpIf(invoker.weaponstatus[ASHTS_CHAMBER]<1,"nope");
		#### # 10{
			class<actor>which=invoker.weaponstatus[ASHTS_CHAMBER]>1?"HDShellAmmo":"RISpentShell";
			invoker.weaponstatus[ASHTS_CHAMBER]=0;
			A_SpawnItemEx(which,
				cos(pitch)*10,0,height-8-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}goto readyend;
	loadchamber:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_CHAMBER]>0,"nope");
		#### # 0 A_JumpIf(!countinv("HDShellAmmo"),"nope");
		#### # 1 offset(0,34) A_PlaySound("weapons/pocket",CHAN_WEAPON);
		#### # 1 offset(2,36);
		#### # 1 offset(5,40);
		#### # 4 offset(4,39){
			if(countinv("HDShellAmmo")){
				A_TakeInventory("HDShellAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[ASHTS_CHAMBER]=3;
				A_PlaySound("weapons/smgchamber",CHAN_WEAPON);
			}
		}
		#### # 7 offset(5,37);
		#### # 1 offset(2,36);
		#### # 1 offset(0,34);
		goto readyend;
	user4:
//======================================
//		MAGGING
//======================================
	
	unload:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_JUSTUNLOAD;
			if(invoker.weaponstatus[ASHTS_MAG]>=0){
				if(invoker.weaponstatus[ASHTS_BOXER]>0){
				setweaponstate("boxout");
				}else{
				setweaponstate("unmag");
				}
			}else if(invoker.weaponstatus[ASHTS_CHAMBER]>0)setweaponstate("prechamber");
		}goto nope;
	altfire:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_WeaponBusy();
		#### # 0 {	if(invoker.weaponstatus[ASHTS_CHAMBER]<3&&invoker.weaponstatus[ASHTS_MAG]>0)setweaponstate("prechamber");
}
		#### # 0 {
			invoker.weaponstatus[0]&=~ASHTF_JUSTUNLOAD;
if(invoker.weaponstatus[ASHTS_MAG]>=20&&invoker.weaponstatus[ASHTS_CHAMBER]==3)setweaponstate("nope");
			else if(HDMagAmmo.NothingLoaded(self,"RIReapD20")||HDMagAmmo.NothingLoaded(self,"RIReapM8")){
				if(
					invoker.weaponstatus[ASHTS_MAG]<0
					&&countinv("HDShellAmmo")
				)setweaponstate("loadchamber");
				else setweaponstate("nope");
			}
		}
	althold:
		---- A 1;
		---- A 0 A_Refire();
		goto ready;
	reload:
//		#### # 0 A_Log("reload shart",true);
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 {	if(invoker.weaponstatus[ASHTS_CHAMBER]<3&&invoker.weaponstatus[ASHTS_MAG]>0)setweaponstate("prechamber");
}
		#### # 3;
		#### # 0 { if(PressingFiremode())setweaponstate("reloadselect");
					}
		#### # 0 {
			invoker.weaponstatus[0]&=~ASHTF_JUSTUNLOAD;
			if(invoker.weaponstatus[ASHTS_BOXER]>0){	
				if(invoker.weaponstatus[ASHTS_MAG]>=8)setweaponstate("nope");
			}else{
				if(invoker.weaponstatus[ASHTS_MAG]>=20)setweaponstate("nope");
			}
			if(HDMagAmmo.NothingLoaded(self,"RIReapD20")){
					if(HDMagAmmo.NothingLoaded(self,"RIReapM8")){
						setweaponstate("nope");
//						A_Log("auto d70 m30 fail",true);
					}else{
						invoker.weaponstatus[ASHTS_BOXEE]=1;
						setweaponstate("reloadselect");
//						A_Log("d70 m30 autoswap",true);
					}
				}else if(HDMagAmmo.NothingLoaded(self,"RIReapM8")){
					if(HDMagAmmo.NothingLoaded(self,"RIReapD20")){
						setweaponstate("nope");
//						A_Log("auto m30 d70 fail",true);
					}else{
						invoker.weaponstatus[ASHTS_BOXEE]=2;
						setweaponstate("reloadselect");
//						A_Log("m30 d70 autoswap",true);
					}
				}
		}goto reloadselect;
	reloadselect:
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_BOXER]==1,"boxout");
		goto unmag;
	unmag:
//		#### # 0 A_Log("Unmag",true);
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(0,24) A_SetCrosshair(21);
		#### # 2 offset(2,28);
		ASTB JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 3 offset(4,32) A_PlaySound("weapons/rprdrmot",CHAN_WEAPON);
		ASTC JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 5 offset(6,36);
		ASTD JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 5 offset(8,42){
			A_MuzzleClimb(0.3,0.4);
		}
		ASTE JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 5 offset(8,42);
		ASTZ A 0 offset(8,42) A_PlaySound("weapons/smgmagmove",CHAN_WEAPON);
		#### # 5 offset(8,42);
		#### # 0{
			int magamt=invoker.weaponstatus[ASHTS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[ASHTS_MAG]=-1;
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("RIReapD20",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"RIReapD20",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"RIReapD20",magamt);
				A_PlaySound("weapons/pocket",CHAN_WEAPON);
				setweaponstate("pocketmag");
			}
		}
	boxout:
//		#### # 0 A_Log("Unbox",true);
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(0,24) A_SetCrosshair(21);
		#### # 2 offset(2,28);
		ASTB JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 3 offset(4,32) A_PlaySound("weapons/rprdrmot",CHAN_WEAPON);
		ASTC JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(6,36);
		ASTD JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(8,42){
			A_MuzzleClimb(0.3,0.4);
		}
		ASTE JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(8,42);
		ASTZ A 0 offset(8,42) A_PlaySound("weapons/smgmagmove",CHAN_WEAPON);
		#### # 4 offset(8,42);

		#### # 0{
			int magamt=invoker.weaponstatus[ASHTS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[ASHTS_MAG]=-1;
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("RIReapM8",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"RIReapM8",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"RIReapM8",magamt);
				A_PlaySound("weapons/pocket",CHAN_WEAPON);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		ASTZ A 2 offset(8,42);
		#### # 7 offset(8,42) A_PlaySound("weapons/pocket",CHAN_WEAPON);
		#### # 7 offset(8,42) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
//		#### # 0 {
//				if(invoker.weaponstatus[ASHTS_BOXER]==1){
//					setweaponstate("magout");
//					}
//				}
		#### # 7 offset(8,42) A_PlaySound("weapons/pocket",CHAN_WEAPON);
		#### # 7 offset(8,42) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
	magout:
		#### # 0{
			if(invoker.weaponstatus[ASHTS_BOXEE]==2){
				invoker.weaponstatus[ASHTS_BOXER]=0;
				setweaponstate("rimagloader");
			}else if(invoker.weaponstatus[ASHTS_BOXEE]==1){
				invoker.weaponstatus[ASHTS_BOXER]=1;
				setweaponstate("rimagloader");
			}
		}
		#### # 0{
				if(PressingFiremode()&&invoker.weaponstatus[ASHTS_BOXER]<1){invoker.weaponstatus[ASHTS_BOXER]=1;
					}else if(PressingFiremode()&&invoker.weaponstatus[ASHTS_BOXER]>0){invoker.weaponstatus[ASHTS_BOXER]=0;
				}
		}
	rimagloader:
		#### # 0{
			if(invoker.weaponstatus[0]&ASHTF_JUSTUNLOAD)setweaponstate("reloadend");
			else if(invoker.weaponstatus[ASHTS_BOXER]==1)setweaponstate("loadboxmag");
			else setweaponstate("loadmag");
		}

	loadmag:
//		#### # 0 A_Log("Loadmag",true);
		#### # 0 A_PlaySound("weapons/pocket",CHAN_WEAPON);
		ASTZ A 10 offset(8,42);
		#### # 0{
			invoker.weaponstatus[ASHTS_BOXER]=0;
			invoker.weaponstatus[ASHTS_BOXEE]=0;
			let mmm=hdmagammo(findinventory("RIReapD20"));
			if(mmm){
				invoker.weaponstatus[ASHTS_MAG]=mmm.TakeMag(true);
				A_PlaySound("weapons/smgmagclick",CHAN_BODY);
			}
		}
		ASTE JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 6 offset(8,42) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		ASTD JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 6 offset(8,42) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 0 A_PlaySound("weapons/rprdrmin",CHAN_BODY);
		ASTC JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 6 offset(6,36);
		goto reloadend;
		
	loadboxmag:
//		#### # 0 A_Log("Loadbox",true);
		#### # 0 A_PlaySound("weapons/pocket",CHAN_WEAPON);
		ASTZ A 5 offset(8,42);
		#### # 0{
			invoker.weaponstatus[ASHTS_BOXER]=1;
			invoker.weaponstatus[ASHTS_BOXEE]=0;
			let mmm=hdmagammo(findinventory("RIReapM8"));
			if(mmm){
				invoker.weaponstatus[ASHTS_MAG]=mmm.TakeMag(true);
				A_PlaySound("weapons/smgmagclick",CHAN_BODY);
			}
		}
		ASTE JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(8,42) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		ASTD JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(8,42) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 0 A_PlaySound("weapons/rprdrmin",CHAN_BODY);
		ASTC JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(6,36);
		goto reloadend;
//====================================================
// CHAMBER ANIMS
//====================================================

	prechamber:
//		#### # 0 A_Log("prech",true);
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 3 offset(4,24);
		#### # 4 offset(4,28);
		ASTB JIHGFEDCBA 0 A_ReaperSpriteSelect();		
		#### # 4 offset(4,32);
		#### # 0 offset(4,32){ if(invoker.weaponstatus[0]&ASHTF_JUSTUNLOAD)setweaponstate("unloaderchamber");}
		goto chamber;
	chamber:
//		#### # 0 A_Log("chambar",true);
		ASTG JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(6,36);
		ASTH JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 3 offset(6,36) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 0 A_PlaySound("weapons/rprbolt",CHAN_WEAPON);
		#### # 2 offset(8,36);
		ASTI JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(10,36){if(!invoker.weaponstatus[ASHTS_CHAMBER]==0)invoker.weaponstatus[ASHTS_CHAMBER]=2;}
		#### # 2 offset(10,36) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 0 offset(10,36){
	class<actor>which=invoker.weaponstatus[ASHTS_CHAMBER]>2?"HDShellAmmo":"RISpentShell";
			if(invoker.weaponstatus[ASHTS_CHAMBER]>=2){
			A_SpawnItemEx(which,
				cos(pitch)*10,0,height-8-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
			invoker.weaponstatus[ASHTS_MAG]--;
			invoker.weaponstatus[ASHTS_CHAMBER]=3;
			}else if(invoker.weaponstatus[ASHTS_CHAMBER]==0){
			invoker.weaponstatus[ASHTS_MAG]--;
			invoker.weaponstatus[ASHTS_CHAMBER]=3;
			}
		}
		ASTG JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(8,36);
		ASTH JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(6,36);
		goto reloadendend;
	unloaderchamber:
//		#### # 0 A_Log("cha77777mbar",true);
		ASTG JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(6,36);
		ASTH JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 3 offset(6,36) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 0 A_PlaySound("weapons/rprbolt",CHAN_WEAPON);
		#### # 2 offset(8,36);
		ASTI JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(10,36);
		#### # 2 offset(10,36) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 0 offset(10,36){
			if(invoker.weaponstatus[ASHTS_CHAMBER]==3){
			invoker.weaponstatus[ASHTS_CHAMBER]=0;
			A_SpawnItemEx("HDShellAmmo",
				cos(pitch)*10,0,height-8-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
			}else if(invoker.weaponstatus[ASHTS_CHAMBER]>0){
			invoker.weaponstatus[ASHTS_CHAMBER]=0;
			A_SpawnItemEx("RISpentShell",
				cos(pitch)*10,0,height-8-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
			}
		}
		ASTG JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(8,36);
		ASTH JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(6,36);
		goto reloadendend;
	reloadend:
//		#### # 0 A_Log("reload end",true);
		ASTC JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 3 offset(6,36);
		ASTB JIHGFEDCBA 0 A_ReaperSpriteSelect();		
		#### # 3 offset(6,36){if(invoker.weaponstatus[ASHTS_CHAMBER]<3&&invoker.weaponstatus[ASHTS_MAG]>0)
			setweaponstate("chamber");
			}
	reloadendend:
		ASTB JIHGFEDCBA 0 A_ReaperSpriteSelect();//just updating the file for slade	
		#### # 3 offset(4,32) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 3 offset(2,28);
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();		
		#### # 3 offset(0,24);
		goto nope;
//===========================================
// ATTACHEMENT CODE
//===========================================

//=============================================
// 
//=============================================

	spawn:
		ASHT A -1 nodelay{
			if(invoker.weaponstatus[ASHTS_MAG]<0)frame=1;
			if(invoker.weaponstatus[ASHTS_BOXER]==1&&invoker.weaponstatus[ASHTS_MAG]>=0)frame=4;
		}
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[ASHTS_MAG]=20;
		weaponstatus[ASHTS_CHAMBER]=3;
//		weaponstatus[ASHTS_BOXER]=0;
		if(!idfa)weaponstatus[ASHTS_AUTO]=0;
	}
}
enum RPRstatus{
	ASHTF_JUSTUNLOAD=1,
	ASHTF_GLMODE=2,
	ASHTF_GZCHAMBER=4,
	ASHTF_CHAMBERBROKEN=8,
	ASHTF_DIRTYMAG=16,
	ASHTF_STILLPRESSINGRELOAD=32,
	ASHTF_LOADINGDIRTY=64,

	ASHTS_FLAGS=0,
	ASHTS_MAG=1, //-1 unmagged
	ASHTS_CHAMBER=2, //0 empty, 1 spent, 2 animate, 3 loaded
	ASHTS_AUTO=3, //0 semi, 1 burst, 2 auto
	ASHTS_CHOKE=4,
	ASHTS_HEAT=5,
	ASHTS_ZMAG=6,
	ASHTS_ZAUTO=7,
	ASHTS_BOXER=8,
	ASHTS_BOXEE=9,
	ASHTS_SIGHTS=10,
};
