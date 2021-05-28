// ------------------------------------------------------------
// SMG
// ------------------------------------------------------------
const RILD_REAPZM="RPZ";
const RILD_RPRZMCOOKOFF=21;

class RIReaperZM:RIReaper{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "REAPRGL"
		//$Sprite "ASHTR0"

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
		inventory.icon "ASHRE0";
		hdweapon.refid RILD_REAPZM;
		tag "Reaper Automatic Shotgun W/ Underbarrel Carbine";
	}
	override void tick(){
		super.tick();
		drainheat(ASHTS_HEAT,12);
	}
//=========================================
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	override double gunmass(){
	return 9+(weaponstatus[ASHTS_MAG]*0.2)+(weaponstatus[ASHTS_ZMAG]*0.02);
	}

	override double weaponbulk(){
		double blx=155;
		int mgg=weaponstatus[ASHTS_MAG];
		int mgz=weaponstatus[ASHTS_ZMAG];
		return blx+(mgg<0?0:(ENC_AST_DRM_LOADED+mgg*ENC_SHELLLOADED))+(mgz<0?0:(mgz*ENC_426_LOADED));
	}

//===============================================
	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=7.;
		double speedfactor=1.;
		let hhh=RIreaperZM(caller.findinventory("RIReaperZM"));
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
	action bool brokenround(){
		if(!(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_CHAMBERBROKEN)){
			int rnd=
				(invoker.owner?1:10)
				+(invoker.weaponstatus[ASHTS_ZAUTO])
				+(invoker.weaponstatus[ASHTS_ZMAG]>100?10:0);
			if(random(0,2000)<rnd){
				invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_CHAMBERBROKEN;
			}
		}return invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_CHAMBERBROKEN;
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
		spr="ASHR";
		//set to no-mag frame
		if(weaponstatus[ASHTS_BOXER]==0&&weaponstatus[ASHTS_MAG]>-1&&weaponstatus[ASHTS_ZMAG]>-1)spr=spr.."A";
		if(weaponstatus[ASHTS_BOXER]==0&&weaponstatus[ASHTS_MAG]<0&&weaponstatus[ASHTS_ZMAG]>-1)spr=spr.."B";
		if(weaponstatus[ASHTS_BOXER]==1&&weaponstatus[ASHTS_MAG]>-1&&weaponstatus[ASHTS_ZMAG]>-1)spr=spr.."E";
		if(weaponstatus[ASHTS_BOXER]==0&&weaponstatus[ASHTS_MAG]>-1&&weaponstatus[ASHTS_ZMAG]<0)spr=spr.."C";
		if(weaponstatus[ASHTS_BOXER]==0&&weaponstatus[ASHTS_MAG]<0&&weaponstatus[ASHTS_ZMAG]<0)spr=spr.."D";
		if(weaponstatus[ASHTS_BOXER]==1&&weaponstatus[ASHTS_MAG]>-1&&weaponstatus[ASHTS_ZMAG]<0)spr=spr.."F";

		return spr.."0",1.;
	}
