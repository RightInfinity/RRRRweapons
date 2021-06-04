// ------------------------------------------------------------
// A 12-gauge pump for protection
// ------------------------------------------------------------
const RILD_KHLEB="KLB";
class RI_khleb:HDShotgun{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Khleb shotgun"
		//$Sprite "HUNTA0"

		weapon.selectionorder 31;
		weapon.slotnumber 3;
		weapon.slotpriority 1;
		weapon.bobrangex 0.21;
		weapon.bobrangey 0.86;
		scale 0.6;
		inventory.pickupmessage "It's Khleb-bering time!";
		hdweapon.barrelsize 30,0.5,2;
		hdweapon.refid RILD_KHLEB;
		tag "Khleb";
		obituary "%k pyhiscally removed a chunk of %o and threw that s#&! on the floor";
	}
	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=6.;
		double speedfactor=1.;
		let hhh=Ri_khleb(caller.findinventory("RI_khleb"));
		if(hhh)choke=hhh.weaponstatus[KHLEBS_CHOKE];

		choke=clamp(choke,0,7);
		spread=6.5-0.5*choke;
		speedfactor=1.+0.02857*choke;

		double shotpower=getshotpower();
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");
		let p=HDBulletActor.FireBullet(caller,"RI_23",
			spread:spread,speedfactor:speedfactor,amount:12
		);
		distantnoise.make(p,"world/shotgunfar");
		caller.A_StartSound("weapons/hunter",CHAN_WEAPON);
		return shotpower;
	}
	action void A_FireHunter(){
		double shotpower=invoker.Fire(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-2,2),-4.1);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,2)*shotpower,-0.7*shotpower);
		invoker.weaponstatus[KHLEBS_CHAMBER]=1;
		invoker.shotpower=shotpower;
	}

	override string,double getpickupsprite(){return "HUNT"..getpickupframe().."0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("SHL1A0",(-47,-10),basestatusbar.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("HDShellAmmo"),-46,-8,
				basestatusbar.DI_SCREEN_CENTER_BOTTOM
			);
		}
		if(hdw.weaponstatus[KHLEBS_CHAMBER]>1){
			sb.drawrect(-24,-14,5,3);
			sb.drawrect(-18,-14,2,3);
		}
		else if(hdw.weaponstatus[KHLEBS_CHAMBER]>0){
			sb.drawrect(-18,-14,2,3);
		}
		sb.drawwepnum(hdw.weaponstatus[KHLEBS_TUBE],hdw.weaponstatus[KHLEBS_TUBESIZE],posy:-7);
		for(int i=hdw.weaponstatus[SHOTS_SIDESADDLE];i>0;i--){
			sb.drawrect(-16-i*2,-5,1,3);
		}
	}
	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Shoot (choke: "..weaponstatus[KHLEBS_CHOKE]..")\n"
		..WEPHELP_ALTFIRE.."  Pump\n"
		..WEPHELP_RELOAD.."  Reload (side saddles first)\n"
		..WEPHELP_ALTRELOAD.."  Reload (pockets only)\n"
		..WEPHELP_FIREMODE.."+"..WEPHELP_RELOAD.."  Load side saddles\n"
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
			"frntsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"backsite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
	}
	override double gunmass(){
		int tube=weaponstatus[KHLEBS_TUBE];
		if(tube>4)tube+=(tube-4)*2;
		return 8+tube*0.3+weaponstatus[SHOTS_SIDESADDLE]*0.08;
	}
	override double weaponbulk(){
		return 125+(weaponstatus[SHOTS_SIDESADDLE]+weaponstatus[KHLEBS_TUBE])*ENC_SHELLLOADED;
	}
	action void A_SetAltHold(bool which){
		if(which)invoker.weaponstatus[0]|=KHLEBF_ALTHOLDING;
		else invoker.weaponstatus[0]&=~KHLEBF_ALTHOLDING;
	}
	action void A_Chamber(bool careful=false){
		int chm=invoker.weaponstatus[KHLEBS_CHAMBER];
		invoker.weaponstatus[KHLEBS_CHAMBER]=0;
		if(invoker.weaponstatus[KHLEBS_TUBE]>0){
			invoker.weaponstatus[KHLEBS_CHAMBER]=2;
			invoker.weaponstatus[KHLEBS_TUBE]--;
		}
		vector3 cockdir;double cp=cos(pitch);
		if(careful)cockdir=(-cp,cp,-5);
		else cockdir=(0,-cp*5,sin(pitch)*frandom(4,6));
		cockdir.xy=rotatevector(cockdir.xy,angle);
		actor fbs;bool gbg;
		if(chm>1){
			if(careful&&!A_JumpIfInventory("HDShellAmmo",0,"null")){
				HDF.Give(self,"HDShellAmmo",1);
			}else{
				[gbg,fbs]=A_SpawnItemEx("HDFumblingShell",
					cos(pitch)*8,0,height-8-sin(pitch)*8,
					vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}else if(chm>0){	
			cockdir*=frandom(1.,1.3);
			[gbg,fbs]=A_SpawnItemEx("HDSpentShell",
				cos(pitch)*8,frandom(-0.1,0.1),height-8-sin(pitch)*8,
				vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
	}
	action void A_CheckPocketSaddles(){
		if(invoker.weaponstatus[SHOTS_SIDESADDLE]<1)invoker.weaponstatus[0]|=KHLEBF_FROMPOCKETS;
		if(!countinv("HDShellAmmo"))invoker.weaponstatus[0]&=~KHLEBF_FROMPOCKETS;
	}
	action bool A_LoadTubeFromHand(){
		int hand=invoker.handshells;
		if(
			!hand
			||(
				invoker.weaponstatus[KHLEBS_CHAMBER]>0
				&&invoker.weaponstatus[KHLEBS_TUBE]>=invoker.weaponstatus[KHLEBS_TUBESIZE]
			)
		){
			EmptyHand();
			return false;
		}
		invoker.weaponstatus[KHLEBS_TUBE]++;
		invoker.handshells--;
		A_StartSound("weapons/huntreload",8,CHANF_OVERLAP);
		return true;
	}
	action bool A_GrabShells(int maxhand=2,bool settics=false,bool alwaysone=false){
		if(maxhand>0)EmptyHand();else maxhand=abs(maxhand);
		bool fromsidesaddles=!(invoker.weaponstatus[0]&KHLEBF_FROMPOCKETS);
		int toload=min(
			fromsidesaddles?invoker.weaponstatus[SHOTS_SIDESADDLE]:countinv("HDShellAmmo"),
			alwaysone?1:(invoker.weaponstatus[KHLEBS_TUBESIZE]-invoker.weaponstatus[KHLEBS_TUBE]),
			max(1,health/22),
			maxhand
		);
		if(toload<1)return false;
		invoker.handshells=toload;
		if(fromsidesaddles){
			invoker.weaponstatus[SHOTS_SIDESADDLE]-=toload;
			if(settics)A_SetTics(2);
			A_StartSound("weapons/pocket",8,CHANF_OVERLAP,0.4);
			A_MuzzleClimb(
				frandom(0.1,0.15),frandom(0.05,0.08),
				frandom(0.1,0.15),frandom(0.05,0.08)
			);
		}else{
			A_TakeInventory("HDShellAmmo",toload,TIF_NOTAKEINFINITE);
			if(settics)A_SetTics(7);
			A_StartSound("weapons/pocket",9);
			A_MuzzleClimb(
				frandom(0.1,0.15),frandom(0.2,0.4),
				frandom(0.2

,0.25),frandom(0.3,0.4),
				frandom(0.1,0.35),frandom(0.3,0.4),
				frandom(0.1,0.15),frandom(0.2,0.4)
			);
		}
		return true;
	}
	states{
	select0:
		SHTG A 0;
		goto select0big;
	deselect0:
		SHTG A 0;
		goto deselect0big;
	firemode:
		SHTG A 0;
	firemodehold:
		---- A 1{
			if(pressingreload()){
				setweaponstate("reloadss");
			}else A_WeaponReady(WRF_NONE);
		}
		---- A 0 A_JumpIf(pressingfiremode()&&invoker.weaponstatus[SHOTS_SIDESADDLE]<12,"firemodehold");
		goto nope;
	ready:
		SHTG A 0 A_JumpIf(pressingunload()&&(pressinguse()||pressingzoom()),"cannibalize");
		SHTG A 0 A_JumpIf(pressingaltfire(),2);
		SHTG A 0{
			if(!pressingaltfire()){
				if(!pressingfire())A_ClearRefire();
				A_SetAltHold(false);
			}
		}
		SHTG A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	reloadSS:
		SHTG A 1 offset(1,34);
		SHTG A 2 offset(2,34);
		SHTG A 3 offset(3,36);
	reloadSSrestart:
		SHTG A 6 offset(3,35);
		SHTG A 9 offset(4,34);
		SHTG A 4 offset(3,34){
			int hnd=min(
				countinv("HDShellAmmo"),
				12-invoker.weaponstatus[SHOTS_SIDESADDLE],
				max(1,health/22),
				3
			);
			if(hnd<1)setweaponstate("reloadSSend");
			else{
				A_TakeInventory("HDShellAmmo",hnd);
				invoker.weaponstatus[SHOTS_SIDESADDLE]+=hnd;
				A_StartSound("weapons/pocket",8);
			}
		}
		SHTG A 0 {
			if(
				!PressingReload()
				&&!PressingAltReload()
			)setweaponstate("reloadSSend");
			else if(
				invoker.weaponstatus[SHOTS_SIDESADDLE]<12
				&&countinv("HDShellAmmo")
			)setweaponstate("ReloadSSrestart");
		}
	reloadSSend:
		SHTG A 3 offset(2,34);
		SHTG A 1 offset(1,34) EmptyHand(careful:true);
		goto nope;
	hold:
		SHTG A 0{
			bool paf=pressingaltfire();
			if(
				paf&&!(invoker.weaponstatus[0]&KHLEBF_ALTHOLDING)
			)setweaponstate("chamber");
			else if(!paf)invoker.weaponstatus[0]&=~KHLEBF_ALTHOLDING;
		}
		SHTG A 1 A_WeaponReady(WRF_NONE);
		SHTG A 0 A_Refire();
		goto ready;
	fire:
		SHTG A 0 A_JumpIf(invoker.weaponstatus[KHLEBS_CHAMBER]==2,"shoot");
		SHTG A 1 A_WeaponReady(WRF_NONE);
		SHTG A 0 A_Refire();
		goto ready;
	shoot:
		SHTG A 2;
		SHTG A 1 offset(0,36) A_FireHunter();
		SHTG E 1;
		goto ready;
	altfire:
	chamber:
		SHTG A 0 A_JumpIf(invoker.weaponstatus[0]&KHLEBF_ALTHOLDING,"nope");
		SHTG A 0 A_SetAltHold(true);
		SHTG A 1 A_Overlay(120,"playsgco");
		SHTG AE 2 A_MuzzleClimb(0,frandom(0.6,1.));
		SHTG E 2 A_JumpIf(pressingaltfire(),"longstroke");
		SHTG EA 2 A_MuzzleClimb(0,-frandom(0.6,1.));
		SHTG E 0 A_StartSound("weapons/huntshort",8);
		SHTG E 0 A_Refire("ready");
		goto ready;
	longstroke:
		SHTG F 2 A_MuzzleClimb(frandom(1.,2.));
		SHTG F 0{
			A_Chamber();
			A_MuzzleClimb(-frandom(1.,2.));
		}
	racked:
		SHTG F 1 A_WeaponReady(WRF_NOFIRE);
		SHTG F 0 A_JumpIf(!pressingaltfire(),"unrack");
		SHTG F 0 A_JumpIf(pressingunload(),"rackunload");
		SHTG F 0 A_JumpIf(invoker.weaponstatus[KHLEBS_CHAMBER],"racked");
		SHTG F 0{
			int rld=0;
			if(pressingreload()){
				rld=1;
				if(invoker.weaponstatus[SHOTS_SIDESADDLE]>0)
				invoker.weaponstatus[0]&=~KHLEBF_FROMPOCKETS;
				else{
					invoker.weaponstatus[0]|=KHLEBF_FROMPOCKETS;
					rld=2;
				}
			}else if(pressingaltreload()){
				rld=2;
				invoker.weaponstatus[0]|=KHLEBF_FROMPOCKETS;
			}
			if(
				(rld==2&&countinv("HDShellAmmo"))
				||(rld==1&&invoker.weaponstatus[SHOTS_SIDESADDLE]>0)
			)setweaponstate("rackreload");
		}
		loop;
	rackreload:
		SHTG F 1 offset(-1,35) A_WeaponBusy(true);
		SHTG F 2 offset(-2,37);
		SHTG F 4 offset(-3,40);
		SHTG F 1 offset(-4,42) A_GrabShells(1,true,true);
		SHTG F 0 A_JumpIf(!(invoker.weaponstatus[0]&KHLEBF_FROMPOCKETS),"rackloadone");
		SHTG F 6 offset(-5,43);
		SHTG F 6 offset(-4,41) A_StartSound("weapons/pocket",9);
	rackloadone:
		SHTG F 1 offset(-4,42);
		SHTG F 2 offset(-4,41);
		SHTG F 3 offset(-4,40){
			A_StartSound("weapons/huntreload",8,CHANF_OVERLAP);
			invoker.weaponstatus[KHLEBS_CHAMBER]=2;
			invoker.handshells--;
			EmptyHand(careful:true);
		}
		SHTG F 5 offset(-4,41);
		SHTG F 4 offset(-4,40) A_JumpIf(invoker.handshells>0,"rackloadone");
		goto rackreloadend;
	rackreloadend:
		SHTG F 1 offset(-3,39);
		SHTG F 1 offset(-2,37);
		SHTG F 1 offset(-1,34);
		SHTG F 0 A_WeaponBusy(false);
		goto racked;

	rackunload:
		SHTG F 1 offset(-1,35) A_WeaponBusy(true);
		SHTG F 2 offset(-2,37);
		SHTG F 4 offset(-3,40);
		SHTG F 1 offset(-4,42);
		SHTG F 2 offset(-4,41);
		SHTG F 3 offset(-4,40){
			int chm=invoker.weaponstatus[KHLEBS_CHAMBER];
			invoker.weaponstatus[KHLEBS_CHAMBER]=0;
			if(chm==2){
				invoker.handshells++;
				EmptyHand(careful:true);
			}else if(chm==1)A_SpawnItemEx("HDSpentShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			if(chm)A_StartSound("weapons/huntreload",8,CHANF_OVERLAP);
		}
		SHTG F 5 offset(-4,41);
		SHTG F 4 offset(-4,40) A_JumpIf(invoker.handshells>0,"rackloadone");
		goto rackreloadend;

	unrack:
		SHTG F 0 A_Overlay(120,"playsgco2");
		SHTG E 2 A_JumpIf(!pressingfire(),1);
		SHTG EA 2{
			if(pressingfire())A_SetTics(1);
			A_MuzzleClimb(0,-frandom(0.6,1.));
		}
		SHTG A 0 A_ClearRefire();
		goto ready;
	playsgco:
		TNT1 A 8 A_StartSound("weapons/huntrackup",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	playsgco2:
		TNT1 A 8 A_StartSound("weapons/huntrackdown",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	flash:
		SHTF B 1 bright{
			A_Light2();
			HDFlashAlpha(-32);
		}
		TNT1 A 1 A_ZoomRecoil(0.9);
		TNT1 A 0 A_Light0();
		TNT1 A 0 A_AlertMonsters();
		stop;
	altreload:
	reloadfrompockets:
		SHTG A 0{
			if(!countinv("HDShellAmmo"))setweaponstate("nope");
			else invoker.weaponstatus[0]|=KHLEBF_FROMPOCKETS;
		}goto startreload;
	reload:
	reloadfromsidesaddles:
		SHTG A 0{
			int sss=invoker.weaponstatus[SHOTS_SIDESADDLE];
			int ppp=countinv("HDShellAmmo");
			if(ppp<1&&sss<1)setweaponstate("nope");
				else if(sss<1)
					invoker.weaponstatus[0]|=KHLEBF_FROMPOCKETS;
				else invoker.weaponstatus[0]&=~KHLEBF_FROMPOCKETS;
		}goto startreload;
	startreload:
		SHTG A 1{
			if(
				invoker.weaponstatus[KHLEBS_TUBE]>=invoker.weaponstatus[KHLEBS_TUBESIZE]
			){
				if(
					invoker.weaponstatus[SHOTS_SIDESADDLE]<12
					&&countinv("HDShellAmmo")
				)setweaponstate("ReloadSS");
				else setweaponstate("nope");
			}
		}
		SHTG AB 4 A_MuzzleClimb(frandom(.6,.7),-frandom(.6,.7));
	reloadstarthand:
		SHTG C 1 offset(0,36);
		SHTG C 1 offset(0,38);
		SHTG C 2 offset(0,36);
		SHTG C 2 offset(0,34);
		SHTG C 3 offset(0,36);
		SHTG C 3 offset(0,40) A_CheckPocketSaddles();
		SHTG C 0 A_JumpIf(invoker.weaponstatus[0]&KHLEBF_FROMPOCKETS,"reloadpocket");
	reloadfast:
		SHTG C 4 offset(0,40) A_GrabShells(3,false);
		SHTG C 3 offset(0,42) A_StartSound("weapons/pocket",9,volume:0.4);
		SHTG C 3 offset(0,41);
		goto reloadashell;
	reloadpocket:
		SHTG C 4 offset(0,39) A_GrabShells(3,false);
		SHTG C 6 offset(0,40) A_JumpIf(health>40,1);
		SHTG C 4 offset(0,40) A_StartSound("weapons/pocket",9);
		SHTG C 8 offset(0,42) A_StartSound("weapons/pocket",9);
		SHTG C 6 offset(0,41) A_StartSound("weapons/pocket",9);
		SHTG C 6 offset(0,40);
		goto reloadashell;
	reloadashell:
		SHTG C 2 offset(0,36);
		SHTG C 4 offset(0,34)A_LoadTubeFromHand();
		SHTG CCCCCC 1 offset(0,33){
			if(
				PressingReload()
				||PressingAltReload()
				||PressingUnload()
				||PressingFire()
				||PressingAltfire()
				||PressingZoom()
				||PressingFiremode()
			)invoker.weaponstatus[0]|=KHLEBF_HOLDING;
			else invoker.weaponstatus[0]&=~KHLEBF_HOLDING;

			if(
				invoker.weaponstatus[KHLEBS_TUBE]>=invoker.weaponstatus[KHLEBS_TUBESIZE]
				||(
					invoker.handshells<1&&(
						invoker.weaponstatus[0]&KHLEBF_FROMPOCKETS
						||invoker.weaponstatus[SHOTS_SIDESADDLE]<1
					)&&
					!countinv("HDShellAmmo")
				)
			)setweaponstate("reloadend");
			else if(
				!pressingaltreload()
				&&!pressingreload()
			)setweaponstate("reloadend");
			else if(invoker.handshells<1)setweaponstate("reloadstarthand");
		}goto reloadashell;
	reloadend:
		SHTG C 4 offset(0,34) A_StartSound("weapons/huntopen",8);
		SHTG C 1 offset(0,36) EmptyHand(careful:true);
		SHTG C 1 offset(0,34);
		SHTG CBA 3;
		SHTG A 0 A_JumpIf(invoker.weaponstatus[0]&KHLEBF_HOLDING,"nope");
		goto ready;

	cannibalize:
		SHTG A 2 offset(0,36) A_JumpIf(!countinv("Slayer"),"nope");
		SHTG A 2 offset(0,40) A_StartSound("weapons/pocket",9);
		SHTG A 6 offset(0,42);
		SHTG A 4 offset(0,44);
		SHTG A 6 offset(0,42);
		SHTG A 2 offset (0,36) A_CannibalizeOtherShotgun();
		goto ready;

	unloadSS:
		SHTG A 2 offset(1,34) A_JumpIf(invoker.weaponstatus[SHOTS_SIDESADDLE]<1,"nope");
		SHTG A 1 offset(2,34);
		SHTG A 1 offset(3,36);
	unloadSSLoop1:
		SHTG A 4 offset(4,36);
		SHTG A 2 offset(5,37) A_UnloadSideSaddle();
		SHTG A 3 offset(4,36){	//decide whether to loop
			if(
				PressingReload()
				||PressingFire()
				||PressingAltfire()
				||invoker.weaponstatus[SHOTS_SIDESADDLE]<1
			)setweaponstate("unloadSSend");
		}goto unloadSSLoop1;
	unloadSSend:
		SHTG A 3 offset(4,35);
		SHTG A 2 offset(3,35);
		SHTG A 1 offset(2,34);
		SHTG A 1 offset(1,34);
		goto nope;
	unload:
		SHTG A 1{
			if(
				invoker.weaponstatus[SHOTS_SIDESADDLE]>0
				&&!(player.cmd.buttons&BT_USE)
			)setweaponstate("unloadSS");
			else if(
				invoker.weaponstatus[KHLEBS_CHAMBER]<1
				&&invoker.weaponstatus[KHLEBS_TUBE]<1
			)setweaponstate("nope");
		}
		SHTG BC 4 A_MuzzleClimb(frandom(1.2,2.4),-frandom(1.2,2.4));
		SHTG C 1 offset(0,34);
		SHTG C 1 offset(0,36) A_StartSound("weapons/huntopen",8);
		SHTG C 1 offset(0,38);
		SHTG C 4 offset(0,36){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			if(invoker.weaponstatus[KHLEBS_CHAMBER]<1){
				setweaponstate("unloadtube");
			}else A_StartSound("weapons/huntrack",8,CHANF_OVERLAP);
		}
		SHTG D 8 offset(0,34){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			int chm=invoker.weaponstatus[KHLEBS_CHAMBER];
			invoker.weaponstatus[KHLEBS_CHAMBER]=0;
			if(chm>1){
				A_StartSound("weapons/huntreload",8);
				if(A_JumpIfInventory("HDShellAmmo",0,"null"))A_SpawnItemEx("HDFumblingShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*5,
					vel.y+cos(pitch)*sin(angle-random(86,90))*5,
					vel.z+sin(pitch)*random(4,6),
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);else{
					HDF.Give(self,"HDShellAmmo",1);
					A_StartSound("weapons/pocket",9);
					A_SetTics(5);
				}
			}else if(chm>0)A_SpawnItemEx("HDSpentShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
		SHTG C 0 A_JumpIf(!pressingunload(),"reloadend");
		SHTG C 4 offset(0,40);
	unloadtube:
		SHTG C 6 offset(0,40) EmptyHand(careful:true);
	unloadloop:
		SHTG C 8 offset(1,41){
			if(invoker.weaponstatus[KHLEBS_TUBE]<1)setweaponstate("reloadend");
			else if(invoker.handshells>=3)setweaponstate("unloadloopend");
			else{
				invoker.handshells++;
				invoker.weaponstatus[KHLEBS_TUBE]--;
			}
		}
		SHTG C 4 offset(0,40) A_StartSound("weapons/huntreload",8);
		loop;
	unloadloopend:
		SHTG C 6 offset(1,41);
		SHTG C 3 offset(1,42){
			int rmm=HDPickup.MaxGive(self,"HDShellAmmo",ENC_SHELL);
			if(rmm>0){
				A_StartSound("weapons/pocket",9);
				A_SetTics(8);
				HDF.Give(self,"HDShellAmmo",min(rmm,invoker.handshells));
				invoker.handshells=max(invoker.handshells-rmm,0);
			}
		}
		SHTG C 0 EmptyHand(careful:true);
		SHTG C 6 A_Jumpif(!pressingunload(),"reloadend");
		goto unloadloop;
	spawn:
		HUNT ABCDEFG -1 nodelay{
			int ssh=invoker.weaponstatus[SHOTS_SIDESADDLE];
			if(ssh>=11)frame=0;
			else if(ssh>=9)frame=1;
			else if(ssh>=7)frame=2;
			else if(ssh>=5)frame=3;
			else if(ssh>=3)frame=4;
			else if(ssh>=1)frame=5;
			else frame=6;
		}
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[KHLEBS_CHAMBER]=2;
		if(!idfa){
			weaponstatus[KHLEBS_TUBESIZE]=3;
			weaponstatus[KHLEBS_CHOKE]=0;
		}
		weaponstatus[KHLEBS_TUBE]=weaponstatus[KHLEBS_TUBESIZE];
		weaponstatus[SHOTS_SIDESADDLE]=12;
		handshells=0;
	}
	override void loadoutconfigure(string input){
	}
}
enum hunterstatus{
	KHLEBF_JAMMED=2,
	KHLEBF_UNLOADONLY=4,
	KHLEBF_FROMPOCKETS=8,
	KHLEBF_ALTHOLDING=16,
	KHLEBF_HOLDING=1,

	KHLEBS_FIREMODE=1,
	KHLEBS_CHAMBER=2,
	//3 is for side saddles
	KHLEBS_TUBE=4,
	KHLEBS_TUBESIZE=5,
	KHLEBS_HAND=6,
	KHLEBS_CHOKE=7,
};
/*

class HunterRandom:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let ggg=Hunter(spawn("Hunter",pos,ALLOW_REPLACE));
			if(!ggg)return;
			HDF.TransferSpecials(self,ggg,HDF.TS_ALL);

			if(!random(0,7))ggg.weaponstatus[KHLEBS_CHOKE]=random(0,7);
			if(!random(0,32)){

			}
		}stop;
	}
}


*/