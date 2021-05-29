class RRRRWeaponsHandler:EventHandler
{
	override void WorldThingSpawned(WorldEvent e)
	{
		let RRRRammo = HDAmmo(e.Thing);
		if (RRRRammo)
		{
			switch (RRRRammo.GetClassName())
			{
				case 'FourMilAmmo':
					RRRRammo.ItemsThatUseThis.Push("RIReaperZM");
					break;
				case 'HD4mMag':
					RRRRammo.ItemsThatUseThis.Push("RIReaperZM");
					break;
				case 'HD9mMag30':
					RRRRammo.ItemsThatUseThis.Push("RIThompson");
					break;
				case 'HDPistolAmmo':
					RRRRammo.ItemsThatUseThis.Push("RIThompson");
					break;
				case 'UaS_9mmBox':
					RRRRammo.ItemsThatUseThis.Push("RIThompson");
					break;
				case 'HDShellAmmo':
					RRRRammo.ItemsThatUseThis.Push("RIReaper");
					RRRRammo.ItemsThatUseThis.Push("RIReaperGL");
					RRRRammo.ItemsThatUseThis.Push("RIReaperZM");
					break;
				case 'UaS_ShellBox':
					RRRRammo.ItemsThatUseThis.Push("RIReaper");
					RRRRammo.ItemsThatUseThis.Push("RIReaperGL");
					RRRRammo.ItemsThatUseThis.Push("RIReaperZM");
					break;
				case 'HDRocketAmmo':
					RRRRammo.ItemsThatUseThis.Push("RIReaperGL");
					break;
				case 'BrontornisRound':
					RRRRammo.ItemsThatUseThis.Push("RIBrontoBuddy");
					break;
			}
		}
	}
}