//================================================
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel == 1){
			int nextdrumloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("RIReapD20")));
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("RIReapM8")));
			
			if(weaponstatus[ASHTS_BOXER]==0){
// ----------------------------------

//	================================
			if(nextdrumloaded>=20){
				sb.drawimage("ASDMB0",(-51,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextdrumloaded<1){
				sb.drawimage("ASDMA0",(-51,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextdrumloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"ASDMNORM","ASDMGREY",
				nextdrumloaded,20,
				(-51,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("RIReapD20"),-48,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
// ++++++++++++++++++++++++++
		if(nextmagloaded>=8){
				sb.drawimage("ASSMB0",(-79,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("ASSMA0",(-79,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"ASSMNORM","ASSMGREY",
				nextmagloaded,20,
				(-79,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("RIReapM8"),-77,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
			
			sb.drawwepcounter(hdw.weaponstatus[ASHTS_AUTO],
				-19,-17,"RBRSA3A7","STFULAUT"
			);
			
		if(hdw.weaponstatus[ASHTS_CHAMBER]==2){
			for(int i=hdw.weaponstatus[ASHTS_MAG]-1;i>0;i--){
			double RIrad=13; //circle radius
			double RIx=(RIrad-0)*cos((18*i)-95);
			double RIy=(RIrad-0)*sin((18*i)-95);
			sb.drawwepdot(-27-(-RIx*1),-23-(-RIy*1),(2,2));
			}
		}else{
			for(int i=hdw.weaponstatus[ASHTS_MAG];i>0;i--){
			double RIrad=13; //circle radius
			double RIx=(RIrad-0)*cos((18*i)-90);
			double RIy=(RIrad-0)*sin((18*i)-90);
			sb.drawwepdot(-27-(-RIx*1),-23-(-RIy*1),(2,2));
			}
		}

//	================================
		}else{
//	================================

//---------------------------------------
		if(nextmagloaded>=8){
				sb.drawimage("ASSMB0",(-51,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("ASSMA0",(-51,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"ASSMNORM","ASSMGREY",
				nextmagloaded,20,
				(-51,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("RIReapM8"),-49,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
//	+++++++++++++++++++++++++++++++++++++
			if(nextdrumloaded>=20){
				sb.drawimage("ASDMB0",(-79,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextdrumloaded<1){
				sb.drawimage("ASDMA0",(-79,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextdrumloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"ASDMNORM","ASDMGREY",
				nextdrumloaded,20,
				(-79,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("RIReapD20"),-77,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);

			sb.drawwepcounter(hdw.weaponstatus[ASHTS_AUTO],
				-23,-17,"RBRSA3A7","STFULAUT"
			);
			//straight
		if(hdw.weaponstatus[ASHTS_CHAMBER]==2){
			for(int i=hdw.weaponstatus[ASHTS_MAG];i>0;i--){
			double RIrad=37; //circle radius
			double RIx=(RIrad-0)*cos((3*i)-0);
			double RIy=(3*i)-90;
			sb.drawwepdot(-51-(-RIx*1),53-(-RIy*1),(2,2));
			sb.drawwepdot(-54-(-RIx*1),53-(-RIy*1),(4,2));
			}
		}else{
			for(int i=hdw.weaponstatus[ASHTS_MAG];i>0;i--){
			double RIrad=37; //circle radius
			double RIx=(RIrad-0)*cos((3*i)-0);
			double RIy=(3*i)-90;
			sb.drawwepdot(-51-(-RIx*1),54-(-RIy*1),(2,2));
			sb.drawwepdot(-54-(-RIx*1),54-(-RIy*1),(4,2));
			}
		}
	}
	}
//============================================================================
			if(hdw.weaponstatus[ASHTS_CHAMBER]==3){
				sb.drawwepdot(-26,-25,(3,5));
				sb.drawwepdot(-26,-22,(3,2));
			}else if(hdw.weaponstatus[ASHTS_CHAMBER]==2){
				sb.drawwepdot(-26,-25,(3,2));
				sb.drawwepdot(-26,-22,(3,2));
			}else if(hdw.weaponstatus[ASHTS_CHAMBER]==1)
				{sb.drawwepdot(-26,-22,(3,2));}
		
		//WHAT
		if(hdw.weaponstatus[0]&ASHTF_GZCHAMBER){
			sb.drawwepdot(-16,-11,(3,1));
		}
		
		int lod=clamp(hdw.weaponstatus[ASHTS_ZMAG]%100,0,50);
		if(hdw.weaponstatus[ASHTS_ZMAG]>100)lod=random[shitgun](10,99);
		sb.drawnum(lod,-16,-10,sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_TEXT_ALIGN_RIGHT,Font.CR_RED);
				sb.drawwepcounter(hdw.weaponstatus[ASHTS_ZAUTO],
			-24,-5,"RBRSA3A7","STFULAUT","STBURAUT"
		);
		sb.drawwepnum(lod,50,posy:-2);
		
		int ZMnextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD4mMag")));
			if(ZMnextmagloaded>50){
				sb.drawimage("ZMAGA0",(-65,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(2,2));
			}else if(ZMnextmagloaded<1){
				sb.drawimage("ZMAGC0",(-65,-4),sb.DI_SCREEN_CENTER_BOTTOM,alpha:ZMnextmagloaded?0.6:1.,scale:(2,2));
			}else sb.drawbar(
				"ZMAGNORM","ZMAGGREY",
				ZMnextmagloaded,50,
				(-65,-4),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HD4mMag"),-64,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
		
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Swap to Underbarrel ZM66\n"
		..WEPHELP_ALTRELOAD.."  Reload Underbarrel ZM66\n"
		..WEPHELP_RELOAD.."  Reload/Cycle bolt\n"
		..WEPHELP_FIREMODE.."  Destroy/Annihilate\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc,string whichdot
	){
	if(hdw.weaponstatus[0]&ASHTF_GLMODE){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		sb.SetClipRect(
			-16+bob.x,-4+bob.y,32,16,
			sb.DI_SCREEN_CENTER
		);
		vector2 bobb=bob*4;
		bobb.y=clamp(bobb.y,-8,8);
		sb.drawimage(
			"RPRFGRN",(0,-11)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"RPRZBCK",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
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
			"RPRZBCK",(0,-11)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
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
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GLMODE, 3);
		#### # 0{
			if(
				invoker.weaponstatus[ASHTS_HEAT]>RILD_RPRZMCOOKOFF    
				&&invoker.weaponstatus[0]&ASHTF_GZCHAMBER
				&&!(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
			){
				setweaponstate("cookoff");
				return;
			}
		}
		#### # 1{
			A_SetCrosshair(21);
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			if(
				invoker.weaponstatus[ASHTS_HEAT]>RILD_RPRZMCOOKOFF    
				&&invoker.weaponstatus[0]&ASHTF_GZCHAMBER
				&&!(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
			){
				setweaponstate("cookoff");
				return;
			}
		}
		#### # 1{
			A_SetCrosshair(21);
			A_WeaponReady(WRF_ALL);
			if(invoker.weaponstatus[ASHTS_ZAUTO]>2)invoker.weaponstatus[ASHTS_ZAUTO]=2;  
		}
		goto readyend;
	
	user3:
		#### # 3;
		#### # 0 { if(PressingReload())setweaponstate("reloadselect");
					}
		#### # 0 A_JumpIf(invoker.weaponstatus[0]&ASHTF_GLMODE, 3);
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_BOXER]==1, 4);
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_MagManager("RIReapD20");
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_MagManager("RIReapM8");
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_MagManager("HD4mMag");
		goto ready;

	user2:
	firemode:
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GLMODE, "zmfiremode");
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1{
			int aut=invoker.weaponstatus[ASHTS_AUTO];
			if(aut>=0){
				invoker.weaponstatus[ASHTS_AUTO]=aut==0?1:0;
			}
		}goto nope;
	zmfiremode:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0; 
		#### # 1{if(invoker.weaponstatus[ASHTS_ZAUTO]>=2)invoker.weaponstatus[ASHTS_ZAUTO]=0;  
			else invoker.weaponstatus[ASHTS_ZAUTO]++;
			A_WeaponReady(WRF_NONE);
		}goto nope;
	fire:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			if(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GLMODE)setweaponstate("fireZM");
		}goto fire2;
	fireZM:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 {
		if(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN){
				setweaponstate("nope");
			}
			if(invoker.weaponstatus[ZM66S_AUTO])A_SetTics(3);
		}
		goto shootgun;
	hold:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_JumpIf(invoker.weaponstatus[0]&ASHTF_GLMODE, 2);
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
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_ZAUTO]>4,"nope");
		#### # 0 A_JumpIf(invoker.weaponstatus[ASHTS_ZAUTO],"shootgun");
		goto nope;
	user4:
	unload:
		ASTA JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_JUSTUNLOAD;
			if(invoker.weaponstatus[0]&ASHTF_GLMODE){setweaponstate("zmunload");
			}else if(invoker.weaponstatus[ASHTS_MAG]>=0){
				if(invoker.weaponstatus[ASHTS_BOXER]>0){
				setweaponstate("boxout");
				}else{
				setweaponstate("unmag");
				}
			}else if(invoker.weaponstatus[ASHTS_CHAMBER]>0){setweaponstate("prechamber");}
		}goto nope;
	altfire:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(6,0){
			invoker.weaponstatus[0]^=ASHTF_GLMODE;
			A_SetCrosshair(21);
			A_StartSound("weapons/pocket",CHAN_WEAPON);
			A_SetHelpText();
		}goto nope;
	
	althold:
		---- A 1;
		---- A 0 A_Refire();
		goto ready;
//===========================================
// THANKS CHIIINNAAAAAAA
//===========================================
//	althold:
//		---- A 1{
//			if(
//				invoker.weaponstatus[ASHTS_HEAT]>RILD_RPRZMCOOKOFF      
//				&&!(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
//				&&invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER
//			)setweaponstate("cookoff");
//			else A_WeaponReady(WRF_NOFIRE);
//		}
//		---- A 0 A_Refire();
//		goto ready;


	ZMflash:
		ASTM JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 bright{
			A_Light1();
			HDFlashAlpha(-16);
			A_StartSound("weapons/rifle",CHAN_WEAPON);
			A_ZoomRecoil(max(0.95,1.-0.05*min(invoker.weaponstatus[ASHTS_ZAUTO],3)));

			//shoot the bullet
			//copypaste any changes to spawnshoot as well!
			double brnd=invoker.weaponstatus[ASHTS_HEAT]*0.01;
			HDBulletActor.FireBullet(self,"HDB_426",
				spread:brnd>1.2?invoker.weaponstatus[ASHTS_HEAT]*0.1:0
			);

			A_MuzzleClimb(
				-frandom(0.1,0.1),-frandom(0,0.1),
				-0.2,-frandom(0.3,0.4),
				-frandom(0.4,1.4),-frandom(1.3,2.6)
			);

			invoker.weaponstatus[ASHTS_FLAGS]&=~ASHTF_GZCHAMBER;
			invoker.weaponstatus[ASHTS_HEAT]+=random(3,5);
			A_AlertMonsters();
		}
		goto lightdone;

	jam:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(-1,36){
			A_StartSound("weapons/riflejam",CHAN_WEAPON);
			invoker.weaponstatus[0]|=ASHTF_CHAMBERBROKEN;
			invoker.weaponstatus[ASHTS_FLAGS]&=~ASHTF_GZCHAMBER;
		}
		#### # 1 offset(1,30) A_StartSound("weapons/riflejam",6);
		goto nope;

	shootgun:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1{
			if(
				//can neither shoot nor chamber
				invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN
				||(
					!(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER)
					&&invoker.weaponstatus[ASHTS_ZMAG]<1
				)
			){
				setweaponstate("nope");
			}else if(!(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER)){
				//no shot but can chamber
				setweaponstate("chamber_premanual");
			}else{
				A_GunFlash("ZMflash");
				A_WeaponReady(WRF_NONE);
				if(invoker.weaponstatus[ASHTS_ZAUTO]>=2)invoker.weaponstatus[ASHTS_ZAUTO]++;  
			}
		}
	zmchamber:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(0,32){
			if(invoker.weaponstatus[ASHTS_ZMAG]<1){
				setweaponstate("nope");
				return;
			}
			if(invoker.weaponstatus[ASHTS_ZMAG]%100>0){  
				if(invoker.weaponstatus[ASHTS_ZMAG]==51)invoker.weaponstatus[ASHTS_ZMAG]=50;
				invoker.weaponstatus[ASHTS_ZMAG]--;
				invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_GZCHAMBER;
			}else{
				invoker.weaponstatus[ASHTS_ZMAG]=min(invoker.weaponstatus[ASHTS_ZMAG],0);
				A_StartSound("weapons/rifchamber",5);
			}
			if(brokenround()){
				setweaponstate("jam");
				return;
			}
			if(!invoker.weaponstatus[ASHTS_ZAUTO])A_SetTics(1);
			else if(invoker.weaponstatus[ASHTS_ZAUTO]>4)setweaponstate("nope");
			else if(invoker.weaponstatus[ASHTS_ZAUTO]>1)A_SetTics(0);
			A_WeaponReady(WRF_NOFIRE); //not WRF_NONE: switch to drop during cookoff
		}
		#### # 0 A_JumpIf(
			invoker.weaponstatus[ASHTS_HEAT]>RILD_RPRZMCOOKOFF    
			&&invoker.weaponstatus[0]&ASHTF_GZCHAMBER
			&&!(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
		,"cookoff");
		#### # 0 A_Refire();
		goto ready;

	cookoffaltfirelayer:
		TNT1 AAA 1{
			if(JustPressed(BT_ALTFIRE)){
				invoker.weaponstatus[0]^=ASHTF_GLMODE;
				A_SetTics(10);
			}else if(JustPressed(BT_ATTACK)&&invoker.weaponstatus[0]&ASHTF_GLMODE)A_Overlay(11,"fire2");
		}stop;
	cookoff:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
//		#### # 0 A_Log("reload shart",true);
		#### # 0{
			A_ClearRefire();
			if(
				(invoker.weaponstatus[ASHTS_ZMAG]>=0)	//something to detach
				&&(PressingAltReload()||PressingUnload())	//trying to detach
			){
				A_StartSound("weapons/rifleclick2",CHAN_WEAPON);
				A_StartSound("weapons/rifleload",5);
				HDMagAmmo.SpawnMag(self,"HD4mMag",invoker.weaponstatus[ASHTS_ZMAG]);
				invoker.weaponstatus[ASHTS_ZMAG]=-1;
			}
			setweaponstate("shootgun");
	}
	chamber_premanual:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(0,33);
		#### # 1 offset(-3,34);
		#### A 1 offset(-8,37);
		goto ZMchamber_manual;

	zmunload:
		#### # 0{
			invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[ASHTS_ZMAG]>=0  
			){
				setweaponstate("unloadmag");
			}else if(
				invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER
				||invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_CHAMBERBROKEN
			){
				setweaponstate("ZMunloadchamber");
			}else{
				setweaponstate("unloadmag");
			}
		}
	altreload:
		#### # 0{
			invoker.weaponstatus[ASHTS_FLAGS]&=~ASHTF_JUSTUNLOAD;
			if(	//full mag, no jam, not unload-only - why hit reload at all?
				!(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
				&&invoker.weaponstatus[ASHTS_ZMAG]%100>=50
				&&!(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_JUSTUNLOAD)
			){
				setweaponstate("nope");
			}else if(	//if jammed, treat as unloading
				invoker.weaponstatus[ASHTS_ZMAG]<0
				&&invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN
			){
				invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_JUSTUNLOAD;
				setweaponstate("ZMunloadchamber");
			}else if(!HDMagAmmo.NothingLoaded(self,"HD4mMag")){
				setweaponstate("unloadmag");
			}
		}goto nope;
	unloadmag:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(0,33);
		#### # 1 offset(-3,34);
		#### # 1 offset(-8,37);
		ASTJ JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(-11,39){
			if(	//no mag, skip unload
				invoker.weaponstatus[ASHTS_ZMAG]<0
			){
				setweaponstate("ZMmagout");
			}
			if(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
				invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_JUSTUNLOAD;
			A_SetPitch(pitch-0.3,SPF_INTERPOLATE);
			A_SetAngle(angle-0.3,SPF_INTERPOLATE);
			A_StartSound("weapons/rifleclick2",CHAN_WEAPON);
		}
		ASTK JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(-12,40){
			A_SetPitch(pitch-0.3,SPF_INTERPOLATE);
			A_SetAngle(angle-0.3,SPF_INTERPOLATE);
			A_StartSound("weapons/rifleload",CHAN_WEAPON);
		}
		#### # 20 offset(-14,44){
			int inmag=invoker.weaponstatus[ASHTS_ZMAG]%100;
			invoker.weaponstatus[ASHTS_ZMAG]=-1;
			if(
				!PressingUnload()&&!PressingAltReload()
				||A_JumpIfInventory("HD4mMag",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HD4mMag",inmag);
				A_SetTics(1);
			}else{
				HDMagAmmo.GiveMag(self,"HD4mMag",inmag);
				A_StartSound("weapons/pocket",CHAN_WEAPON);
				if(inmag<51)A_Log(HDCONST_426MAGMSG,true);
			}
		}
	ZMmagout:
		ASTK JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			if(
				invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_JUSTUNLOAD
				||!countinv("HD4mMag")
			)setweaponstate("ZMreloadend");
		} //fallthrough to loadmag
	ZMloadmag:
		ASTK JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 12{
			let zmag=HD4mMag(findinventory("HD4mMag"));
			if(!zmag){setweaponstate("reloadend");return;}
			A_StartSound("weapons/pocket",CHAN_WEAPON);
			if(zmag.DirtyMagsOnly())invoker.weaponstatus[0]|=ASHTF_LOADINGDIRTY;
			else{
				invoker.weaponstatus[0]&=~ASHTF_LOADINGDIRTY;
				A_SetTics(10);
			}
		}
		#### # 2 A_JumpIf(invoker.weaponstatus[0]&ASHTF_LOADINGDIRTY,"loadmagdirty");
	loadmagclean:
		ASTK JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 8 offset(-15,45)A_StartSound("weapons/rifleload",CHAN_WEAPON);
		ASTJ JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(-14,44){
			let zmag=HD4mMag(findinventory("HD4mMag"));
			if(!zmag){setweaponstate("reloadend");return;}
			if(zmag.DirtyMagsOnly()){
				setweaponstate("loadmagdirty");
				return;
			}
			invoker.weaponstatus[ASHTS_ZMAG]=zmag.TakeMag(true);
			A_StartSound("weapons/rifleclick2",CHAN_WEAPON);
		}goto ZMchamber_manual;
	loadmagdirty:
		ASTJ JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 0{
			if(PressingReload())invoker.weaponstatus[0]|=ASHTF_STILLPRESSINGRELOAD;
			else invoker.weaponstatus[0]&=~ASHTF_STILLPRESSINGRELOAD;
		}
		#### # 3 offset(-15,45)A_StartSound("weapons/rifleload",CHAN_WEAPON);
		#### # 1 offset(-15,42)A_WeaponMessage(HDCONST_426MAGMSG,70);
		#### # 1 offset(-15,41){
			bool prr=PressingAltReload();
			if(
				prr
				&&!(invoker.weaponstatus[0]&ASHTF_STILLPRESSINGRELOAD)
			){
				setweaponstate("reallyloadmagdirty");
			}
			else if(!PressingAltReload())invoker.weaponstatus[0]&=~ASHTF_STILLPRESSINGRELOAD;
		}
		goto nope;
	reallyloadmagdirty:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(-14,44)A_StartSound("weapons/rifleclick2",CHAN_WEAPON);
		#### # 8 offset(-18,50){
			let zmag=HD4mMag(findinventory("HD4mMag"));
			if(!zmag){setweaponstate("reloadend");return;}
			invoker.weaponstatus[ASHTS_ZMAG]=zmag.TakeMag(true)+100;
			A_MuzzleClimb(
				-frandom(0.4,0.6),frandom(2.,3.)
				-frandom(0.2,0.3),frandom(1.,1.6)
			);
			A_StartSound("weapons/rifleclick2",6);
			A_StartSound("weapons/smack",7);

			string realmessage=HDCONST_426MAGMSG;
			realmessage=realmessage.left(random(13,20));
			realmessage.appendformat("\cgFUCK YOURSELF. \cj--mgmt.");
			A_WeaponMessage(realmessage,70);
		}
		#### # 4 offset(-17,49);
		goto ZMchamber_manual;
	ZMchamber_manual:
		ASTJ JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(-15,43){
			if(!invoker.weaponstatus[ASHTS_ZMAG]%100)invoker.weaponstatus[ASHTS_ZMAG]=0;
			if(
				!(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER)
				&& !(invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER)
				&& invoker.weaponstatus[ASHTS_ZMAG]%100>0
			){
				A_StartSound("weapons/rifleclick");
				if(invoker.weaponstatus[ASHTS_ZMAG]==51)invoker.weaponstatus[ASHTS_ZMAG]=49;
				else invoker.weaponstatus[ASHTS_ZMAG]--;
				invoker.weaponstatus[ASHTS_FLAGS]|=ASHTF_GZCHAMBER;
				brokenround();
			}else setweaponstate("ZMreloadend");
			A_WeaponBusy();
		}
		goto nope;
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 4 offset(-14,45);
		goto reloadend;

	ZMreloadend:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(-11,39);
		#### # 1 offset(-8,37) A_MuzzleClimb(frandom(0.2,-2.4),frandom(0.2,-1.4));
		#### # 1 offset(-3,34);
		#### # 1 offset(0,33);
		goto nope;


	ZMunloadchamber:
		ASTL JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 1 offset(-3,34);
		#### # 1 offset(-9,39);
		#### # 3 offset(-19,44) A_MuzzleClimb(frandom(-0.4,0.4),frandom(-0.4,0.4));
		ASTJ JIHGFEDCBA 0 A_ReaperSpriteSelect();
		#### # 2 offset(-16,42){
			A_MuzzleClimb(frandom(-0.4,0.4),frandom(-0.4,0.4));
			if(
				invoker.weaponstatus[ASHTS_FLAGS]&ASHTF_GZCHAMBER
				&&!(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
			){
				A_SpawnItemEx("ZM66DroppedRound",0,0,20,
					random(4,7),random(-2,2),random(-2,1),0,
					SXF_NOCHECKPOSITION
				);
				invoker.weaponstatus[ASHTS_FLAGS]&=~ASHTF_GZCHAMBER;
				A_StartSound("weapons/rifleclick2",CHAN_WEAPON);
			}else if(!random(0,4)){
				invoker.weaponstatus[0]&=~ASHTF_CHAMBERBROKEN;
				invoker.weaponstatus[ASHTS_FLAGS]&=~ASHTF_GZCHAMBER;
				A_StartSound("weapons/rifleclick");
				for(int i=0;i<3;i++)A_SpawnItemEx("TinyWallChunk",0,0,20,
					random(4,7),random(-2,2),random(-2,1),0,SXF_NOCHECKPOSITION
				);
				if(!random(0,5))A_SpawnItemEx("HDSmokeChunk",12,0,height-12,4,frandom(-2,2),frandom(2,4));
			}else if(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN){
				A_StartSound("weapons/smack",CHAN_WEAPON);
			}
		}goto reloadend;

//=============================================
// 
//=============================================

	spawn:
		ASHR A -1 nodelay{
		// A Drum 450
		// B -Drum 450
		// C Drum -450
		// D -Drum -450
		// E Stick 450
		// F stick -450
		if(invoker.weaponstatus[ASHTS_BOXER]==0&&invoker.weaponstatus[ASHTS_MAG]>-1&&invoker.weaponstatus[ASHTS_ZMAG]>-1)frame=0;
		if(invoker.weaponstatus[ASHTS_BOXER]==0&&invoker.weaponstatus[ASHTS_MAG]<0&&invoker.weaponstatus[ASHTS_ZMAG]>-1)frame=1;
		if(invoker.weaponstatus[ASHTS_BOXER]==1&&invoker.weaponstatus[ASHTS_MAG]>-1&&invoker.weaponstatus[ASHTS_ZMAG]>-1)frame=4;
		if(invoker.weaponstatus[ASHTS_BOXER]==0&&invoker.weaponstatus[ASHTS_MAG]>-1&&invoker.weaponstatus[ASHTS_ZMAG]<0)frame=2;
		if(invoker.weaponstatus[ASHTS_BOXER]==0&&invoker.weaponstatus[ASHTS_MAG]<0&&invoker.weaponstatus[ASHTS_ZMAG]<0)frame=3;
		if(invoker.weaponstatus[ASHTS_BOXER]==1&&invoker.weaponstatus[ASHTS_MAG]>-1&&invoker.weaponstatus[ASHTS_ZMAG]<0)frame=5;
		}
		#### # 0{
			//don't jam just because
			if(
				!(invoker.weaponstatus[0]&ASHTF_GZCHAMBER)
				&&!(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
				&&invoker.weaponstatus[ASHTS_ZMAG]>0
				&&invoker.weaponstatus[ASHTS_ZMAG]<51
			){
				invoker.weaponstatus[ASHTS_ZMAG]--;
				invoker.weaponstatus[0]|=ASHTF_GZCHAMBER;
				brokenround();
			}
			
		}
		#### # 0{
			if(
				invoker.weaponstatus[0]&ASHTF_GZCHAMBER
				&&!(invoker.weaponstatus[0]&ASHTF_CHAMBERBROKEN)
				&&invoker.weaponstatus[ASHTS_HEAT]>RILD_RPRZMCOOKOFF  
			){
				setstatelabel("spawnshoot");
			}
		}
	spawnshoot:
		#### # 1 bright light("SHOT"){
			if(invoker.weaponstatus[ASHTS_MAG]=1){
				sprite=getspriteindex("ASHRA0");
			}else sprite=getspriteindex("ASHRA0");

			//shoot the bullet
			//copy any changes to flash as well!
			double brnd=invoker.weaponstatus[ASHTS_HEAT]*0.01;
			HDBulletActor.FireBullet(self,"HDB_426",
				spread:brnd>1.2?invoker.weaponstatus[ASHTS_HEAT]*0.1:0
			);

			A_ChangeVelocity(frandom(-0.4,0.1),frandom(-0.1,0.08),1,CVF_RELATIVE);
			A_StartSound("weapons/rifle",CHAN_VOICE);
			invoker.weaponstatus[ASHTS_HEAT]+=random(3,5);
			angle+=frandom(2,-7);
			pitch+=frandom(-4,4);
		}
		#### # 2{
			if(invoker.weaponstatus[ASHTS_ZAUTO]>1)A_SetTics(0);  
			invoker.weaponstatus[0]&=~(ASHTF_GZCHAMBER|ASHTF_CHAMBERBROKEN);
			if(invoker.weaponstatus[ASHTS_ZMAG]%100>0){  
				invoker.weaponstatus[ASHTS_ZMAG]--;
				invoker.weaponstatus[0]|=ASHTF_GZCHAMBER;
				brokenround();
			}
		}goto spawn;
	
//===========================
// END OF STATES
//===========================		
	}
	
	override void InitializeWepStats(bool idfa){
		weaponstatus[ASHTS_FLAGS]|=ASHTF_GZCHAMBER;
		weaponstatus[ASHTS_ZMAG]=51;
		weaponstatus[ASHTS_MAG]=20;
		weaponstatus[ASHTS_CHAMBER]=3;
		if(!idfa)weaponstatus[ASHTS_AUTO]=0;
	}
}
	
//		ASHTF_JUSTUNLOAD 1
//	ASHTF_GLMODE=2,
//	ASHTF_GZCHAMBER=4,
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
// ASHTS_BOXER=8
//	ASHTS_BOXEE=9
//	ASHTS_SIGHTS=10

