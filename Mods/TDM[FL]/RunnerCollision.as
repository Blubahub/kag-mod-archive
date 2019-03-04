// character was placed in crate

const f32 hitTileInterval = 1.0f; 
void onTick(CBlob@ this)
{
	if (this.getName() != "trader" && !this.hasTag("dead") && getGameTime() > this.get_f32("hit_tile_time"))
	{
		hitTileBelow(this, this.getPosition());
		this.set_f32("hit_tile_time", getGameTime() + hitTileInterval);
	}
	
}


void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.doTickScripts = true; // run scripts while in crate
	this.getMovement().server_SetActive(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// when dead, collide only if its moving and some time has passed after death
	if (this.hasTag("dead"))
	{
		bool slow = (this.getShape().vellen < 1.5f);
		return !slow;
	}
	else // collide only if not a player or other team member, or crouching
	{
		//other team member
		if (blob.hasTag("player") && this.getTeamNum() == blob.getTeamNum())
		{
			//knight shield up logic

			//we're a platform if they aren't pressing down
			bool thisplatform = this.hasTag("shieldplatform") &&
			                    !blob.isKeyPressed(key_down);

			if (thisplatform || blob.getName() == "knight")
			{
				Vec2f pos = this.getPosition();
				Vec2f bpos = blob.getPosition();

				const f32 size = 9.0f;

				if (thisplatform)
				{
					if (bpos.y < pos.y - size && thisplatform)
					{
						return true;
					}
				}

				if (bpos.y > pos.y + size && blob.hasTag("shieldplatform"))
				{
					return true;
				}
			}

			return false;
		}

		if (blob.hasTag("migrant"))
		{
			return false;
		}

		const bool still = (this.getShape().vellen < 0.01f);

		if (this.isKeyPressed(key_down) &&
		        this.isOnGround() && still)
		{
			CShape@ s = blob.getShape();
			if (s !is null && !s.isStatic() &&
			        !blob.hasTag("ignore crouch"))
			{
				return false;
			}
		}

	}

	return true;
}

void hitTileBelow(CBlob@ this, Vec2f pos)
{
	CMap@ map = getMap();
	for (int i = -8; i < 12; i+=4)
	{
		for (int j = -8; j < 12; j+=4)
		{
			Vec2f at = pos + Vec2f(j,i);

			CBlob@ blob = map.getBlobAtPosition(at);
			if (blob !is null)
			{
				if (blob.hasTag("blocks sword") || blob.hasTag("blocks water") || blob.hasTag("door") || blob.hasTag("place norotate") || blob.getName() == "wooden_platform")
				this.server_Hit(blob, Vec2f(0,0), blob.getPosition(), 100.0f, 0);
			}

			Vec2f tileSpacePos = map.getTileSpacePosition(at);
			Tile tile = map.getTileFromTileSpace(tileSpacePos);
			if (map.isTileSolid(at))
			{
				if (tile.type == CMap::tile_bedrock && XORRandom(100) == 0)
					map.server_DestroyTile(at, 100000.0f);
				else if (tile.type != CMap::tile_bedrock)
					map.server_DestroyTile(at, 100.0f);
			}
			else
			{
				if (XORRandom(4) == 0)
					map.server_DestroyTile(at, 1.0f);
			}
		}
	}
}