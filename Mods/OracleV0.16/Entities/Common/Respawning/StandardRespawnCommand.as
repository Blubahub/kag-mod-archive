// REQUIRES:
//
//      onRespawnCommand() to be called in onCommand()
//
//  implementation of:
//
//      bool canChangeClass( CBlob@ this, CBlob @caller )
//
// Tag: "change class sack inventory" - if you want players to have previous items stored in sack on class change
// Tag: "change class store inventory" - if you want players to store previous items in this respawn blob



#include "ClassSelectMenu.as"

void InitRespawnCommand(CBlob@ this)
{
	this.addCommandID("class menu");
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius() * 2.0f + caller.getRadius());
}

bool canChangeClass(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}

// default classes
void InitClasses(CBlob@ this)
{
  AddIconToken("$links$", "LinkMale.png", Vec2f(32, 32), 0);
  AddIconToken("$rams$", "RamMale.png", Vec2f(32, 32), 0);
  AddIconToken("$slimes$", "SlimeMale.png", Vec2f(32, 32), 0);
  AddIconToken("$foxs$", "FoxMale.png", Vec2f(32, 32), 0);
  AddIconToken("$ralphs$", "RalphMale.png", Vec2f(32, 32), 0);
  AddIconToken("$octorocks$", "OctorockMale.png", Vec2f(32, 32), 0);
  AddIconToken("$wizrobes$", "WizrobeMale.png", Vec2f(32, 32), 0);
  AddIconToken("$cactuss$", "CactusMale.png", Vec2f(32, 32), 0);
  AddIconToken("$snakes$", "SnakeMale.png", Vec2f(32, 32), 0);
  AddIconToken("$windbirds$", "WindBirdMale.png", Vec2f(32, 32), 0);
  AddIconToken("$marins$", "MarinMale.png", Vec2f(32, 32), 0);
  AddIconToken("$pigs$", "PigMale.png", Vec2f(32, 32), 0);
  AddIconToken("$dins$", "DinMale.png", Vec2f(32, 32), 0);
  AddIconToken("$tarins$", "TarinMale.png", Vec2f(32, 32), 0);
  AddIconToken("$elders$", "ElderMale.png", Vec2f(32, 32), 0);
  AddIconToken("$vasus$", "VasuMale.png", Vec2f(32, 32), 0);
  AddIconToken("$blainos$", "BlainoMale.png", Vec2f(32, 32), 0);
  AddIconToken("$gorons$", "GoronMale.png", Vec2f(32, 32), 0);
  AddIconToken("$windmills$", "WindmillMale.png", Vec2f(32, 32), 0);
  AddIconToken("$zoras$", "ZoraMale.png", Vec2f(32, 32), 0);
  AddIconToken("$lynels$", "LynelMale.png", Vec2f(32, 32), 0);
  AddIconToken("$moblins$", "MoblinMale.png", Vec2f(32, 32), 0);
  AddIconToken("$ghosts$", "GhostMale.png", Vec2f(32, 32), 0);
  AddIconToken("$nayrus$", "NayruMale.png", Vec2f(32, 32), 0);
  AddIconToken("$fairys$", "FairyMale.png", Vec2f(32, 32), 0);
  AddIconToken("$darknuts$", "DarknutMale.png", Vec2f(32, 32), 0);
  
  //DPS
  addPlayerClass(this, "Fox", "$foxs$", "fox", "Quick, but fragile, doesn't collide with enemies\n[LMB] Strike",1);
  addPlayerClass(this, "Octorock", "$octorocks$", "octorock", "Machine gun with 4 legs\n[LMB] Throw rock",1);
  addPlayerClass(this, "Ralph", "$ralphs$", "ralph", "A long range fragile sniper\n[LMB] Shoot",1);
  addPlayerClass(this, "Cactus", "$cactuss$", "cactus", "Slow and steady, can build up 3 charges of shots\n[LMB] Shoot",1);
  addPlayerClass(this, "Tarin", "$tarins$", "tarin", "Magical man with magical powers\n[RMB] Morph\n[LMB] Throw magic power",1);
  addPlayerClass(this, "Blaino", "$blainos$", "blaino", "A sturdy and stubborn wrestler that can deflect projectiles\n[RMB] Deflect\n[LMB] Punch",1);
  addPlayerClass(this, "Lynel", "$lynels$", "lynel", "A quick centaur that has a steady dash\n[RMB] Charge dash\n[LMB] Stab",1);
  addPlayerClass(this, "Darknut", "$darknuts$", "darknut", "A mysterious lonely knight, a ruthless killer\n[RMB] Throw bat/teleport to bat\n[LMB] Slash",1);
  
  //Tank
  addPlayerClass(this, "Link", "$links$", "link", "Tank with a hefty shield\n[RMB] Shield\n[LMB] Slash",2);
	addPlayerClass(this, "Ram", "$rams$", "ram", "A creature with a bulk shell\n[LMB with Shell] Ram\n[LMB without Shell] Throw rock",2);
	addPlayerClass(this, "Slime", "$slimes$", "slime", "Slimey, disgusting, but powerful\n[RMB] Ram\n[LMB] Slime trap (slows enemies)",2);
	addPlayerClass(this, "Pig", "$pigs$", "pig", "Touch but slow, pulls people in an peppers them with his massive shotgun\n[RMB] Pull\n[LMB] Shotgun",2);
  addPlayerClass(this, "Goron", "$gorons$", "goron", "Tough mountainous goron, stuns with his pots\n[RMB] Spin to win\n[LMB] Throw pot",2);
  addPlayerClass(this, "Moblin", "$moblins$", "moblin", "A ruthless Moblin, has a large compound crossbow\n[RMB] Triple crossbow\n[LMB] Slash",2);
  
  //Support
	addPlayerClass(this, "Snake", "$snakes$", "snake", "Fast, heals teammates and poisons enemies\n[LMB] Shoot",3);
	addPlayerClass(this, "Wind Bird", "$windbirds$", "windbird", "A magical bird, can resurect allies\n[RMB] Drop Res skeleton\n[LMB] Push",3);
	addPlayerClass(this, "Marin", "$marins$", "marin", "Slow and graceful, sings to heal\n[RMB] Sing\n[LMB] Blow away",3);
	addPlayerClass(this, "Windmill", "$windmills$", "windmill", "Mysterious man with healing windmills\n[RMB] Drop Windmill\n[LMB] Crank",3);
	addPlayerClass(this, "Ghost", "$ghosts$", "ghost", "A wandering soul that turns others invisble to do the dirty work for him\n[RMB] Cloak Aura\n[LMB] Life Steal",3);
	addPlayerClass(this, "Nayru", "$nayrus$", "nayru", "A harpist who uses the power of music to hurt and harm\n[RMB] Drop Healing harp\n[LMB] Strum",3);
	addPlayerClass(this, "Fairy", "$fairys$", "fairy", "A powerful fairy that harvests others and dishes them out to her teammates for a big heal\n[RMB] Give Fairy\n[LMB] Ignite",3);
  
  //Specialist
	addPlayerClass(this, "Wizrobe", "$wizrobes$", "wizrobe", "Weak but mobile and annoying\n[RMB] Teleport\n[LMB] Blast",4);
	addPlayerClass(this, "Din", "$dins$", "din", "Graceful and kind, danced to speed up allies\n[RMB] Dance\n[LMB] Tornado launch",4);
	addPlayerClass(this, "Elder", "$elders$", "elder", "Slow but helpful, can make portals to get allies out of trouble\n[RMB] Create portal\n[LMB] Splash area",4);
	addPlayerClass(this, "Vasu", "$vasus$", "vasu", "Mysterious snake charmer that has all kinds of snakes for the job\n[RMB] Damaging Snake\n[LMB] Throw Keys",4);
	addPlayerClass(this, "Zora", "$zoras$", "zora", "A skilled killer, searching for his old father\n[RMB] Invisibility\n[LMB] Shell shot",4);
	
	
	
}



