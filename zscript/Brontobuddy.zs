// ------------------------------------------------------------
// Bronto buddy
// ------------------------------------------------------------
const RILD_BB="BRR";


class RIBrontoBuddy:Brontornis{

	default{
		+hdweapon.fitsinbackpack
		weapon.selectionorder 61;
		scale 0.6;
		inventory.pickupmessage "You got the Brontornis! It's got a neat bolt rack!";
		hdweapon.barrelsize 24,1,3;
		tag "Brontornis Cannon W/Bolt Rack";
		hdweapon.refid RILD_BB;
	}
	action void A_UnloadSideSaddle(int slot){
		int uamt=clamp(invoker.weaponstatus[slot],0,1);
		if(!uamt)return;
		invoker.weaponstatus[slot]-=uamt;
		int maxpocket=min(uamt,HDPickup.MaxGive(self,"BrontornisRound",ENC_BRONTOSHELL));
		if(maxpocket>0&&pressingunload()){
			A_SetTics(16);
			uamt-=maxpocket;
			A_GiveInventory("BrontornisRound",maxpocket);
		}
		A_StartSound("weapons/pocket");
		EmptyHand(uamt);
	}
	action void A_CannibalizeOtherShotgun(){
		let zzz=hdweapon(findinventory("RIBrontoBuddy"));
		if(zzz){
			int totake=min(
				zzz.weaponstatus[BRONS_SIDESADDLE],
				HDPickup.MaxGive(self,"BrontornisRound",ENC_BRONTOSHELL),
				4
			);
			if(totake>0){
				zzz.weaponstatus[BRONS_SIDESADDLE]-=totake;
				A_GiveInventory("BrontornisRound",totake);
			}
		}
	}
	override double gunmass(){
		double amt=weaponstatus[BRONS_CHAMBER];
		return 6+amt*amt+(weaponstatus[BRONS_SIDESADDLE]*0.12);
	}
	override double weaponbulk(){
		return 75+((weaponstatus[BRONS_CHAMBER]>1?ENC_BRONTOSHELLLOADED:0)+2+(weaponstatus[BRONS_SIDESADDLE]*ENC_BRONTOSHELL));
	}

