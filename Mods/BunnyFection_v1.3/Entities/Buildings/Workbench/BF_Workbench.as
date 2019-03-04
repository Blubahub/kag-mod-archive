// BF_Workbench script

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "BF_Costs.as";

void onInit( CBlob@ this )
{
    this.set_TileType("background tile", CMap::tile_wood_back);
    this.getSprite().SetZ(-50);
    this.getShape().getConsts().mapCollisions = false;

    // ICONS
    AddIconToken( "$custom_blockwood$", "BF_BlockWood.png", Vec2f(8,8), 0);
    AddIconToken( "$custom_doorwood$", "BF_DoorWood.png", Vec2f(16,8), 0);
    AddIconToken( "$custom_candle$", "BF_Candle.png", Vec2f(8,8), 4);
    AddIconToken( "$custom_blockstone$", "BF_BlockStone.png", Vec2f(8,8), 0);
    AddIconToken( "$custom_doorstone$", "BF_DoorStone.png", Vec2f(16,8), 0);
    AddIconToken( "$custom_sconcestone$", "BF_SconceStone.png", Vec2f(8,8), 3);
    AddIconToken( "$custom_turretcannon$", "BF_TurretCannon.png", Vec2f(16,16), 7);
    AddIconToken( "$custom_turretballista$", "BF_TurretBallista.png", Vec2f(24,16), 9);
    AddIconToken( "$custom_trapspike$", "BF_TrapSpike.png", Vec2f(8,24), 6);
    AddIconToken( "$custom_trapdoor$", "BF_TrapDoor.png", Vec2f(8,24), 6);
    AddIconToken( "$custom_platformwood$", "BF_PlatformWood.png", Vec2f(8,8), 0);
	AddIconToken( "$custom_ladderwood$", "BF_LadderWood.png", Vec2f(16,16), 6);

    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(4,3));
    this.set_string("shop description", "Craft");

    // WOOD
    {   // Wood Block
        ShopItem@ s = addShopItem( this, "Wood Block", "$custom_blockwood$", "bf_blockwood", "Craft a Wood Block.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_WBLOCK );
    }
    {   // Wood Door
        ShopItem@ s = addShopItem( this, "Wood Door", "$custom_doorwood$", "bf_doorwood", "Craft a Wood Door.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_WDOOR );
    }
    {   // Candle
        ShopItem@ s = addShopItem( this, "Candle", "$custom_candle$", "bf_candle", "Craft a small candle, illuminates a small area.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_CANDLE );
    }
    {   // Wood Ballista
        ShopItem@ s = addShopItem( this, "Wood Ballista", "$custom_turretballista$", "bf_turretballista", "Craft a Wood Ballista that automatically fires at intruders.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_BALLISTA );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_BALLISTA );
    }

    // STONE
    {   // Stone Block
        ShopItem@ s = addShopItem( this, "Stone Block", "$custom_blockstone$", "bf_blockstone", "Craft a Stone Block.", false );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_SBLOCK );
    }
    {   // Stone Door
        ShopItem@ s = addShopItem( this, "Stone Door", "$custom_doorstone$", "bf_doorstone", "Craft a Stone Door.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SDOOR );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_SDOOR );
    }
    {   // Stone Sconce
        ShopItem@ s = addShopItem( this, "Stone Sconce", "$custom_sconcestone$", "bf_sconcestone", "Craft a Stone Sconce, this object emits light which can be activated or deactivated.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SCONCE );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_SCONCE );
    }
    {   // Stone Cannon
        ShopItem@ s = addShopItem( this, "Stone Cannon", "$custom_turretcannon$", "bf_turretcannon", "Craft a Stone Cannon that automatically fires at intruders.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_CANNON );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_CANNON );
    }
    {   // Stone Spike Trap
        ShopItem@ s = addShopItem( this, "Stone Spike Trap", "$custom_trapspike$", "bf_trapspike", "Craft a Stone Spike Trap, when activated impales intruders.\n\nRequires manual re-priming.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SPIKE_TRAP );
        AddRequirement(s.requirements, "blob", "mat_stone", "Stone", COST_STONE_SPIKE_TRAP );
    }
    {   // Stone Trap Door
        ShopItem@ s = addShopItem( this, "Stone Trap Door", "$custom_trapdoor$", "bf_trapdoor", "Craft a Stone Trap Door, when activated extends a wall to block intruders.\n\nRequires manual re-priming.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_TRAP_DOOR );
        AddRequirement(s.requirements, "blob", "mat_stone", "Stone", COST_STONE_TRAP_DOOR );
    }
    
    {   // Wood Platform
        ShopItem@ s = addShopItem( this, "Wood Platform", "$custom_platformwood$", "bf_platformwood", "Craft a Wood Platform.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_PLATFORM );
    }
    {   // Wood Ladder
        ShopItem@ s = addShopItem( this, "Wood Ladder", "$custom_ladderwood$", "bf_ladderwood", "Craft a Wood Ladder.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_LADDER);
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/ConstructShort.ogg" );
    }
}