void BuildRespawnMenuFor(CBlob@ this, CBlob @caller, int men = 0)
{
	LinkPlayerClass[]@ classes;
	this.get("LinkPlayerClasses" + getTypeFromInt(men), @classes);
	
	

	if (caller !is null && caller.isMyPlayer() )
	{
		if(men == 0) {
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(4 * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), "Swap class");
			if (menu !is null)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				CGridButton@ button = menu.AddButton("", "DPS", LinkSpawnCmd::buildDPSMenu, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
				
				CBitStream params2;
				params2.write_u16(caller.getNetworkID());
				CGridButton@ button2 = menu.AddButton("", "Tank", LinkSpawnCmd::buildTankMenu, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params2);
        
        CBitStream params3;
				params3.write_u16(caller.getNetworkID());
				CGridButton@ button3 = menu.AddButton("", "Support", LinkSpawnCmd::buildSupportMenu, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params3);
        
        CBitStream params4;
				params4.write_u16(caller.getNetworkID());
				CGridButton@ button4 = menu.AddButton("", "Specialist", LinkSpawnCmd::buildSpecialistMenu, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params4);
				
				
			}
		}
		else if(men > 0 && classes !is null) {
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(classes.length * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), "Swap class");
			if (menu !is null)
			{
				CPlayer@ p = caller.getPlayer();
				if(p !is null)
				{
					addClassesToMenu(this, menu, caller.getNetworkID(), p.getCoins(),men);
				}
			}			
		}
	}
}

void onRespawnCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	switch (cmd)
	{
		case LinkSpawnCmd::buildMenu:
		{
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller,0);
			}
		}
		break;
		case LinkSpawnCmd::buildDPSMenu:
		{
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller,1);
			}
		}
		break;
    case LinkSpawnCmd::buildTankMenu:
		{
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller,2);
			}
		}
		break;
		case LinkSpawnCmd::buildSupportMenu:
		{
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller,3);
			}
		}
		break;
    case LinkSpawnCmd::buildSpecialistMenu:
		{
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller,4);
			}
		}
		break;
		
		case LinkSpawnCmd::changeClass:
		{
			if (getNet().isServer())
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());

				if (caller !is null && canChangeClass(this, caller))
				{
					string classconfig = params.read_string();
					CBlob @newBlob = server_CreateBlob(classconfig, caller.getTeamNum(), this.getRespawnPosition());

					if (newBlob !is null)
					{
						// copy health and inventory
						// make sack
						CInventory @inv = caller.getInventory();

						if (inv !is null)
						{
							if (this.hasTag("change class drop inventory"))
							{
								while (inv.getItemsCount() > 0)
								{
									CBlob @item = inv.getItem(0);
									caller.server_PutOutInventory(item);
								}
							}
							else if (this.hasTag("change class store inventory"))
							{
								if (this.getInventory() !is null)
								{
									caller.MoveInventoryTo(this);
								}
								else // find a storage
								{
									PutInvInStorage(caller);
								}
							}
							else
							{
								// keep inventory if possible
								caller.MoveInventoryTo(newBlob);
							}
						}

						// set health to be same ratio
						float healthratio = caller.getHealth() / caller.getInitialHealth();
						newBlob.server_SetHealth(newBlob.getInitialHealth() * healthratio);

						//copy air
						if (caller.exists("air_count"))
						{
							newBlob.set_u8("air_count", caller.get_u8("air_count"));
							newBlob.Sync("air_count", true);
						}

						//copy stun
						if (caller.exists("knocked"))
						{
							newBlob.set_u8("knocked", caller.get_u8("knocked"));
							newBlob.Sync("knocked", true);
						}

						// plug the soul
						newBlob.server_SetPlayer(caller.getPlayer());
						newBlob.setPosition(caller.getPosition());

						// no extra immunity after class change
						if (caller.exists("spawn immunity time"))
						{
							newBlob.set_u32("spawn immunity time", caller.get_u32("spawn immunity time"));
							newBlob.Sync("spawn immunity time", true);
						}

						caller.Tag("switch class");
						caller.server_SetPlayer(null);
						caller.server_Die();
					}
				}
			}
		}
		break;
	}

	//params.SetBitIndex( index );
}

void PutInvInStorage(CBlob@ blob)
{
	CBlob@[] storages;
	if (getBlobsByTag("storage", @storages))
		for (uint step = 0; step < storages.length; ++step)
		{
			CBlob@ storage = storages[step];
			if (storage.getTeamNum() == blob.getTeamNum())
			{
				blob.MoveInventoryTo(storage);
				return;
			}
		}
}