	override string,double getpickupsprite(){
		int ssh=weaponstatus[BRONS_SIDESADDLE];
		if(ssh==0)return "BLBRA0",1.;
		if(ssh==1)return "BLBRB0",1.;
		if(ssh==2)return "BLBRC0",1.;
		if(ssh==3)return "BLBRD0",1.;
		return "BLBRD0",1.;	
	}

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("BROCA0",(-48,-10),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.7,0.7));
			sb.drawnum(hpl.countinv("BrontornisRound"),-45,-8,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_BLACK);
		}
		if(hdw.weaponstatus[BRONS_CHAMBER]>1)sb.drawwepdot(-16,-10,(5,3));
		sb.drawwepnum(
			hpl.countinv("BrontornisRound"),
			(50/ENC_BRONTOSHELL)
		);
		for(int i=hdw.weaponstatus[BRONS_SIDESADDLE];i>0;i--){
			sb.drawwepdot(-8-i*8,-2,(6,3));
			sb.drawwepdot(-9-i*8,-3,(6,1));
		}
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.." or "..WEPHELP_FIREMODE.."  Toggle zoom\n"
		..WEPHELP_RELOAD.."  Reload From Rack First\n"
		..WEPHELP_ALTRELOAD.."  Reload From Pockets\n"
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void failedpickupunload(){
		int sss=weaponstatus[BRONS_SIDESADDLE];
		if(sss<1)return;
		A_StartSound("weapons/pocket",5);
		int dropamt=min(sss,1);
		A_DropItem("BrontornisRound",dropamt);
		weaponstatus[BRONS_SIDESADDLE]-=dropamt;
		setstatelabel("spawn");
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("BrontornisRound",1);
	}
	states{
	select0:
		BLSG A 0;
		goto select0small;
	deselect0:
		BLSG A 0;
		goto deselect0small;
	ready:
		BLSG A 0 A_JumpIf(pressingunload()&&(pressinguse()||pressingzoom()),"cannibalize");
		BLSG A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	altfire:
	firemode:
		BLSG A 1 offset(0,34);
		BLSG A 1 offset(0,36);
		BLSG A 2 offset(2,37){invoker.weaponstatus[0]^=BRONF_ZOOM;}
		BLSG A 1 offset(1,36);
		BLSG A 1 offset(0,34);
		goto nope;
	fire:
		BLSG A 1 offset(0,34){
			if(invoker.weaponstatus[BRONS_CHAMBER]<2){
				setweaponstate("nope");
				return;
			}
			A_GunFlash();
			A_StartSound("weapons/bronto",CHAN_WEAPON);
			A_StartSound("weapons/bronto",6);
			A_StartSound("weapons/bronto2",7);
			let tb=HDBulletActor.FireBullet(
				self,"HDB_bronto",
				aimoffy:(invoker.weaponstatus[0]&BRONF_ZOOM)?-2:0
			);
			invoker.weaponstatus[BRONS_CHAMBER]=1;
			invoker.weaponstatus[BRONS_HEAT]+=32;
		}
		BLSG B 2;
		goto nope;
	flash:
		BLSF A 1 bright{
			HDFlashAlpha(0,true);
			A_Light1();
		}
		TNT1 A 2{
			A_ZoomRecoil(0.5);
			A_Light0();
		}
		TNT1 A 0{
			int recoilside=randompick(-1,1);
			if(gunbraced()){
				A_GiveInventory("IsMoving",2);
				hdplayerpawn(self).gunbraced=false;
				A_ChangeVelocity(
					cos(pitch)*-frandom(0.8,1.4),0,
					sin(pitch)*frandom(0.8,1.4),
					CVF_RELATIVE
				);
				A_MuzzleClimb(
					recoilside*5,-frandom(3.,5.),
					recoilside*5,-frandom(3.,5.)
				);
			}else{
				A_ChangeVelocity(
					cos(pitch)*-frandom(1.8,3.2),0,
					sin(pitch)*frandom(1.8,3.2),
					CVF_RELATIVE
				);
				A_GiveInventory("IsMoving",7);
				A_MuzzleClimb(
					recoilside*5,-frandom(5.,13.),
					recoilside*5,-frandom(5.,13.)
				);
				A_MuzzleClimb(
					recoilside*5,-frandom(5.,13.),
					recoilside*5,-frandom(5.,13.),
					wepdot:true
				);
			}
			if(!binvulnerable
				&&(
					countinv("IsMoving")>6
					||floorz<pos.z
				)
			){
				givebody(max(0,11-health));
				damagemobj(invoker,self,10,"bashing");
				A_GiveInventory("IsMoving",5);
				A_ChangeVelocity(
					cos(pitch)*-frandom(2,4),0,sin(pitch)*frandom(2,4),
					CVF_RELATIVE
				);
			}
		}
		stop;
		altreload:
	reloadfrompockets:
		BLSG A 0{
			int ppp=countinv("BrontornisRound");
			if(ppp<1)setweaponstate("nope");
				else if(ppp<1)
					invoker.weaponstatus[0]|=BRONF_FROMPOCKETS;
				else invoker.weaponstatus[0]&=~BRONF_FROMPOCKETS;
		}goto startreload;
	reload:
	reloadfromsidesaddles:
		BLSG A 0{
			int sss=invoker.weaponstatus[BRONS_SIDESADDLE];
			int ppp=countinv("BrontornisRound");
			if(ppp<1&&sss<1)setweaponstate("nope");
				else if(sss<1)
					invoker.weaponstatus[0]&=~BRONF_FROMPOCKETS;
				else invoker.weaponstatus[0]|=BRONF_FROMPOCKETS;
		}goto startreload;
	startreload:
		BLSG A 0{
			invoker.weaponstatus[0]&=~BRONF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[BRONS_CHAMBER]>1
				){
				if(
					invoker.weaponstatus[BRONS_SIDESADDLE]<3
					&&countinv("BrontornisRound")
				)setweaponstate("reloadSS");
				else setweaponstate("nope");
			}
		}goto unloadstart;
	reloadSS:
		BLSG A 1 offset(1,34);
		BLSG A 2 offset(2,34);
		BLSG A 3 offset(3,36);
	reloadSSrestart:
		BLSG A 6 offset(3,35);
		BLSG A 9 offset(4,34);
		BLSG A 4 offset(3,34){
			int hnd=1;
			if(invoker.weaponstatus[BRONS_SIDESADDLE]>2)setweaponstate("reloadSSend");
			else{
				A_TakeInventory("BrontornisRound",hnd);
				invoker.weaponstatus[BRONS_SIDESADDLE]+=hnd;
				A_StartSound("weapons/pocket",CHAN_WEAPON);
			}
		}
		BLSG A 0 {
			if(
				!PressingReload()
				&&!PressingAltReload()
			)setweaponstate("reloadSSend");
			else if(
				invoker.weaponstatus[BRONS_SIDESADDLE]<3
				&&countinv("BrontornisRound")
			)setweaponstate("ReloadSSrestart");
		}
	reloadSSend:
		BLSG A 3 offset(2,34);
		BLSG A 1 offset(1,34);
		goto nope;


	unloadSS:
		BLSG A 2 offset(1,34) A_JumpIf(invoker.weaponstatus[BRONS_SIDESADDLE]<1,"nope");
		BLSG A 1 offset(2,34);
		BLSG A 1 offset(3,36);
	unloadSSLoop1:
		BLSG A 4 offset(4,36);
		BLSG A 2 offset(5,37) A_UnloadSideSaddle(BRONS_SIDESADDLE);
		BLSG A 3 offset(4,36){	//decide whether to loop
			if(
				PressingReload()
				||PressingFire()
				||PressingAltfire()
				||invoker.weaponstatus[BRONS_SIDESADDLE]<1
			)setweaponstate("unloadSSend");
		}goto unloadSSLoop1;
	unloadSSend:
		BLSG A 3 offset(4,35);
		BLSG A 2 offset(3,35);
		BLSG A 1 offset(2,34);
		BLSG A 1 offset(1,34);
		goto nope;
	
	unload:
		BLSG A 0{
			if(
				invoker.weaponstatus[BRONS_SIDESADDLE]>0
				&&!(player.cmd.buttons&BT_USE)
			)setweaponstate("unloadSS");
		}
		BLSG A 0{
			invoker.weaponstatus[0]|=BRONF_JUSTUNLOAD;
		}goto unloadstart;

	unloadstart:
		BLSG A 1;
		BLSG BBB 2 A_MuzzleClimb(
			-frandom(0.5,0.6),frandom(0.5,0.6),
			-frandom(0.5,0.6),frandom(0.5,0.6)
		);
		BLSG B 3 A_StartSound("weapons/brontunload",CHAN_WEAPON);
		BLSG BBBBBBBB 0{invoker.drainheat(BRONS_HEAT,12);}
		BLSG B 12 offset(0,34){
			int chm=invoker.weaponstatus[BRONS_CHAMBER];
			invoker.weaponstatus[BRONS_CHAMBER]=0;
			if(chm<1){
				A_SetTics(6);
				return;
			}

			A_StartSound("weapons/brontoload",CHAN_AUTO);
			if(chm>1){
				if(
					PressingUnload()
					&&!A_JumpIfInventory("BrontornisRound",0,"null")
				){
					A_SetTics(18);
					A_StartSound("weapons/pocket");
					A_GiveInventory("BrontornisRound");
				}
				else A_SpawnItemEx("BrontornisRound",
					cos(pitch)*2,0,height-10-sin(pitch)*2,
					vel.x,vel.y,vel.z-frandom(-1,1),
					random(-3,3),SXF_ABSOLUTEMOMENTUM|
					SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH|
					SXF_TRANSFERTRANSLATION
				);
			}else if(chm==1){
				A_SpawnItemEx("TerrorCasing",
					cos(pitch)*4,0,height-10-sin(pitch)*4,
					vel.x,vel.y,vel.z-frandom(-1,1),
					frandom(-1,1),SXF_ABSOLUTEMOMENTUM|
					SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH|
					SXF_TRANSFERTRANSLATION
				);
			}
		}
