// ------------------------------------------------------------
// SMG
// ------------------------------------------------------------
const RILD_TMPSN="TMP";
class RIThompson:HDWeapon{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "TMPSN"
		//$Sprite "TMPNA0"

		obituary "%o found out what was in %k's violin case.";
		weapon.selectionorder 291;
		weapon.slotnumber 2;
		weapon.kickback 30;
		weapon.bobrangex 0.3;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		scale 0.50;
		inventory.pickupmessage "You got the Thompson SMG! Rata-tat-tat!";
		hdweapon.barrelsize 30,1,3;
		hdweapon.refid RILD_TMPSN;
		tag "Thompson Submachine Gun (9mm Repro)";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	override double gunmass(){
		return 10+(weaponstatus[TMPS_MAG]<0)?-0.5:(weaponstatus[TMPS_MAG]*0.02);
	}
	override double weaponbulk(){
		int mg=weaponstatus[TMPS_MAG];
		if(mg<0)return 110;
		else return (110+ENC_TMPS_DRM_LOADED)+mg*ENC_9_LOADED;
	}
	override void failedpickupunload(){
		failedpickupunloadmag(TMPS_MAG,"RITmpsD70");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HDPistolAmmo"))owner.A_DropInventory("HDPistolAmmo",amt*70);
			else owner.A_DropInventory("RITmpsD70",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HDPistolAmmo");
		owner.A_TakeInventory("RITmpsD70");
		owner.A_GiveInventory("RITmpsD70");
	}
	override string,double getpickupsprite(){
		string spr;
		int wepstat0=weaponstatus[0];
		spr="TMPN";
		//set to no-mag frame
		if(weaponstatus[TMPS_BOXER]==1){
			if(weaponstatus[TMPS_MAG]<0)spr=spr.."B";
				else spr=spr.."C";
			}else{
				if(weaponstatus[TMPS_MAG]<0)spr=spr.."B";
				else spr=spr.."A";
			}
		return spr.."0",1.;
	}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel == 1){
			int nextdrumloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("RITmpsD70")));
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD9mMag30")));
			if(weaponstatus[TMPS_BOXER]==1){
//=============================================================
				if(nextdrumloaded>=70){
		sb.drawimage("TDRMD0",(-61,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.75,1.75));
				}else if(nextdrumloaded<1){
					sb.drawimage("TDRMC0",(-61,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextdrumloaded?0.6:1.,scale:(1.75,1.75));
				}else sb.drawbar(
					"TDRMNORM","TDRMGREY",
					nextdrumloaded,70,
					(-61,-3),-1,
					sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
				);
			sb.drawnum(hpl.countinv("RITmpsD70"),-58,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
// -----------------------------------------------------
			if(nextmagloaded>=30){
					sb.drawimage("CLP3A0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(3,3));
				}else if(nextmagloaded<1){
					sb.drawimage("CLP3B0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(3,3));
				}else sb.drawbar(
					"CLP3NORM","CLP3GREY",
					nextmagloaded,30,
					(-46,-3),-1,
					sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
				);
			sb.drawnum(hpl.countinv("HD9mMag30"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
//+++++++++++++++++++++++++++++++++++++++++++++++++
			sb.drawwepcounter(hdw.weaponstatus[TMPS_AUTO],
				-22,-12,"RBRSA3A7","STFULAUT"
			);
			for(int i=hdw.weaponstatus[TMPS_MAG];i>0;i--){
				double RIrad=13; //circle radius
				double RIx=(1);
				double RIy=(.75*i);
				sb.drawwepdot(-18,-27-(-RIy*1),(2,1));
			}
			if(hdw.weaponstatus[TMPS_CHAMBER]==2){sb.drawwepdot(-28,-17,(3,2));
				}else if(hdw.weaponstatus[TMPS_CHAMBER]==1){sb.drawwepdot(-28,-22,(3,2));
				}else{sb.drawwepdot(-28,-27,(3,2));
				}
//=======================================================
			}else{
//=======================================================
				if(nextdrumloaded>=70){
					sb.drawimage("TDRMD0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.75,1.75));
				}else if(nextdrumloaded<1){
					sb.drawimage("TDRMC0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextdrumloaded?0.6:1.,scale:(1.75,1.75));
				}else sb.drawbar(
					"TDRMNORM","TDRMGREY",
					nextdrumloaded,70,
					(-46,-3),-1,
					sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
				);
			sb.drawnum(hpl.countinv("RITmpsD70"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
// -----------------------------------------------------
			if(nextmagloaded>=30){
					sb.drawimage("CLP3A0",(-61,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(3,3));
				}else if(nextmagloaded<1){
					sb.drawimage("CLP3B0",(-61,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(3,3));
				}else sb.drawbar(
					"CLP3NORM","CLP3GREY",
					nextmagloaded,30,
					(-61,-3),-1,
					sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
				);
			sb.drawnum(hpl.countinv("HD9mMag30"),-58,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
//+++++++++++++++++++++++++++++++++++++++++++++++++
			sb.drawwepcounter(hdw.weaponstatus[TMPS_AUTO],
				-20,-12,"RBRSA3A7","STFULAUT"
			);
			for(int i=hdw.weaponstatus[TMPS_MAG];i>0;i--){
				double RIrad=13; //circle radius
				double RIx=(RIrad-0)*cos((5.1428571428571428571428571428571*i)-90);
				double RIy=(RIrad-0)*sin((5.1428571428571428571428571428571*i)-90);
				sb.drawwepdot(-27-(RIx*1),-18-(-RIy*1),(2,2));
			}
			if(hdw.weaponstatus[TMPS_CHAMBER]==2){sb.drawwepdot(-26,-17,(3,2));
				}else if(hdw.weaponstatus[TMPS_CHAMBER]==1){sb.drawwepdot(-26,-22,(3,2));
				}else{sb.drawwepdot(-26,-27,(3,2));
				}
			}
		}
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_RELOAD.."  Reload (Hold "..WEPHELP_FIREMODE.." to swap magazine types\)\n"
		..WEPHELP_FIREMODE.."  Semi/Auto\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc,string whichdot
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		sb.SetClipRect(
			-16+bob.x,-4+bob.y,32,16,
			sb.DI_SCREEN_CENTER
		);
		vector2 bobb=bob*3;
		bobb.y=clamp(bobb.y,-8,8);
		sb.drawimage(
			"TmpSFNT",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"TmpSBCK",(0,-11)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
	}
//	Sprite code
//A - 0 - regular
//B - 1 - no drum
//C - 2 - reg hands
//D - 3 - no drum hands

	action void A_ThompsonSpriteSelect(){
	    let psp = player.FindPSprite (PSP_Weapon);
        if (!psp)
               return;
		if(invoker.weaponstatus[TMPS_BOXER]==0&&invoker.weaponstatus[TMPS_MAG]>-1)psp.frame=2;
//		if(invoker.weaponstatus[TMPS_BOXER]==1)psp.frame=3;
		else psp.frame=3;
	}
	states{
	select0:
		TMPB ABCD 0 A_ThompsonSpriteSelect();
		goto select0small;
	deselect0:
		TMPB ABCD 0 A_ThompsonSpriteSelect();
		goto deselect0small;

	ready:
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 1{
			A_SetCrosshair(21);

			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
	user3:
		#### # 0 A_JumpIf(invoker.weaponstatus[TMPS_BOXER]==1,"boxmagman");
		#### # 0 A_MagManager("RITmpsD70");
		goto ready;
	boxmagman:	
		#### # 0 A_MagManager("HD9mMag30");
		goto ready;

	altfire:
	althold:
		goto nope;
	hold:
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 0{
			if(
				//full auto
				invoker.weaponstatus[TMPS_AUTO]==2
			)setweaponstate("fire2");
			else if(
				//burst
				invoker.weaponstatus[TMPS_AUTO]<1
			)setweaponstate("nope");
		}goto fire;
	user2:
	firemode:
		#### # 3 { if(PressingReload())setweaponstate("reloadselect");
					}
		#### # 1{
			int aut=invoker.weaponstatus[TMPS_AUTO];
			if(aut>=0){
				invoker.weaponstatus[TMPS_AUTO]=aut==0?1:0;
			}
		}goto nope;
	fire:
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 1;
	fire2:
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 0{
			if(invoker.weaponstatus[TMPS_CHAMBER]==2
			&&invoker.weaponstatus[TMPS_MAG]>0){
				A_GunFlash();
			}else if (invoker.weaponstatus[TMPS_CHAMBER]==2
			&&invoker.weaponstatus[TMPS_MAG]<1
			&&invoker.weaponstatus[TMPS_BOXER]==1){
				setweaponstate("boxmagclick");
			}else{
				setweaponstate("nope");
			}
		}
		#### # 1 offset(0,40);
		#### # 0{
			if(invoker.weaponstatus[TMPS_CHAMBER]==1){
				A_SpawnItemEx("HDSpent9mm",
					cos(pitch)*10,0,height-12-sin(pitch)*10,
					vel.x,vel.y,vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
				invoker.weaponstatus[TMPS_MAG]--;
				invoker.weaponstatus[TMPS_CHAMBER]=0;
				if(invoker.weaponstatus[TMPS_MAG]<=0){
					A_PlaySound("weapons/tmpboltfin",CHAN_WEAPON);
				}
			}
		}
		#### # 0{
			if(invoker.weaponstatus[TMPS_BOXER]==0
			&&invoker.weaponstatus[TMPS_MAG]==0
			&&invoker.weaponstatus[TMPS_BOXER]==0){
				setweaponstate("dropboltdrum");
			}
		}
		#### # 0{
			invoker.weaponstatus[TMPS_CHAMBER]=2;
			if(invoker.weaponstatus[TMPS_AUTO]==2)A_SetTics(1);
			A_WeaponReady(WRF_NOFIRE);
		}
		TNT1 A 0 A_ReFire();
		goto ready;
	flash:
		TMPZ ABCD 0 A_ThompsonSpriteSelect();
		#### # 0{
			let bbb=HDBulletActor.FireBullet(self,"HDB_9",speedfactor:1.2);
			A_AlertMonsters();
			A_ZoomRecoil(0.95);
			A_PlaySound("weapons/tmpshot",CHAN_WEAPON, 2.5);
			invoker.weaponstatus[TMPS_CHAMBER]=1;
		}

		#### # 1 bright{
			HDFlashAlpha(64);
			A_Light1();
		}
		TNT1 A 0 A_MuzzleClimb(-frandom(0.4,0.6),-frandom(0.5,0.8),-frandom(0.4,0.6),-frandom(0.5,0.8));
		goto lightdone;
	boxmagclick:
		#### # 0 A_PlaySound("weapons/smgchamber",CHAN_WEAPON);
		goto nope;
	dropboltdrum:
		#### # 3;
		#### # 0{
			invoker.weaponstatus[TMPS_CHAMBER]=0;
			A_PlaySound("weapons/tmpdrumfin",CHAN_WEAPON, 2.5);
		}
		goto nope;
	unloadchamber:
		#### # 0 A_PlaySound("weapons/smgchamber",CHAN_WEAPON);
		#### # 1{
			invoker.weaponstatus[TMPS_CHAMBER]=0;
		}goto nope;
	loadchamber:
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 A_JumpIf(invoker.weaponstatus[TMPS_CHAMBER]<1,"nope");
		#### # 10{
			invoker.weaponstatus[TMPS_CHAMBER]=0;
		}goto readyend;
		
	user4:
	unload:
		// #### # 0 A_Log("Unload shart",true);
		#### # 0{
			invoker.weaponstatus[0]|=TMPF_JUSTUNLOAD;
			if(invoker.weaponstatus[TMPS_MAG]>=0){
				if(invoker.weaponstatus[TMPS_BOXER]>0){
					setweaponstate("unbox");
				}else if(invoker.weaponstatus[TMPS_BOXER]==0&&invoker.weaponstatus[TMPS_CHAMBER]<=1){
					setweaponstate("unmagempty");
				}else{
					setweaponstate("unmag");
				}
			}else if(invoker.weaponstatus[TMPS_CHAMBER]>0)setweaponstate("unloadchamber");
		}goto nope;
	reload:
		// #### # 0 A_Log("reload shart",true);
		#### # 3 { if(PressingFiremode())setweaponstate("reloadselect");
					}
		#### # 0{
			invoker.weaponstatus[0]&=~TMPF_JUSTUNLOAD;
			if(invoker.weaponstatus[TMPS_BOXER]>0){		
				if(invoker.weaponstatus[TMPS_MAG]>=30)setweaponstate("nope");
			}else{
				if(invoker.weaponstatus[TMPS_MAG]>=70)setweaponstate("nope");
			}
			if(HDMagAmmo.NothingLoaded(self,"RITmpsD70")){
					if(HDMagAmmo.NothingLoaded(self,"HD9mMag30")){
						setweaponstate("nope");
//						A_Log("auto d70 m30 fail",true);
					}else{
						invoker.weaponstatus[TMPS_BOXEE]=1;
						setweaponstate("reloadselect");
//						A_Log("d70 m30 autoswap",true);
					}
				}else if(HDMagAmmo.NothingLoaded(self,"HD9mMag30")){
					if(HDMagAmmo.NothingLoaded(self,"RITmpsD70")){
						setweaponstate("nope");
//						A_Log("auto m30 d70 fail",true);
					}else{
						invoker.weaponstatus[TMPS_BOXEE]=2;
						setweaponstate("reloadselect");
//						A_Log("m30 d70 autoswap",true);
					}
				}
			}
		goto reloadselect;
	reloadselect:
		// #### # 0 A_Log("reload select",true);
		#### # 0 A_JumpIf(invoker.weaponstatus[TMPS_BOXER]==0&&invoker.weaponstatus[TMPS_CHAMBER]<=1,"unmagempty");
		#### # 0 A_JumpIf(invoker.weaponstatus[TMPS_BOXER]==1,"unbox");
		goto unmag;
	unmag:
		// #### # 0 A_Log("unmag",true);
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 1 offset(5,34) A_SetCrosshair(21);
		TMPC ABCD 0 A_ThompsonSpriteSelect();
		#### # 2 offset(8,34);
		#### # 4 offset(14,36);
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(21,38);
		TMPE ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(28,42) A_PlaySound("weapons/tmpdrumout",CHAN_WEAPON);
		TMPF ABCD 0 A_ThompsonSpriteSelect();
		#### # 6 offset(34,54){
			A_MuzzleClimb(0.3,0.4);
			A_PlaySound("weapons/smgmagmove",CHAN_WEAPON);
		}
		TMPG ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(36,56);
		TMPD B 5 offset(34,54);
		TMPD B 0{
			int magamt=invoker.weaponstatus[TMPS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[TMPS_MAG]=-1;
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("RITmpsD70",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"RITmpsD70",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"RITmpsD70",magamt);
				A_PlaySound("weapons/pocket",CHAN_WEAPON);
				setweaponstate("pocketmag");
			}
		}
	unmagempty:
		// #### # 0 A_Log("unmagempty",true);
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 1 offset(5,34) A_SetCrosshair(21);
		TMPC ABCD 0 A_ThompsonSpriteSelect();
		#### # 2 offset(8,34);
		#### # 4 offset(14,36);
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(21,38);
		TMPI ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(21,38)A_PlaySound("weapons/pocket",CHAN_WEAPON);
		TMPJ ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(21,38);
		TMPK ABCD 0 A_ThompsonSpriteSelect();
		#### # 3 offset(21,38){
			A_PlaySound("weapons/tmpboltback",CHAN_WEAPON);
			invoker.weaponstatus[TMPS_CHAMBER]=2;
		}
		#### # 2 offset(20,36);
		TMPL ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(22,37);	
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(25,39);
		TMPE ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(28,42) A_PlaySound("weapons/tmpdrumout",CHAN_WEAPON);
		TMPF ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(34,54){
			A_MuzzleClimb(0.3,0.4);
			A_PlaySound("weapons/smgmagmove",CHAN_WEAPON);
		}
		TMPG ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(36,56);
		TMPD B 5 offset(34,54);
		TMPD B 0{
			int magamt=invoker.weaponstatus[TMPS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[TMPS_MAG]=-1;
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("RITmpsD70",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"RITmpsD70",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"RITmpsD70",magamt);
				A_PlaySound("weapons/pocket",CHAN_WEAPON);
				setweaponstate("pocketmag");
			}
		}
	unbox:
		// #### # 0 A_Log("unbox",true);
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 1 offset(5,34) A_SetCrosshair(21);
		TMPC ABCD 0 A_ThompsonSpriteSelect();
		#### # 2 offset(8,34);
		#### # 2 offset(14,36);
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 3 offset(21,38);
		TMPE ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(28,42) A_PlaySound("weapons/tmpdrumout",CHAN_WEAPON);
		TMPF ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(34,54){
			A_MuzzleClimb(0.3,0.4);
			A_PlaySound("weapons/smgmagmove",CHAN_WEAPON);
		}
		TMPG ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(36,56);
		TMPD B 4 offset(34,54);
		TMPD B 0{
			int magamt=invoker.weaponstatus[TMPS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[TMPS_MAG]=-1;		
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("HD9mMag30",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HD9mMag30",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"HD9mMag30",magamt);
				A_PlaySound("weapons/pocket",CHAN_WEAPON);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		// #### # 0 A_Log("pocket",true);
		TMPD B 0;
		#### # 7 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 7 offset(36,52) A_PlaySound("weapons/pocket",CHAN_WEAPON);
		#### # 7 offset(36,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 7 offset(34,54) A_PlaySound("weapons/pocket",CHAN_WEAPON);
	magout:
		TMPD B 0;
		#### # 0{
			if(invoker.weaponstatus[TMPS_BOXEE]==2){
				invoker.weaponstatus[TMPS_BOXER]=0;
				setweaponstate("rimagloader");
			}else if(invoker.weaponstatus[TMPS_BOXEE]==1){
				invoker.weaponstatus[TMPS_BOXER]=1;
				setweaponstate("rimagloader");
			}
		}
//		#### # 0 A_Log("postboxeee",true);
		#### # 0{
				if(PressingFiremode()&&invoker.weaponstatus[TMPS_BOXER]<1){invoker.weaponstatus[TMPS_BOXER]=1;
					}else if(PressingFiremode()&&invoker.weaponstatus[TMPS_BOXER]>0){invoker.weaponstatus[TMPS_BOXER]=0;
				}
		}
	rimagloader:
		#### # 0{
			if(invoker.weaponstatus[0]&TMPF_JUSTUNLOAD)setweaponstate("reloadend");
			else if(invoker.weaponstatus[TMPS_BOXER]==1)setweaponstate("loadboxmag");
			else setweaponstate("loadmag");
		}

	loadmag:
		// #### # 0 A_Log("loadmag",true);
		TMPD B 0;
		#### # 0 A_PlaySound("weapons/pocket",CHAN_WEAPON);
		#### # 1{
			invoker.weaponstatus[TMPS_MAG]=0;
			invoker.weaponstatus[TMPS_BOXER]=0;
			invoker.weaponstatus[TMPS_BOXEE]=0;
		}
		TMPG ABCD 0 A_ThompsonSpriteSelect();
		#### # 9 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		TMPF ABCD 0 A_ThompsonSpriteSelect();
		#### # 8 offset(30,48) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		TMPE ABCD 0 A_ThompsonSpriteSelect();
		#### # 6 offset(24,44) A_PlaySound("weapons/smgmagmove",CHAN_WEAPON);
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(12,38);
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 2 offset(0,34);
		#### # 0 A_JumpIf(invoker.weaponstatus[TMPS_CHAMBER]<=1,"chamber");
		#### # 0{
			invoker.weaponstatus[TMPS_MAG]=-1;
			let mmm=hdmagammo(findinventory("RITmpsD70"));
			if(mmm){
				invoker.weaponstatus[TMPS_MAG]=mmm.TakeMag(true);
				A_PlaySound("weapons/tmpdrumin",CHAN_BODY);
			}
			if(
				invoker.weaponstatus[TMPS_MAG]<1
				||invoker.weaponstatus[TMPS_CHAMBER]>0
			)setweaponstate("reloadend");
		}
		
	loadboxmag:
		// // #### # 0 A_Log("loadboxmag",true);
		TMPD B 0;
		#### # 0 A_PlaySound("weapons/pocket",CHAN_WEAPON);
		TMPG ABCD 0 A_ThompsonSpriteSelect();
		#### # 6 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		TMPF ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(30,48) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		TMPE ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(24,44) A_PlaySound("weapons/smgmagmove",CHAN_WEAPON);
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 2 offset(12,38);
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 2 offset(10,34){
			invoker.weaponstatus[TMPS_BOXER]=1;
			invoker.weaponstatus[TMPS_BOXEE]=0;
			let mmm=hdmagammo(findinventory("HD9mMag30"));
			if(mmm){
				invoker.weaponstatus[TMPS_MAG]=mmm.TakeMag(true);
				A_PlaySound("weapons/tmpdrumin",CHAN_BODY);
			}
		}
		#### # 0 A_JumpIf(invoker.weaponstatus[TMPS_CHAMBER]<=1,"chamber");
		#### # 0{
			if(
				invoker.weaponstatus[TMPS_MAG]<1
				||invoker.weaponstatus[TMPS_CHAMBER]>0
			)setweaponstate("reloadend");
		}
		
	chamber:
		TMPL ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(10,32);	
		TMPI ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(10,32)A_PlaySound("weapons/pocket",CHAN_WEAPON);
		TMPJ ABCD 0 A_ThompsonSpriteSelect();
		#### # 5 offset(11,34);
		TMPK ABCD 0 A_ThompsonSpriteSelect();
		#### # 3 offset(14,37){
			A_PlaySound("weapons/tmpboltback",CHAN_WEAPON);
			invoker.weaponstatus[TMPS_CHAMBER]=2;
		}
		#### # 2 offset(20,36);
		TMPL ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(10,34);	
	reloadend:
		// #### # 0 A_Log("reloadend",true);
		TMPD ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(0,34);
		TMPC ABCD 0 A_ThompsonSpriteSelect();
		#### # 4 offset(0,34);
		TMPA ABCD 0 A_ThompsonSpriteSelect();
		#### # 2 offset(0,34);
		goto nope;




	spawn:
		TMPN A -1 nodelay{
			if(invoker.weaponstatus[TMPS_MAG]<0)frame=1;
			if(invoker.weaponstatus[TMPS_BOXER]==1&&invoker.weaponstatus[TMPS_MAG]>=0)frame=2;		
		}
	}
	override void initializewepstats(bool idfa){
		weaponstatus[0]=0;
		weaponstatus[TMPS_MAG]=70;
		weaponstatus[TMPS_CHAMBER]=2;
		weaponstatus[TMPS_BOXER]=0;
		weaponstatus[TMPS_BOXEE]=0;
		if(!idfa)weaponstatus[TMPS_AUTO]=0;
	}
	override void loadoutconfigure(string input){
		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>0)weaponstatus[TMPS_AUTO]=clamp(firemode,0,1);
	}

}
enum TMPStatus{
	TMPF_JUSTUNLOAD=1,

	TMPS_FLAGS=0,
	TMPS_MAG=1, //-1 unmagged
	TMPS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
	TMPS_AUTO=3, //0 semi, 1 burst, 2 auto
	TMPS_BOXER=4,
	TMPS_BOXEE=5,
};

class ThompsonRandom:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let lll=RIThompson(spawn("RIThompson",pos,ALLOW_REPLACE));
			if(!lll)return;
			lll.special=special;
			lll.vel=vel;
			spawn("RITmpsD70",pos+(7,0,0),ALLOW_REPLACE);
			spawn("RITmpsD70",pos+(5,0,0),ALLOW_REPLACE);
		}stop;
	}
}
