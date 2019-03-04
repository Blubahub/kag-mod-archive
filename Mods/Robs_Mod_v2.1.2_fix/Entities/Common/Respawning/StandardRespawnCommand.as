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
#include "CopyTatoos.as";

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
	AddIconToken("$builder_class_icon$", "ClassIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$knight_class_icon$", "ClassIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$archer_class_icon$", "ClassIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$sapper_class_icon$", "ClassIcons.png", Vec2f(32, 32), 6);
	AddIconToken("$ghoul_class_icon$", "ClassIcons.png", Vec2f(32, 32), 3);
	AddIconToken("$waterman_class_icon$", "ClassIcons.png", Vec2f(32, 32), 4);
	AddIconToken("$crossbow_class_icon$", "ClassIcons.png", Vec2f(32, 32), 5);
	AddIconToken("$necro_class_icon$", "ClassIcons.png", Vec2f(32, 32), 7);
	AddIconToken("$runemaster_class_icon$", "ClassIcons.png", Vec2f(32, 32), 8);
	AddIconToken("$paladin_class_icon$", "ClassIcons.png", Vec2f(32, 32), 9);
	AddIconToken("$priest_class_icon$", "ClassIcons.png", Vec2f(32, 32),10);
	AddIconToken("$samurai_class_icon$", "ClassIcons.png", Vec2f(32, 32),11);
	AddIconToken("$mindman_class_icon$", "ClassIcons.png", Vec2f(32, 32),12);
	AddIconToken("$shadowman_class_icon$", "ClassIcons.png", Vec2f(32, 32),13);
	AddIconToken("$runescribe_class_icon$", "ClassIcons.png", Vec2f(32, 32),14);
	AddIconToken("$brainswitch_class_icon$", "ClassIcons.png", Vec2f(32, 32),15);
	
	AddIconToken("$change_class$", "GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	//addPlayerClass(this, "Builder", "$builder_class_icon$", "builder", "Build ALL the towers.");
	addPlayerClass(this, "Rune Master", "$runemaster_class_icon$", "runemaster", "Rune carver.");
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
	addPlayerClass(this, "Ghoul", "$ghoul_class_icon$", "ghoul", "The Slash an eat.");
	addPlayerClass(this, "Sapper", "$sapper_class_icon$", "sapper", "The Slash an splode.");
	addPlayerClass(this, "Elementalist", "$waterman_class_icon$", "waterman", "Burning water.");
	addPlayerClass(this, "Crossbowman", "$crossbow_class_icon$", "crossbow", "The Ranged Advantage.");
	addPlayerClass(this, "Boring Necromancer", "$necro_class_icon$", "necro", "The summon and splode.");
	addPlayerClass(this, "Paladin", "$paladin_class_icon$", "paladin", "Holy crusher.");
	addPlayerClass(this, "Priest", "$priest_class_icon$", "priest", "Holy smiter.");
	addPlayerClass(this, "Samurai", "$samurai_class_icon$", "samurai", "The slash and fly.");
	addPlayerClass(this, "Gravity Charmer", "$mindman_class_icon$", "mindman", "The hover and float.");
	addPlayerClass(this, "Shadow Master", "$shadowman_class_icon$", "shadowman", "The phase and stab.");
	addPlayerClass(this, "Rune Scribe", "$runescribe_class_icon$", "runescribe", "The write and spell.");
	addPlayerClass(this, "Mind Writer", "$brainswitch_class_icon$", "brainswitcher", "Body Switching!");
	
	//addPlayerClass(this, "Test", "$builder_class_icon$", "shark", "testing.");
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(CLASS_BUTTON_SIZE * 5, CLASS_BUTTON_SIZE * 3), "Swap class");
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
					if(getGameTime() < 180*getTicksASecond() && caller.getPlayer().getUsername() != "Pirate-Rob")classconfig = "runemaster";
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
						if(caller.getName() != "ghoul"){
							// set health to be same ratio
							float healthratio = caller.getHealth() / caller.getInitialHealth();
							newBlob.server_SetHealth(newBlob.getInitialHealth() * healthratio);
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

						if (caller.exists("knocked"))
						{
							newBlob.set_u8("knocked", caller.get_u8("knocked"));
							newBlob.Sync("knocked", true);
						}
						copyTatoos(caller,newBlob);

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
