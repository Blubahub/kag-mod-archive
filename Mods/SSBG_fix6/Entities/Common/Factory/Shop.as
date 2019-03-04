//generic shop menu

// properties:
//      shop offset - Vec2f - used to offset things bought that spawn into the world, like vehicles

#include "ShopCommon.as";
#include "Requirements_Tech.as";
#include "MakeCrate.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{
	this.addCommandID( "shop menu" );
	this.addCommandID( "shop buy" );
	this.addCommandID("shop made item");

	if (!this.exists("shop available"))
		this.set_bool("shop available", true);
	if (!this.exists("shop offset"))
		this.set_Vec2f("shop offset", Vec2f(0,0));
	if (!this.exists("shop menu size"))
		this.set_Vec2f("shop menu size", Vec2f(7,7));
	if (!this.exists("shop description"))
		this.set_string("shop description", "Workbench");
	if (!this.exists("shop icon"))
		this.set_u8("shop icon", 15);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	ShopItem[]@ shop_items;
	if (!this.get(SHOP_ARRAY, @shop_items)) { return; }
	if (shop_items.length > 0 && this.get_bool("shop available") && !this.hasTag("shop disabled"))
	{
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		caller.CreateGenericButton( this.get_u8("shop icon"), this.get_Vec2f("shop offset"), this, this.getCommandID("shop menu"), this.get_string("shop description"), params );
	}
}

bool isInRadius( CBlob@ this, CBlob @caller )
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius()*3.0f + caller.getRadius());
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop menu"))
    {
		if(this.hasTag("shop disabled"))
			return;
		
        // build menu for them
        CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		BuildShopMenu( this, caller, this.get_string("shop description"), Vec2f(0,0), this.get_Vec2f("shop menu size") );
    }
	else
	if (cmd == this.getCommandID("shop buy"))
    {
		if(this.hasTag("shop disabled"))
			return;
		
        u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
        bool spawnToInventory = params.read_bool();
        bool spawnInCrate = params.read_bool();
		bool producing = params.read_bool();
        string blobName = params.read_string();
        u8 s_index = params.read_u8();

        CBlob@ caller = getBlobByNetworkID(callerID);
        if (caller is null) { return; }
        CInventory@ inv = caller.getInventory();

        if (inv !is null && isInRadius( this, caller ))
        {
            ShopItem[]@ shop_items;
            if (!this.get(SHOP_ARRAY, @shop_items)) { return; }
            if (s_index >= shop_items.length) { return; }
            ShopItem@ s = shop_items[s_index];

			// production?
			if (s.ticksToMake > 0)
			{
				s.producing = producing;
				return;
			}

			// check spam

			//if (isSpammed( blobName, this.getPosition(), 12 ))
			//{
			//	if (caller.isMyPlayer())
			//	{
			//		client_AddToChat( "There is too many " + blobName + "'s made here sorry." );
			//		this.getSprite().PlaySound("/NoAmmo.ogg" );
			//	}
			//	return;
			//}

			if (!getNet().isServer()) { return; } //only do this on server

			bool tookReqs = false;

			// try taking from the caller + this shop first
            CBitStream missing;
			if (hasRequirements_Tech( inv, this.getInventory(), s.requirements, missing ))
            {
				server_TakeRequirements( inv, this.getInventory(), s.requirements );
				tookReqs = true;
			}
			// try taking from caller + storages second
			if (!tookReqs)
			{
				const s32 team = this.getTeamNum();
				CBlob@[] storages;
				if (getBlobsByTag( "storage", @storages ))
					for (uint step = 0; step < storages.length; ++step)
					{
						CBlob@ storage = storages[step];
						if (storage.getTeamNum() == team)
						{
							CBitStream missing;
							if (hasRequirements_Tech( inv, storage.getInventory(), s.requirements, missing ))
							{
								server_TakeRequirements( inv, storage.getInventory(), s.requirements );
								tookReqs = true;
								break;
							}
						}
					}
			}

			if (tookReqs)
			{
				if(s.spawnNothing)
				{
					CBitStream params;
					params.write_netid( caller.getNetworkID() );
					params.write_netid( 0 );
					params.write_string( blobName );
					this.SendCommand( this.getCommandID("shop made item"), params );
				}
				else
				{

					//inv.server_TakeRequirements(s.requirements);
					Vec2f spawn_offset = Vec2f();

					if (this.exists("shop offset")) { spawn_offset = this.get_Vec2f("shop offset"); }
					if (this.isFacingLeft()) { spawn_offset.x *= -1; }
					CBlob@ newlyMade = null;

					if (spawnInCrate)
					{
						CBlob@ crate = server_MakeCrate( blobName, s.name, s.crate_icon, caller.getTeamNum(), caller.getPosition() );
						crate.SetDamageOwnerPlayer( caller.getPlayer() );
						
						if (crate !is null)
						{
							if (spawnToInventory && caller.canBePutInInventory(crate)) {
								caller.server_PutInInventory(crate);
							}
							else {
								caller.server_Pickup(crate);
							}
							@newlyMade = crate;
						}
					}
					else
					{
						CBlob@ blob = server_CreateBlob(blobName, caller.getTeamNum(), this.getPosition() + spawn_offset);
						blob.SetDamageOwnerPlayer( caller.getPlayer() );
						
						if (blob !is null)
						{
							if (spawnToInventory && blob.canBePutInInventory(caller)) {
								caller.server_PutInInventory(blob);
							}
							else {
								if (blob.getAttachments() !is null && blob.getAttachments().getAttachmentPointByName("PICKUP") !is null)
									caller.server_Pickup(blob);
							}
							@newlyMade = blob;
						}
					}

					if (newlyMade !is null)
					{
						CBitStream params;
						params.write_netid(caller.getNetworkID() );
						params.write_netid(newlyMade.getNetworkID() );
						params.write_string( blobName );
						this.SendCommand( this.getCommandID("shop made item"), params );
					}
				}
            }
        }
	}
}



