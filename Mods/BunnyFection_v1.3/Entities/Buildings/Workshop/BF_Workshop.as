// BF_Workshop script

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
    AddIconToken( "$custom_workbench$", "BF_WorkshopIcons.png", Vec2f(16,16), 0);
    AddIconToken( "$custom_forge$", "BF_WorkshopIcons.png", Vec2f(16,16), 1);
    AddIconToken( "$custom_anvil$", "BF_WorkshopIcons.png", Vec2f(16,16), 2);
    AddIconToken( "$custom_laboratory$", "BF_WorkshopIcons.png", Vec2f(16,16), 3);
    AddIconToken( "$custom_storage$", "BF_WorkshopIcons.png", Vec2f(16,16), 4);

    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(3,1));
    this.set_string("shop description", "Construct");
    this.set_u8("shop icon", 12);

    // WORKBENCH
    {
        ShopItem@ s = addShopItem( this, "Workbench", "$custom_workbench$", "bf_workbench", "Construct a Workbench for crafting basic blocks, gadgets and mechanisms.");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_WORKBENCH );
    }
    /*// FORGE
    {
        ShopItem@ s = addShopItem( this, "Forge", "$custom_forge$", "bf_forge", "Construct a Forge for smelting and refining raw ore into useable materials.");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_FORGE );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_FORGE );
    }
    // ANVIL
    {
        ShopItem@ s = addShopItem( this, "Anvil", "$custom_anvil$", "bf_anvil", "Construct an Anvil for crafting advanced blocks, gadgets and mechanisms.");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_ANVIL );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_ANVIL );
    }*/
    // LABORATORY
    {
        ShopItem@ s = addShopItem( this, "Laboratory", "$custom_laboratory$", "bf_laboratory", "Construct a Laboratory for crafting potions, explosives and chemical weapons." );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_LABORATORY );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_LABORATORY );
    }
    // STORAGE
    {
        ShopItem@ s = addShopItem( this, "Storage", "$custom_storage$", "bf_storage", "Construct a Storage cache for storing all your materials and crafted items." );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_STORAGE );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/Construct.ogg" ); 
        this.getSprite().getVars().gibbed = true;
        this.server_Die();
    }
}