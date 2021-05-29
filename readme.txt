Hideous Destructor, RightInfinity's Revolting Revolutionary Rweapons (..Nailed it)



Changes:

 v4.4.2a Release 2
  + Fixed GZDoom warnings.
  + Added more Reaper help text.
  + Fixed Reapers reloading wrong magazine types after ammo box refill.
  + Fixed purging useless ammo.

------------------
 v4.4.2a Release 1
  + Reapers jam Slight less again, Not sure what changed but they returned to jamming a ton.
  
  + Box magazines have been made more reliable, to make up for the lack of ammo

------------------
 v4.3.1 Release 1
  + Added the Reaper with underbarrel Zm66. Because I got inspired. Feedback, please. I'm genuinely intrested in hearing where this abomination is useful. Loadout code: RPZ
  
  + Reapers and thompsons can now be loaded with stick mags, a unique 8 round mag for the Reaper, and standard 30 round smg SMG for the Tommy. Press and hold firemode during reloading to swap mag types
  
  + Added a force-reload chord to reload full Thompsons and Reapers by pressing reload and firemode at the same time. Use for mag type swaps.
  + Reapers (except the ZM Reaper) can have optional glow sights. add "sights 1"  to the loadout code to get them
  + Reanimated/Recoded the Thomspon, with advice from the TheBadInfluence
  + Ammo-racked bronto now uses TEXTURES, _should_ be compatable with texturepacks

 v4.2.4 MASTER Release 1
 + Updated to 4.2.4 master
 + All guns now use the updated bullet types
 + Reapers now support chokes, Same loadout code as the other shotties (eg, RPR choke 7)
 + Slapped in my sidesaddle equipped Bronto. Intended for easy backpack storage and use. spawns occasionally in the place of regular brontos

 v1.7b
 +Uncommented the rando spawn code. D'oh
 v1.7
  +Updated for HD 4.1.3b-ish.
 +Split the reaperGL, Reaper regular  code so I can do something later
 +Fixed a sprite issue cocking the weapon while the drum is near empty
 +Alt fire now cocks the gun if you're using the GL-less reaper
 + fixed issue with wonky ground sprites with the reaper
 v1.6
 +replace that godawful cocking hand for something slightly less bad
 +Added a grenade chucking Reaper variant. Code RPG. Get excessive
 +Spawning! Tommys rarely show up where ammoboxes come up, Reapers of both types rarely in the place of shellboxes
 v1.5b
 +Fed my drums some weight watchers. Now balanced around the weight of a classic lib+drum awkwardness when loaded.
 v1.5
 +Added the edge with the Raycob's Reaper Automatic Shotgun
 +Quiented the fuck most of the sounds. My audio setup was fucked so I didn't know things sounded weird
 v1.4b
 +fixed the fugging alpha of the textures erasing sections of the mag while reloading
 v1.4
 +Implemented Mag Manager Sprites (Thanks Matt!)
 +Resprited the Tompson using TEXTURES
 v1.3
 +Replaced heresy bar with circle
 +Added in thompson's bolt hold open
 +Rejiggered the reload anims to comply with the tommy's actual drum loading method.
 v1.2
 +Replaced default SMG sounds with prototype sounds
 +Added in an almost inaudible metallic whirr of the clock spring unwinding on an empty mag
 v1.1
 +Added Recoil Frames

Please yell at me if my code offends. I'm pretty horrid and need the ruler over the knuckles to learn.

Raycob Reaper Automatic Shotgun
 -Loadout Code	RPR			(Regular)
 -Classname		RIreaper
 + Accepts both it's drum magazines and 8 round box mags.
 + Hold Firemode to exchange magazine types.
 + Press Reload + Firemode to force a reload with a full magazine.
 + Accepts the same 0-7 choke settings as the hunter and slayer
 + Has optional glow sights, probably useful as only decoration. use sights 0-1 in the loadout code

Reaper + Rocquette Grenade Launcher
 -Loadout Code	RPG
 -Classname		RIreaperGL
 + Got the boomer tuber underneath. Spoldes reel gud

Reaper + ZM66C Underbarrel
 -Loadout Code	RPZ
 -Classname 	RIreaperZM
 + Hit Alt fire to swap gun you're using
 + Altreload Reloads the ZM at all times, and clears jams that happen
 + Unload is context senstive and will prioritize the selected gun first
 
Brontoris Cannon W/Bolt Rack
 -Loadout Code	BRR
 -Classname		RIBrontoBuddy
 + Standard bronto that has a shotgun-like sidesaddle on the side.
 + Due to the shell weight and bulk, does not speed up reload, and is primarly meant for soldiers who use a bronto in a tertiary role, and would love to save some bulk in their backpack or pockets
 
Reaper 12 Gauge Drum
 -Loadout Code	RDM
 -Classname		RIReapD20

Reaper 12 Gauge Magazine
 -Loadout code 	RSM
 -Classname		RIReapM8

Thompson m1921/28 (-ish) 9x21mm Repro
 -Loadout Code 	TMP
 -Classname		RIThompson
 + Accepts both it's drum magazines and regular 9mm SMG mags.
 + Hold Firemode to exchange magazine types.
 + Press Reload + Firemode to force a reload with a full magazine.
 
Thompson Drum magazine
 -Loadout code 	TDM
 -Classname 	RITmpsD70

Known issues:
	-Reaper ZM does not Cookoff on ground, because I haven't provideded the pile of sprites needed yet.

Spriting credits:
Tommy gun sprites by YukesVonFaust
Captain J for the ppsh drum sprite I edited into a Thompson reload sprite + His USAS 12 sprites that blat good
Potetobloke For the reaper drum base sprite


Thanks to:
TheBadInfluence for doing better research than I could on the nitty gritty Thompson functions
LtSnowolf for being best battle bud and pointing me at BF:BC2.
Matt, for having code I can abuse and glue together into something new.
Breezwagon
Potetobloke for pointing out I forgot something.
Some bloke on FPSBanana for ripping the BC2 sounds.

TODO:
	-Bullet visible in reload anim

		