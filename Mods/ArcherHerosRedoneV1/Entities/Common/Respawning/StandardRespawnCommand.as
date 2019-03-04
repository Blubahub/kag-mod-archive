// This file controls choosing classes at tents and halls. Go to the initclasses script to add classes.

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
	AddIconToken("$builder_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 8); //These are class 'tokens'
  /*
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12); //Tokens are essentially pngs used in menus.
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);
  AddIconToken("$soldiers$", "GUI/MenuItems.png", Vec2f(32, 32), 38);
  AddIconToken("$turrets$", "GUI/MenuItems.png", Vec2f(32, 32), 40);
  AddIconToken("$shotguns$", "GUI/MenuItems.png", Vec2f(32, 32), 37);
  AddIconToken("$jetpacks$", "GUI/MenuItems.png", Vec2f(32, 32), 34);
  AddIconToken("$nades$", "GUI/MenuItems.png", Vec2f(32, 32), 35);
  AddIconToken("$engineers$", "GUI/MenuItems.png", Vec2f(32, 32), 32);
  AddIconToken("$tanks$", "GUI/MenuItems.png", Vec2f(32, 32), 39);
  AddIconToken("$snipers$", "GUI/MenuItems.png", Vec2f(32, 32), 41);
  AddIconToken("$revolvers$", "GUI/MenuItems.png", Vec2f(32, 32), 36);
  AddIconToken("$healers$", "GUI/MenuItems.png", Vec2f(32, 32), 33);
	AddIconToken("$change_class$", "GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
AddIconToken("$uzis$", "GUI/MenuItems.png", Vec2f(32, 32),  42);   
AddIconToken("$brutes$", "GUI/MenuItems.png", Vec2f(32, 32),  43);   
AddIconToken("$hunters$", "GUI/MenuItems.png", Vec2f(32, 32),  44);   
AddIconToken("$natives$", "GUI/MenuItems.png", Vec2f(32, 32),  45);   
	
	
	addPlayerClass(this, "Soldier", "$soldiers$", "soldier", "The most average person.");
  addPlayerClass(this, "Turret", "$turrets$", "turret", "bop");
  addPlayerClass(this, "Shotgun", "$shotguns$", "shotgun", "bop");
  addPlayerClass(this, "Jetpack", "$jetpacks$", "jetpack", "bop");
  addPlayerClass(this, "Nade", "$nades$", "nade", "bop");
  addPlayerClass(this, "Engineer", "$engineers$", "engineer", "bop");
  addPlayerClass(this, "Tank", "$tanks$", "tank", "bop");
	addPlayerClass(this, "Sniper", "$snipers$", "sniper", "360 no scoped."); 
  addPlayerClass(this, "Revolver", "$revolvers$", "revolver", "bop");
  addPlayerClass(this, "Healer", "$healers$", "healer", "bop");
  addPlayerClass(this, "Hunter", "$hunters$", "hunter", "bop");
  addPlayerClass(this, "Uzi", "$uzis$", "uzi", "bop");
  addPlayerClass(this, "Brute", "$brutes$", "brute", "bop");
  addPlayerClass(this, "Native", "$natives$", "native", "bop");
  */
  
  addPlayerClass(this, "Soldier", "$newsoldier$", "newsoldier", "The most average person.");
  //This is where I added template class. The first string is a pretty name for the menu. The second is the token name. The third is the actual name for your class/blob. The fifth is dumb.
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f((classes.length + 1) * CLASS_BUTTON_SIZE / 2, CLASS_BUTTON_SIZE * 2), "Swap class");
		if (menu !is null)
		{
			addClassesToMenu(this, menu, caller.getNetworkID());
		}
	}
}

void onRespawnCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	switch (cmd)
	{
		case SpawnCmd::buildMenu:
		{
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller);
			}
		}
		break;

		case SpawnCmd::changeClass:
		{
			if (getNet().isServer())
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());

				if (caller !is null && canChangeClass(this, caller))
				{
					string classconfig = params.read_string();
					CBlob @newBlob = server_CreateBlob(classconfig, caller.getTeamNum(), this.getRespawnPosition());
          
          ConfigFile top = ConfigFile();
        top.loadFile("../Cache/Profiles/Stats.cfg");
        int score = top.read_s32(classconfig + "played", 0);
        top.add_s32(classconfig + "played", score + 1);
      top.saveFile("Profiles/Stats.cfg");

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

						// plug the soul
						newBlob.server_SetPlayer(caller.getPlayer());
						newBlob.setPosition(caller.getPosition());

						// no extra immunity after class change
						if (caller.exists("spawn immunity time"))
						{
							newBlob.set_u32("spawn immunity time", caller.get_u32("spawn immunity time"));
							newBlob.Sync("spawn immunity time", true);
						}

						if (caller.exists("knocked"))
						{
							newBlob.set_u8("knocked", caller.get_u8("knocked"));
							newBlob.Sync("knocked", true);
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
