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
        
#include "BarracksClassSelectMenu.as"

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
void InitBarracksClasses( CBlob@ this )
{
    AddIconToken("$sapper_class_icon$", "RobsClassIcons.png", Vec2f(32, 32), 6);
    AddIconToken("$ghoul_class_icon$", "RobsClassIcons.png", Vec2f(32, 32), 3);
    AddIconToken("$waterman_class_icon$", "RobsClassIcons.png", Vec2f(32, 32), 4);
    AddIconToken("$crossbow_class_icon$", "RobsClassIcons.png", Vec2f(32, 32), 5);
    AddIconToken("$necro_class_icon$", "RobsClassIcons.png", Vec2f(32, 32), 7);
    AddIconToken("$runemaster_class_icon$", "RobsClassIcons.png", Vec2f(32, 32), 8);
    AddIconToken("$paladin_class_icon$", "RobsClassIcons.png", Vec2f(32, 32), 9);
    AddIconToken("$priest_class_icon$", "RobsClassIcons.png", Vec2f(32, 32),10);
    AddIconToken("$samurai_class_icon$", "RobsClassIcons.png", Vec2f(32, 32),11);
    AddIconToken("$mindman_class_icon$", "RobsClassIcons.png", Vec2f(32, 32),12);
    AddIconToken("$shadowman_class_icon$", "RobsClassIcons.png", Vec2f(32, 32),13);
    AddIconToken("$runescribe_class_icon$", "RobsClassIcons.png", Vec2f(32, 32),14);
    AddIconToken("$brainswitch_class_icon$", "RobsClassIcons.png", Vec2f(32, 32),15);

    AddIconToken( "$heavyknight_class_icon$", "GUI/NewIcons.png", Vec2f(32,32), 2 );
    AddIconToken( "$crossbowman_class_icon$", "GUI/NewIcons.png", Vec2f(32,32), 1 );
    AddIconToken( "$hunter_class_icon$", "GUI/NewIcons.png", Vec2f(32,32), 3 );
    addBarracksPlayerClass( this, "Heavy Knight", "$heavyknight_class_icon$", "heavyknight", "Upgraded knight.", "armorkit", "Armor Kit" );
    addBarracksPlayerClass( this, "Crossbowman", "$crossbowman_class_icon$", "crossbowman", "Upgraded archer.", "crossbow", "Crossbow");
    addBarracksPlayerClass( this, "Hunter", "$hunter_class_icon$", "hunter", "Upgraded archer.", "longbow", "Long Bow" );
    addBarracksPlayerClass(this, "Sapper", "$sapper_class_icon$", "sapper", "The Slash an splode.");
    addBarracksPlayerClass(this, "Elementalist", "$waterman_class_icon$", "waterman", "Burning water.");
    addBarracksPlayerClass(this, "Paladin", "$paladin_class_icon$", "paladin", "Holy crusher.", "coins", "50");
    addBarracksPlayerClass(this, "Priest", "$priest_class_icon$", "priest", "Holy smiter.");
    addBarracksPlayerClass(this, "Samurai", "$samurai_class_icon$", "samurai", "The slash and fly.", "coins", "50");
    addBarracksPlayerClass(this, "Gravity Charmer", "$mindman_class_icon$", "mindman", "The hover and float.", "coins", "25");
    addBarracksPlayerClass(this, "Shadow Master", "$shadowman_class_icon$", "shadowman", "The phase and stab.", "coins", "20");
    addBarracksPlayerClass(this, "Rune Scribe", "$runescribe_class_icon$", "runescribe", "The write and spell.", "coins", "70");
}

void BuildRespawnMenuForBarracks( CBlob@ this, CBlob @caller )
{
    NewPlayerClass[]@ classes;
    this.get( "barracksplayerclasses", @classes );

    if (caller !is null && caller.isMyPlayer() && classes !is null)
    {
        CGridMenu@ menu = CreateGridMenu( caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(6*CLASS_BUTTON_SIZE,CLASS_BUTTON_SIZE*2), "Swap class" );
        if (menu !is null) 
        {
            if (getRules().isWarmup())
            {
                CBitStream params;
                write_classchange(params, caller.getNetworkID(), "builder");
                CGridButton@ button = menu.AddButton("$builder_class_icon$", "Onlly Builder is avaible on warmup", SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
            }
            else
                addBarracksClassesToMenu(this, menu, caller.getNetworkID());
        }
    }
}

void onBarracksRespawnCommand( CBlob@ this, u8 cmd, CBitStream @params)
{

    switch( cmd )
    {
    case SpawnCmd::buildMenu:
    {
        {
            // build menu for them
            CBlob@ caller = getBlobByNetworkID( params.read_u16() );
            BuildRespawnMenuForBarracks( this, caller );
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

                    if(this.get( "barracksplayerclasses", @classes ))
                    {
                        for (uint i = 0 ; i < classes.length; i++)
                        {
                            NewPlayerClass @pclass = classes[i];
                            if (pclass.configFilename == classconfig)
                            {
                                if (pclass.item == "coins")
                                {
                                    CPlayer@ p = caller.getPlayer();
                                    if (p !is null)
                                    {
                                       p.server_setCoins(p.getCoins() - parseInt(pclass.itemsDesc)); 
                                    }
                                    
                                }
                                else
                                {
                                    caller.TakeBlob(pclass.item, 1);
                                }
                            }
                        }
                        /*caller.TakeBlob( "soulorb", 1 );
                        caller.TakeBlob( "soulstone", 1 );
                        
                        caller.TakeBlob( "chestplate", 1 );
                        caller.TakeBlob( "mace", 1 );
                        
                        caller.TakeBlob( "crossbow", 1 );*/
                        
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
                    caller.Tag("switch class");
                    caller.server_SetPlayer( null );
                    caller.server_Die();
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
