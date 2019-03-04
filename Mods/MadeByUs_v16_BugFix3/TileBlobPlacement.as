#include "PlacementCommon.as"
#include "BuildBlock.as"

#include "GameplayEvents.as"

//server-only
void PlaceBlock(CBlob@ this, u8 index, Vec2f cursorPos)
{

	CBitStream missing;

	CBlob @carryBlob = this.getCarriedBlob();
	
	if(carryBlob !is null)
	if (index > 0 && carryBlob.get_s16("placetile") == index && carryBlob.getQuantity() > 0)
	{
		if(carryBlob.getQuantity() >= carryBlob.get_s16("material_cost")){
			carryBlob.server_SetQuantity(carryBlob.getQuantity()-carryBlob.get_s16("material_cost"));
			if(carryBlob.getQuantity() <= 0)carryBlob.server_Die();
			getMap().server_SetTile(cursorPos, index);

			SendGameplayEvent(createBuiltBlockEvent(this.getPlayer(), index));
		}
	}
	
	if(carryBlob !is null)
	if (index > 0 && carryBlob.get_s16("secondary_placetile") == index && carryBlob.getQuantity() > 0)
	{
		if(carryBlob.getQuantity() >= carryBlob.get_s16("secondary_material_cost")){
			carryBlob.server_SetQuantity(carryBlob.getQuantity()-carryBlob.get_s16("secondary_material_cost"));
			if(carryBlob.getQuantity() <= 0)carryBlob.server_Die();
			getMap().server_SetTile(cursorPos, index);

			SendGameplayEvent(createBuiltBlockEvent(this.getPlayer(), index));
		}
	}
}

void onInit(CBlob@ this)
{
	AddCursor(this);
	SetupBuildDelay(this);
	this.addCommandID("placeBlock");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	if (this.isInInventory())
	{
		return;
	}

	//don't build with menus open
	if (getHUD().hasMenus())
	{
		return;
	}

	if (isBuildDelayed(this))
	{
		return;
	}

	BlockCursor @bc;
	this.get("blockCursor", @bc);
	if (bc is null)
	{
		return;
	}

	SetTileAimpos(this, bc);
	
	
	CBlob @carryBlob = this.getCarriedBlob();
	if (carryBlob is null || !carryBlob.hasTag("tileplace"))
	{
		return;
	}
	
	
	// check buildable
	bc.buildable = false;
	bc.supported = false;
	TileType buildtile = carryBlob.get_s16("placetile");

	if (buildtile > 0)
	{
		bc.blockActive = true;
		bc.blobActive = false;
		CMap@ map = this.getMap();
		u8 blockIndex = carryBlob.get_s16("placetile");

		if (bc.cursorClose)
		{
			Vec2f halftileoffset(map.tilesize * 0.5f, map.tilesize * 0.5f);
			bc.buildableAtPos = isBuildableAtPos(this, bc.tileAimPos + halftileoffset, buildtile, null, bc.sameTileOnBack);
			bc.rayBlocked = isBuildRayBlocked(this.getPosition(), bc.tileAimPos + halftileoffset, bc.rayBlockedPos);
			bc.buildable = bc.buildableAtPos && !bc.rayBlocked;
			bc.supported = bc.buildable && map.hasSupportAtPos(bc.tileAimPos);
		}
		if (!getHUD().hasButtons() && this.isKeyPressed(key_action1))
		{
			if (bc.cursorClose && bc.buildable && bc.supported)
			{
				CBitStream params;
				params.write_u8(blockIndex);
				params.write_Vec2f(bc.tileAimPos);
				this.SendCommand(this.getCommandID("placeBlock"), params);
				//u32 delay = this.get_u32("build delay");
				SetBuildDelay(this, 5);
				bc.blockActive = false;
			}
			else if (this.isKeyJustPressed(key_action1) && !bc.sameTileOnBack)
			{
				Sound::Play("NoAmmo.ogg");
			}
		}
	}else{bc.blockActive = false;}
	
	if(!carryBlob.hasTag("secondary_tileplace"))return;
	
	buildtile = carryBlob.get_s16("secondary_placetile");
	
	if (buildtile > 0)
	{
		bc.blockActive = true;
		bc.blobActive = false;
		CMap@ map = this.getMap();
		u8 blockIndex = carryBlob.get_s16("secondary_placetile");

		if (bc.cursorClose)
		{
			Vec2f halftileoffset(map.tilesize * 0.5f, map.tilesize * 0.5f);
			bc.buildableAtPos = isBuildableAtPos(this, bc.tileAimPos + halftileoffset, buildtile, null, bc.sameTileOnBack);
			bc.rayBlocked = isBuildRayBlocked(this.getPosition(), bc.tileAimPos + halftileoffset, bc.rayBlockedPos);
			bc.buildable = bc.buildableAtPos && !bc.rayBlocked;
			bc.supported = bc.buildable && map.hasSupportAtPos(bc.tileAimPos);
		}
		if (!getHUD().hasButtons() && this.isKeyPressed(key_action2))
		{
			if (bc.cursorClose && bc.buildable && bc.supported)
			{
				CBitStream params;
				params.write_u8(blockIndex);
				params.write_Vec2f(bc.tileAimPos);
				this.SendCommand(this.getCommandID("placeBlock"), params);
				//u32 delay = this.get_u32("build delay");
				SetBuildDelay(this, 5);
				bc.blockActive = false;
			}
			else if (this.isKeyJustPressed(key_action1) && !bc.sameTileOnBack)
			{
				Sound::Play("NoAmmo.ogg");
			}
		}
	}else{bc.blockActive = false;}
}

