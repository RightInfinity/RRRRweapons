// ------------------------------------------------------------
// SMG
// ------------------------------------------------------------
const RILD_REAPGL="RPG";

class RIReaperGL:RIReaper{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "REAPRGL"
		//$Sprite "ASHGA0"

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
		inventory.icon "ASHGA0";
		hdweapon.refid RILD_REAPGL;
		tag "Reaper Automatic Shotgun W/ Grenade Launcher";
	}
//=========================================
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	override double gunmass(){
	return 9+weaponstatus[ASHTS_MAG]*0.3+(weaponstatus[0]&ASHTF_GZCHAMBER?1.:0.);
	}

	override double weaponbulk(){
		double blx=155;
		if(weaponstatus[0]&ASHTF_GZCHAMBER)blx+=ENC_ROCKETLOADED;
		int mgg=weaponstatus[ASHTS_MAG];
		return blx+(mgg<0?0:(ENC_AST_DRM_LOADED+mgg*ENC_SHELLLOADED));
	}

//===============================================
	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=7.;
		double speedfactor=1.;
		let hhh=RIreaperGL(caller.findinventory("RIReaperGL"));
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
		caller.A_StartSound("weapons/rprbang",CHAN_WEAPON);
		return shotpower;
	}
	action void A_FireReaper(){
		double shotpower=invoker.Fire(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-1,1)*1.4,-3.4);
		if(invoker.weaponstatus[ASHTS_AUTO]>0)shotrecoil=(randompick(-1,1)*1.4,-3.4);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[ASHTS_CHAMBER]=3;
		invoker.shotpower=shotpower;
	}

	override void failedpickupunload(){
		failedpickupunloadmag(ASHTS_MAG,"RIReapD20");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HDShellAmmo"))owner.A_DropInventory("HDShellAmmo",amt*20);
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
		spr="ASHG";
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
	}
	}
// ===============================================================
			if(hdw.weaponstatus[ASHTS_CHAMBER]==3){
				sb.drawwepdot(-30,-20,(3,5));
				sb.drawwepdot(-30,-17,(3,2));
			}else if(hdw.weaponstatus[ASHTS_CHAMBER]==2){
				sb.drawwepdot(-30,-20,(3,2));
				sb.drawwepdot(-30,-17,(3,2));
			}else if(hdw.weaponstatus[ASHTS_CHAMBER]==1)
				{sb.drawwepdot(-30,-17,(3,2));}
		//WHAT
		if(hdw.weaponstatus[0]&ASHTF_GZCHAMBER){
			sb.drawwepdot(-23,-17,(3,1.5));
			sb.drawwepdot(-24,-17,(1,8));
			sb.drawwepdot(-23,-20,(3,4));
		}
		sb.drawimage("ROQPA0",(-73,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.6,0.6));
			sb.drawnum(hpl.countinv("HDRocketAmmo"),-73,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Swap to Grenade Launcher\n"
		..WEPHELP_ALTRELOAD.."  Reload Grenade Launcher\n"
		..WEPHELP_RELOAD.."  Reload/Cycle bolt (Hold "..WEPHELP_FIREMODE.." to swap magazine types\)\n"
		..WEPHELP_FIREMODE.."  Destroy/Annihilate\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc,string whichdot
	){
	if(hdw.weaponstatus[0]&ASHTF_GLMODE)sb.drawgrenadeladder(hdw.airburst,bob);
		else if(weaponstatus[ASHTS_SIGHTS]==0){
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

	states{
	select0:
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GLMODE,"select0rigren");
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		goto select0big;
	deselect0:
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GLMODE,"deselect0rigren");
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		goto deselect0big;
	select0rigren:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		goto select0big;
	deselect0rigren:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		goto deselect0big;
	ready:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GLMODE, 2);
		#### # 1{
			A_SetCrosshair(21);
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1{
			A_SetCrosshair(21);
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;

	user2:
	firemode:
		#### # 0 A_JumpIf(invoker.weaponstatus[0]&ASHTF_GLMODE,"abadjust");
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
	fire:
		#### JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			if(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GLMODE)setweaponstate("firefrag");
		}goto fire2;
	user4:
	unload:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_JUSTUNLOAD;
			if(invoker.weaponstatus[0]&ASHTF_GLMODE){setweaponstate("unloadgrenade");
			}else if(invoker.weaponstatus[ASHTS_MAG]>=0){
				if(invoker.weaponstatus[ASHTS_BOXER]>0){
				setweaponstate("boxout");
				}else{
				setweaponstate("unmag");
				}
			}else if(invoker.weaponstatus[ASHTS_CHAMBER]>0){setweaponstate("prechamber");}
		}goto nope;
