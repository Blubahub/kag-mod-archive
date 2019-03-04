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
		
#include "WizardsClassSelectMenu.as"
#include "Hitters.as"

void InitRespawnCommand( CBlob@ this )
{
	this.addCommandID("class menu");
}

bool isInRadius( CBlob@ this, CBlob @caller )
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius()*2.0f + caller.getRadius());
}

bool canChangeClass( CBlob@ this, CBlob @caller )
{
	return this.isOverlapping(caller);
}

// default classes
void InitWizardAltarClasses( CBlob@ this )
{
	AddIconToken( "$necromancer_class_icon$", "GUI/NewIcons.png", Vec2f(32,32), 4 );
    AddIconToken( "$wizard_class_icon$", "GUI/NewIcons.png", Vec2f(32,32), 5 );
    AddIconToken( "$druid_class_icon$", "GUI/NewIcons.png", Vec2f(32,32), 6 );
	addWizardAltarPlayerClass( this, "Necromancer", "$necromancer_class_icon$", "Necromancer", "Summons zombies.", "medium_soulstone", "Medium Soulstone" );
	addWizardAltarPlayerClass( this, "Wizard", "$wizard_class_icon$", "wizard", "Poweful wizard.", "soulstone", "Powerful Soulstone");
    addWizardAltarPlayerClass( this, "Druid", "$druid_class_icon$", "druid", "Heals your teammates.", "weak_soulstone", "Weak Soulstone");
}

void BuildRespawnMenuForWizardAltar( CBlob@ this, CBlob @caller )
{
	NewPlayerClass[]@ classes;
    this.get( "wizardaltarplayerclasses", @classes );

    if (caller !is null && caller.isMyPlayer() && classes !is null)
    {
        CGridMenu@ menu = CreateGridMenu( caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(classes.length*CLASS_BUTTON_SIZE,CLASS_BUTTON_SIZE), "Swap class" );
        if (menu !is null) {
            addWizardAltarClassesToMenu(this, menu, caller.getNetworkID());
        }
    }
}

void onWizardAltarRespawnCommand( CBlob@ this, u8 cmd, CBitStream @params)
{

	switch( cmd )
    {
    case SpawnCmd::buildMenu:
    {
        {
            // build menu for them
            CBlob@ caller = getBlobByNetworkID( params.read_u16() );
            BuildRespawnMenuForWizardAltar( this, caller );
        }
    }
    break;

    case SpawnCmd::changeClass:
    {
        if (getNet().isServer() )
        {
            // build menu for them
            CBlob@ caller = getBlobByNetworkID( params.read_u16() );
            Vec2f pos = this.getPosition();

            if (caller !is null && canChangeClass( this, caller ))
            {
                string classconfig = params.read_string();
                CBlob @newBlob = server_CreateBlob( classconfig, caller.getTeamNum(), this.getRespawnPosition() );
				CBlob@ item;
                if (newBlob !is null)
                {
                    // copy health and inventory
                    // make sack
                    CInventory @inv = caller.getInventory();
                    NewPlayerClass[]@ classes;

                    if(this.get( "wizardaltarplayerclasses", @classes ))
                    {
                    	for (uint i = 0 ; i < classes.length; i++)
                    	{
                    		NewPlayerClass @pclass = classes[i];
                    		if (pclass.configFilename == classconfig)
                    			caller.TakeBlob(pclass.item, 1);
                    	}
						/*caller.TakeBlob( "soulorb", 1 );
						caller.TakeBlob( "soulstone", 1 );
						
						caller.TakeBlob( "chestplate", 1 );
						caller.TakeBlob( "mace", 1 );
						
						caller.TakeBlob( "crossbow", 1 );*/
						
					}
					if(classconfig == "wizard")
					{
						@item = server_CreateBlob( "mat_orbs", newBlob.getTeamNum(), newBlob.getPosition());
					}

                    if (inv !is null)
                    {
						if (this.hasTag("change class drop inventory"))
						{
							while (inv.getItemsCount() > 0)
                            {
                                CBlob @item = inv.getItem(0);
                                caller.server_PutOutInventory( item );
							}
						}
						else if (this.hasTag("change class store inventory"))
						{		
							if (this.getInventory() !is null) {
								caller.MoveInventoryTo( this );
							}
							else // find a storage
							{	   
								PutInvInStorage( caller );
							}
						}
						else
                        {
                            // keep inventory if possible
                            caller.MoveInventoryTo( newBlob );
                        }
                    }

                    if(caller.getHealth() != caller.getInitialHealth()) //only if was damaged, else just set max hearts //fix contributed by norill 19 aug 13
						newBlob.server_SetHealth( Maths::Min(caller.getHealth(), newBlob.getInitialHealth()) ); //set old hearts, capped by new initial hearts
					
                    // plug the soul
                    newBlob.server_SetPlayer( caller.getPlayer() );
                    newBlob.setPosition( caller.getPosition() );
					newBlob.Tag("action pressed"); // no immunity after class change
                    caller.server_setTeamNum(100);
                    caller.server_SetHealth(0.1f);
                }
            }
        }
    }
    break;
    }

	//params.SetBitIndex( index );
}

void PutInvInStorage( CBlob@ blob )
{
	CBlob@[] storages;
	if (getBlobsByTag( "storage", @storages ))
		for (uint step = 0; step < storages.length; ++step)
		{
			CBlob@ storage = storages[step];
			if (storage.getTeamNum() == blob.getTeamNum())
			{																
				blob.MoveInventoryTo( storage );
				return;
			}
		}
}