// render block placement

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (getHUD().hasButtons())
	{
		return;
	}

	CBlob @carryBlob = blob.getCarriedBlob();
	if (carryBlob is null || !carryBlob.hasTag("tileplace"))
	{
		return;
	}
	
	// draw a map block or other blob that snaps to grid
	TileType buildtile = carryBlob.get_s16("placetile");

	if (buildtile > 0)
	{
		CMap@ map = getMap();
		BlockCursor @bc;
		blob.get("blockCursor", @bc);
		
		Vec2f tileAimPos = Vec2f(int(blob.getAimPos().x/8)*8,int(blob.getAimPos().y/8)*8);

		SColor color;
		
		if(getMap().hasSupportAtPos(tileAimPos)){
			color.set(150, 150, 150, 150);
			map.DrawTile(tileAimPos, buildtile, color, getCamera().targetDistance, false);
		} else {
			color.set(255, 255, 46, 50);
			const u32 gametime = getGameTime();
			Vec2f offset(0.0f, -1.0f + 1.0f * ((gametime * 0.8f) % 8));

			if (gametime % 16 < 9)
			{
				Vec2f supportPos = tileAimPos;
				Vec2f point;
				if (map.rayCastSolid(supportPos, supportPos + Vec2f(0.0f, map.tilesize * 32.0f), point))
				{
					const uint count = (point - supportPos).getLength() / map.tilesize;
					for (uint i = 1; i < count; i++)
					{
						map.DrawTile(supportPos + Vec2f(0.0f, map.tilesize * i), buildtile,
									 SColor(128, 100, 8, 5),
									 getCamera().targetDistance, false);
					}
				}
			}
			
			map.DrawTile(tileAimPos, buildtile, color, getCamera().targetDistance, false);
		}
		
		/*
		if (bc !is null)
		{
			if (bc.cursorClose && bc.buildable)
			{
				SColor color;

				if (bc.buildable && bc.supported)
				{
					color.set(255, 255, 255, 255);
					map.DrawTile(tileAimPos, buildtile, color, getCamera().targetDistance, false);
				}
				else
				{
					// no support
					color.set(255, 255, 46, 50);
					const u32 gametime = getGameTime();
					Vec2f offset(0.0f, -1.0f + 1.0f * ((gametime * 0.8f) % 8));
					map.DrawTile(tileAimPos + offset, buildtile, color, getCamera().targetDistance, false);

					if (gametime % 16 < 9)
					{
						Vec2f supportPos = tileAimPos + Vec2f(blob.isFacingLeft() ? map.tilesize : -map.tilesize, map.tilesize);
						Vec2f point;
						if (map.rayCastSolid(supportPos, supportPos + Vec2f(0.0f, map.tilesize * 32.0f), point))
						{
							const uint count = (point - supportPos).getLength() / map.tilesize;
							for (uint i = 0; i < count; i++)
							{
								map.DrawTile(supportPos + Vec2f(0.0f, map.tilesize * i), buildtile,
								             SColor(255, 205, 16, 10),
								             getCamera().targetDistance, false);
							}
						}
					}
				}
			}
			else
			{
				f32 halfTile = map.tilesize / 2.0f;
				Vec2f aimpos = blob.getAimPos();
				Vec2f offset(-0.2f + 0.4f * ((getGameTime() * 0.8f) % 8), 0.0f);
				map.DrawTile(Vec2f(aimpos.x - halfTile, aimpos.y - halfTile) + offset, buildtile,
				             SColor(255, 255, 46, 50),
				             getCamera().targetDistance, false);
			}
		}*/
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer() && cmd == this.getCommandID("placeBlock"))
	{
		u8 index = params.read_u8();
		Vec2f pos = params.read_Vec2f();
		PlaceBlock(this, index, pos);
	}
}

