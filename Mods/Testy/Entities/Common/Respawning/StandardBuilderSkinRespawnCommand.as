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
	AddIconToken("$tree_class_icon$", "GUI/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$goblin_class_icon$", "/GUI/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$wizard_class_icon$", "/GUI/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$ggoblin_class_icon$", "/Gui/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$ninja_class_icon$", "/Gui/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$goldenman_class_icon$", "/Gui/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$migrant_class_icon$", "/Gui/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$bunny_class_icon$", "/GUI/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$penguin_class_icon$", "/GUI/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$pig_class_icon$", "/GUI/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$futurebunny_class_icon$", "/GUI/TreeIcon.png", Vec2f(32, 32), 8);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 11, 2);
	addPlayerClass(this, "Builder", "$builder_class_icon$", "builder", "Build ALL the towers.");
	addPlayerClass(this, "TreeDude", "$tree_class_icon$", "treedude", "The Tree dude.. Idk why hes here..");
	addPlayerClass(this, "Goblin", "$goblin_class_icon$", "goblin", "Hes a wild goblin, just a warning!");
	addPlayerClass(this, "Green Goblin", "$ggoblin_class_icon$", "ggoblin", "A green goblin? What now? a yellow one?!?");
	addPlayerClass(this, "Wizard", "$wizard_class_icon$", "wizard", "Hes a wizard alright!");
	addPlayerClass(this, "Ninja", "$ninja_class_icon$", "ninja", "Hes a dude with a stick.. which might be a sword");
	addPlayerClass(this, "Golden man", "$goldenman_class_icon$", "golden", "golden man, the dude who is pure gold");
	addPlayerClass(this, "Migrant", "$migrant_class_icon$", "migrantbuilder", "The migrant wanted some action, so he became a builder");
	addPlayerClass(this, "Bunny", "$bunny_class_icon$", "bunny", "A bunny wanted to become a builder, so it played minecraft");
	addPlayerClass(this, "Pig", "$pig_class_icon$", "pig", "A pig man.. for some reason..");
	addPlayerClass(this, "FutureBunny", "$futurebunny_class_icon$", "futurebunny", "The bunny went mad and invented time travel, so here it is!");
	addPlayerClass(this, "Penguin", "$penguin_class_icon$", "penguin", "The penguin got tired of being a starbound logo, so it went here to build!");
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(classes.length * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), "Swap class");
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