//helper for building menus of shopitems

void addShopItemsToMenu(CBlob@ this, CGridMenu@ menu, CBlob@ caller )
{
	ShopItem[]@ shop_items;

	if (this.get( SHOP_ARRAY, @shop_items ))
	{
		for (uint i = 0 ; i < shop_items.length; i++)
		{
			ShopItem @s_item = shop_items[i];
			if (s_item is null || caller is null) { continue; }
			CBitStream params;

			params.write_u16( caller.getNetworkID() );
			params.write_bool( s_item.spawnToInventory );
			params.write_bool( s_item.spawnInCrate );
			params.write_bool( s_item.producing );
			params.write_string( s_item.blobName );
			params.write_u8(u8(i));

			
			CGridButton@ button;
			
			if( s_item.customButton)
				@button = menu.AddButton( s_item.iconName, s_item.name, this.getCommandID("shop buy"), Vec2f(s_item.buttonwidth, s_item.buttonheight), params );
			else
				@button = menu.AddButton( s_item.iconName, s_item.name, this.getCommandID("shop buy"), params );
				
			
			if (button !is null)
			{
				if (s_item.producing)		  // !! no click for production items
					button.clickable = false;

				button.selectOnClick = true;

				bool tookReqs = false;
				CBlob@ storageReq = null;
				// try taking from the caller + this shop first
				CBitStream missing;
				if (hasRequirements_Tech( this.getInventory(), caller.getInventory(), s_item.requirements, missing ))
				{
					tookReqs = true;
				}
				// try taking from caller + storages second
				//if (!tookReqs)
				//{
				//	const s32 team = this.getTeamNum();
				//	CBlob@[] storages;
				//	if (getBlobsByTag( "storage", @storages ))
				//		for (uint step = 0; step < storages.length; ++step)
				//		{
				//			CBlob@ storage = storages[step];
				//			if (storage.getTeamNum() == team)
				//			{
				//				CBitStream missing;
				//				if (hasRequirements_Tech( caller.getInventory(), storage.getInventory(), s_item.requirements, missing ))
				//				{
				//					@storageReq = storage;
				//					break;
				//				}
				//			}
				//		}
				//}

				const bool takeReqsFromStorage = (storageReq !is null);

				if (s_item.ticksToMake > 0)		   // production
					SetItemDescription_Tech( button, this, s_item.requirements, s_item.description, this.getInventory() );
				else
				{
					string desc = s_item.description;
					//if (takeReqsFromStorage)
					//	desc += "\n\n(Using resources from team storage)";

					SetItemDescription_Tech( button, caller, s_item.requirements, desc, takeReqsFromStorage ? storageReq.getInventory() : this.getInventory() );
				}

				//if (s_item.producing) {
				//	button.SetSelected( 1 );
				//	menu.deleteAfterClick = false;
				//}
			}
		}
	}
}

void BuildShopMenu( CBlob@ this, CBlob @caller, string description, Vec2f offset, Vec2f slotsAdd )
{
	if (caller is null || !caller.isMyPlayer())
		return;

	ShopItem[]@ shopitems;

	if (!this.get( SHOP_ARRAY, @shopitems )) { return; }

	
	CControls@ controls = caller.getControls();
	CGridMenu@ menu = CreateGridMenu( caller.getScreenPos() + offset, this, Vec2f(slotsAdd.x, slotsAdd.y), description );
	
	if (menu !is null) {
		if(!this.hasTag(SHOP_AUTOCLOSE))
			menu.deleteAfterClick = false;
		addShopItemsToMenu(this, menu, caller );
	}
	
}

void BuildDefaultShopMenu( CBlob@ this, CBlob @caller )
{
	BuildShopMenu( this, caller, "Shop", Vec2f(0,0), Vec2f( 4,4) );
}