//===========================================
// THANKS CHIIINNAAAAAAA
//===========================================
	nadeflash:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();		
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER,1);
		stop; // this does nothing (?now?) but I'll keep it here anyway~
		#### # 2 offset(0,15){
			A_FireHDGL();
			invoker.weaponstatus[ASHTS_FLAGS]&=~ASHTF_GZCHAMBER;
			A_StartSound("weapons/grenadeshot",CHAN_WEAPON);
			A_ZoomRecoil(0.95);
		}
		#### # 2 A_MuzzleClimb(
			0,0,0,0,
			-1.2,-3.,
			-1.,-2.8
		);
		stop;
	firefrag:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER,1);
		goto nope; //Note to tell Matt that the ZM's GL causes a flash even when unloaded
		#### # 2;
		#### # 1 A_Gunflash("nadeflash");
		#### # 2 offset(0,15);
		goto nope;


	altfire:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(6,0){
			invoker.weaponstatus[0]^=ASHTF_GLMODE;
			invoker.airburst=0;
			A_SetCrosshair(21);
			A_SetHelpText();
		}goto nope;
	
	althold:
		---- A 1;
		---- A 0 A_Refire();
		goto ready;

	altreload:
		#### # 0{
			invoker.weaponstatus[ASHTS_FLAGS]&=~ASHTF_JUSTUNLOAD;
			if(!(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER)
				&&countinv("HDRocketAmmo")
			)setweaponstate("unloadgrenade");
		}goto nope;
	unloadgrenade:
	//unload is also reload. Genius
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			A_SetCrosshair(21);
			A_MuzzleClimb(-0.3,-0.3);
		}
		ASTJ JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(0,34);
		#### # 1 offset(4,38){
			A_MuzzleClimb(-0.3,-0.3);
		}
		#### # 2 offset(8,48){
			A_StartSound("weapons/grenopen",5);
			A_MuzzleClimb(-0.3,-0.3);
			if(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER)A_StartSound("weapons/grenreload",CHAN_WEAPON);
		}
		ASTK JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 10 offset(10,49){
			if(!(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER)){
				if(!(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_JUSTUNLOAD))A_SetTics(3);
				return;
			}
			invoker.weaponstatus[ASHTS_FLAGS]&=~ASHTF_GZCHAMBER;
			if(
				!PressingUnload()
				||A_JumpIfInventory("HDRocketAmmo",0,"null")
			){
				A_SpawnItemEx("HDRocketAmmo",
					cos(pitch)*10,0,height-10-10*sin(pitch),vel.x,vel.y,vel.z,0,
					SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}else{
				A_StartSound("weapons/pocket",5);
				A_GiveInventory("HDRocketAmmo",1);
				A_MuzzleClimb(frandom(0.8,-0.2),frandom(0.4,-0.2));
			}
		}
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_JUSTUNLOAD,"greloadend");
	loadgrenade:
		#### # 4 offset(10,50) A_StartSound("weapons/pocket",CHAN_WEAPON);
		#### # 8 offset(10,50) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### # 8 offset(10,50) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### # 8 offset(10,50) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### # 18 offset(8,50){
			A_TakeInventory("HDRocketAmmo",1,TIF_NOTAKEINFINITE);
			invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_GZCHAMBER;
			A_StartSound("weapons/grenreload",CHAN_WEAPON);
		}
	greloadend:
		ASTJ JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(4,44) A_StartSound("weapons/grenopen",CHAN_WEAPON);
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(0,40);
		#### # 1 offset(0,34) A_MuzzleClimb(frandom(-2.4,0.2),frandom(-1.4,0.2));
		goto nope;

//=============================================
// 
//=============================================

	spawn:
		ASHG A -1 nodelay{
			if(invoker.weaponstatus[ASHTS_MAG]<0)frame=1;
			if(invoker.weaponstatus[ASHTS_BOXER]==1&&invoker.weaponstatus[ASHTS_MAG]>=0)frame=4;
		}
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[ASHTS_FLAGS]|=ASHTF_GZCHAMBER;
		weaponstatus[ASHTS_MAG]=20;
		weaponstatus[ASHTS_CHAMBER]=3;
		weaponstatus[ASHTS_BOXER]=0;
		weaponstatus[ASHTS_BOXEE]=0;
		if(!idfa)weaponstatus[ASHTS_AUTO]=0;
	}
}
	
//		ASHTF_JUSTUNLOAD 1
//	ASHTF_GLMODE=2,
//	ASHTF_ZCHAMBER=4,
//	ASHTF_CHAMBERBROKEN=8,
//	ASHTF_DIRTYMAG=16,
//	ASHTF_STILLPRESSINGRELOAD=32,
//	ASHTF_LOADINGDIRTY=64,

//		ASHTS_FLAGS 0
//		ASHTS_MAG 1 //-1 unmagged
//		ASHTS_CHAMBER 2 //0 empty, 1 spent, 2 animate, 3 loaded
//		ASHTS_AUTO 3 //0 semi, 1 burst, 2 auto
//		ASHTS_CHOKE 4
//	ASHTS_HEAT=5
//	ASHTS_ZMAG=6
//	ASHTS_ZAUTO=7
//	ASHTS_BOXER=8
//	ASHTS_BOXEE=9
//	ASHTS_SIGHTS=10

