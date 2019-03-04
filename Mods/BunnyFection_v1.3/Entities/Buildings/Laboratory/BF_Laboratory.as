// BF_Laboratory script

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
    AddIconToken( "$custom_miningcharge$", "BF_MiningCharge.png", Vec2f(8,16), 0);
    AddIconToken( "$custom_potionspeed$", "BF_Potion.png", Vec2f(8,8), 10);
    AddIconToken( "$custom_potioninvisiblity$", "BF_Potion.png", Vec2f(8,8), 0);
    AddIconToken( "$custom_potionrockskin$", "BF_Potion.png", Vec2f(8,8), 5);
    AddIconToken( "$custom_potionfeather$", "BF_Potion.png", Vec2f(8,8), 30);

    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(4,1));
    this.set_string("shop description", "Craft");

    // EXPLOSIVES
    /*{   // Mining Charge
         ShopItem@ s = addShopItem( this, "Mining Charge", "$custom_miningcharge$", "bf_miningcharge", "Craft a mining charge, used for clearing paths in thick stone and gathering precious ores.", false );
         AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_MINING_CHARGE );
         AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_MINING_CHARGE );
    }*/
	// POTIONS
    {   // Speed
         ShopItem@ s = addShopItem( this, "Speed Potion", "$custom_potionspeed$", "bf_potionspeed", "Brew a speed potion. Boosts your speed for some seconds", false );
         AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_POTION_SPEED );
         AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_POTION_SPEED);
    }  
	{   // invisibility
         ShopItem@ s = addShopItem( this, "Invisibility Potion", "$custom_potioninvisiblity$", "bf_potioninvisibility", "Brew an invisibility potion. Makes you invisible for a few seconds", false );
         AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_POTION_INVISIBILITY );
         AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_POTION_INVISIBILITY );
    }
	{   // rockskin
         ShopItem@ s = addShopItem( this, "RockSkin Potion", "$custom_potionrockskin$", "bf_potionrockskin", "Brew a rock skin potion. Increases your resistance to hits for some seconds", false );
         AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_POTION_ROCK_SKIN );
         AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_POTION_ROCK_SKIN );
    }
	{   // feather
         ShopItem@ s = addShopItem( this, "Feather Potion", "$custom_potionfeather$", "bf_potionfeather", "Brew a feather potion. Defy gravity! Makes you floaty for some seconds", false );
         AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_POTION_FEATHER );
         AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_POTION_FEATHER );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/ConstructShort.ogg" );
    }
}
