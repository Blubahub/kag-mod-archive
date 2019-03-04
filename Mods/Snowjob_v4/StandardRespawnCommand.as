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
	AddIconToken("$builder_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 8);
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);
	AddIconToken("$shieldman_icon$", "ShieldmanIcon.png", Vec2f(32, 32), 0);
	AddIconToken("$swapper_icon$", "SwapperIcon.png", Vec2f(32, 32), 0);
	AddIconToken("$grappleknight_icon$", "GrappleKnightIcon.png", Vec2f(32, 32), 1);
	AddIconToken("$twister_icon$", "TwisterIcon.png", Vec2f(32, 32), 0);
	AddIconToken("$ranger_icon$", "RangerIcon.png", Vec2f(32, 32), 0);
	AddIconToken("$grabber_icon$", "GrabberIcon.png", Vec2f(32, 32), 0);
	AddIconToken("$waterdeity_icon$", "WaterDeityIcon.png", Vec2f(32, 32), 0);
	
	addPlayerClass(this, "Builder", "$builder_class_icon$", "builder", "Build ALL the towers.");
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
	addPlayerClass(this, "Great Shield Knight", "$shieldman_icon$", "shieldman", "Shielded Defender");
	addPlayerClass(this, "Swapper", "$swapper_icon$", "swapper", "Linked spacial manipulator");
	addPlayerClass(this, "Grapple Knight", "$grappleknight_icon$", "grappleknight", "Grapple and stab");
	addPlayerClass(this, "Twister", "$twister_icon$", "twister", "Spin to win");
	addPlayerClass(this, "Ranger", "$ranger_icon$", "ranger", "Shoot n stab");
	addPlayerClass(this, "Grabber", "$grabber_icon$", "grabber", "Smash and grab");
	addPlayerClass(this, "Water Deity", "$waterdeity_icon$", "waterdeity", "Spray and Pray");
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f - 96.0f), this, Vec2f(3 * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), "Normal Classes");
		if (menu !is null)
		{
			addClassesToMenuNormal(this, menu, caller.getNetworkID());
		}
		CGridMenu@ menu1 = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f((classes.length-3) * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), "Unique Classes");
		if (menu1 !is null)
		{
			addClassesToMenuUnique(this, menu1, caller.getNetworkID());
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