//		#### # 0 A_Log("reload shart",true);
		BLSG B 1 offset(0,36) A_JumpIf(invoker.weaponstatus[0]&BRONF_JUSTUNLOAD,"reloadend");
		BLSG B 1 offset(0,41) A_StartSound("weapons/pocket",CHAN_WEAPON);
		BLSG B 1 offset(0,38);
//		#### # 0 A_Log("farts",true);
		BLSG B 3 offset(0,36);
		BLSG B 3 offset(0,34);
		BLSG B 3 offset(0,35);
		BLSG B 0 offset(0,34) A_JumpIf(invoker.weaponstatus[BRONS_SIDESADDLE]>0&&invoker.weaponstatus[0]&BRONF_FROMPOCKETS,"reloadsaddle");
		BLSG B 4 offset(0,34){
			invoker.weaponstatus[BRONS_CHAMBER]=2;
			A_TakeInventory("BrontornisRound",1,TIF_NOTAKEINFINITE);
			A_StartSound("weapons/brontoload",CHAN_WEAPON);
		}
		BLSG B 6 offset(0,33);
		goto reloadend;
	reloadsaddle:
		BLSG B 4 offset(0,34){
			invoker.weaponstatus[BRONS_CHAMBER]=2;
			invoker.weaponstatus[BRONS_SIDESADDLE]--;
			A_StartSound("weapons/brontoload",CHAN_WEAPON);
		}
	reloadend:
		BLSG B 6 offset(0,34);
		BLSG B 2 offset(0,34) A_StartSound("weapons/brontunload",CHAN_WEAPON);
		BLSG B 1 offset(0,36);
		BLSG B 1 offset(0,34);
		BLSG BA 4;
		BLSG A 0 A_StartSound("weapons/brontoclose",CHAN_WEAPON);
		goto ready;

	cannibalize:
		BLSG A 2 offset(0,36) A_JumpIf(!countinv("RIBrontoBuddy"),"nope");
		BLSG A 2 offset(0,40) A_StartSound("weapons/pocket",CHAN_WEAPON);
		BLSG A 6 offset(0,42);
		BLSG A 4 offset(0,44);
		BLSG A 6 offset(0,42);
		BLSG A 2 offset (0,36) A_CannibalizeOtherShotgun();
		goto ready;

	spawn:
		BLBR A -1 nodelay{
			if(invoker.weaponstatus[BRONS_SIDESADDLE]==1){frame=1;
			}else if(invoker.weaponstatus[BRONS_SIDESADDLE]==2){frame=2;
			}else if(invoker.weaponstatus[BRONS_SIDESADDLE]==3){frame=3;
			}else if(invoker.weaponstatus[BRONS_SIDESADDLE]<1){frame=0;
			}
		}
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[BRONS_CHAMBER]=2;
		if(!idfa){
			weaponstatus[0]=0;
			weaponstatus[BRONS_HEAT]=0;
			weaponstatus[BRONS_SIDESADDLE]=3;
		}
	}
	override void loadoutconfigure(string input){
		int zoom=getloadoutvar(input,"zoom",1);
		if(!zoom)weaponstatus[0]&=~BRONF_ZOOM;
		else if(zoom>0)weaponstatus[0]|=BRONF_ZOOM;
	}
	int handshells;
	action void EmptyHand(int amt=-1,bool careful=false){
		if(!amt)return;
		if(amt>0)invoker.handshells=amt;
		while(invoker.handshells>0){
			if(careful&&!A_JumpIfInventory("BrontornisRound",0,"null")){
				invoker.handshells--;
				HDF.Give(self,"BrontornisRound",1);
 			}else{
				invoker.handshells--;
				A_SpawnItemEx("BrontornisRound",
					cos(pitch)*5,1,height-7-sin(pitch)*5,
					cos(pitch)*cos(angle)*frandom(1,4)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,4)+vel.y,
					-sin(pitch)*random(1,4)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}
	}
}
enum brontostatus{
	BRONF_ZOOM=1,
	BRONF_JUSTUNLOAD=2,
	BRONF_FROMPOCKETS=4,

	BRONS_STATUS=0,
	BRONS_CHAMBER=1,
	BRONS_HEAT=2,
	BRONS_SIDESADDLE=3,
};



//map pickup
class BrontoBSpawner:IdleDummy replaces BrontornisSpawner{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let lll=random(0,5);
			if(lll<=4){
			A_SpawnItemEx("BrontornisRound",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			A_SpawnItemEx("BrontornisRound",3,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			A_SpawnItemEx("BrontornisRound",1,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			A_SpawnItemEx("BrontornisRound",-3,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			A_SpawnItemEx("Brontornis",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			}else{
			A_SpawnItemEx("RIBrontoBuddy",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);				
			}
		}stop;
	}
}
