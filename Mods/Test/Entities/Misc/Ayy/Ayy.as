const f32 yPos = 90.00f;

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetRotationsAllowed(false);
	
	this.setPosition(Vec2f(this.getPosition().x, yPos));
	
	// this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	// this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 7, Vec2f(16, 16));
	// this.SetMinimapRenderAlways(true);
	
	// this.getSprite().SetZ(-25); //background
	
	// this.set_Vec2f("shop offset", Vec2f(-6, 0));
	// this.set_Vec2f("shop menu size", Vec2f(5, 4));
	// this.set_string("shop description", "Mysterious Wreckage's Molecular Fabricator");
	// this.set_u8("shop icon", 15);

	// this.set_f32("map_damage_ratio", 1.0f);
	// this.set_bool("map_damage_raycast", true);
	// this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	// this.Tag("map_damage_dirt");
	// this.Tag("map_destroy_ground");

	// this.Tag("ignore fall");
	// this.Tag("explosive");
	// this.Tag("high weight");
	// this.Tag("scyther inside");

	// this.server_setTeamNum(-1);

	// if (getNet().isServer())
	// {
		// if (XORRandom(100) < 75)
		// {
			// CBlob@ blob = server_CreateBlob("chargerifle", this.getTeamNum(), this.getPosition());
			// this.server_PutInInventory(blob);
		// }

		// if (XORRandom(100) < 25)
		// {
			// CBlob@ blob = server_CreateBlob("chargerifle", this.getTeamNum(), this.getPosition());
			// this.server_PutInInventory(blob);
		// }
		
		// if (XORRandom(100) < 50)
		// {
			// for (int i = 0; i < 1 + XORRandom(4); i++)
			// {
				// CBlob@ blob = server_CreateBlob("bobomax", this.getTeamNum(), this.getPosition());
				// this.server_PutInInventory(blob);
			// }
		// }

		// if (XORRandom(100) < 10)
		// {
			// CBlob@ blob = server_CreateBlob("chargelance", this.getTeamNum(), this.getPosition());
			// this.server_PutInInventory(blob);

			// MakeMat(this, this.getPosition(), "mat_lancerod", 50 + XORRandom(50));
		// }
		
		// if (XORRandom(100) < 5)
		// {
			// CBlob@ blob = server_CreateBlob("exosuititem", this.getTeamNum(), this.getPosition());
			// this.server_PutInInventory(blob);
		// }
		
		// if (XORRandom(100) < 10)
		// {
			// CBlob@ blob = server_CreateBlob("fieldgenerator", this.getTeamNum(), this.getPosition());
			// this.server_PutInInventory(blob);
		// }
		
		// if (XORRandom(100) < 25)
		// {
			// CBlob@ blob = server_CreateBlob("mat_mithrilbomb", this.getTeamNum(), this.getPosition());
			// blob.server_SetQuantity(1 + XORRandom(4));
			
			// this.server_PutInInventory(blob);
		// }

		// MakeMat(this, this.getPosition(), "mat_lancerod", 50 + XORRandom(50));
		// MakeMat(this, this.getPosition(), "mat_matter", 50 + XORRandom(200));
		// MakeMat(this, this.getPosition(), "mat_plasteel", 25 + XORRandom(50));
	// }

	// this.inventoryButtonPos = Vec2f(6, 0);
	
	// CMap@ map = getMap();
	// this.setPosition(Vec2f(this.getPosition().x, 0.0f));
	// this.setVelocity(Vec2f((15 + XORRandom(5)) * (XORRandom(2) == 0 ? 1.00f : -1.00f), 5));
	// // this.getShape().SetGravityScale(0.0f);

	if (getNet().isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundVolume(10.0f);
		sprite.SetEmitSound("Ayy_Loop.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.RewindEmitSound();
		
		// client_AddToChat("A strange object has fallen out of the sky in the " + ((this.getPosition().x < getMap().tilemapwidth * 4) ? "west" : "east") + "!", SColor(255, 255, 0, 0));
		client_AddToChat("A strange object has fallen out of the sky!", SColor(255, 255, 0, 0));
	}
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	bool server = getNet().isServer();
	bool client = getNet().isClient();
	
	Vec2f pos = Vec2f(this.getPosition().x, yPos);

	if (client) ShakeScreen(80, 30, pos);
	
	this.setPosition(pos + Vec2f(0.25f, 0));
}
