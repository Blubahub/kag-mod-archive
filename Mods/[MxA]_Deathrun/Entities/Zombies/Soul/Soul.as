const array <SColor> teamColor = {SColor(255, 26, 78, 131), SColor(255, 148, 27, 27),
					  			  SColor(255, 51, 102, 13), SColor(255, 98, 26, 131),
							  	  SColor(255, 132, 71, 21), SColor(255, 43, 83, 83),
					  			  SColor(255, 42, 48, 132), SColor(255, 100, 113, 96)};

int tick;

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(teamColor[this.getTeamNum()]);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.set_string("player", "");
	tick = -1;
}

void onTick(CBlob@ this)
{
	if(this.get_string("player") == "")
		return;

	CPlayer@ player = getPlayerByUsername(this.get_string("player"));
	if(player is null)
		return;

	if(player.getBlob() is null)
		return;

	if(this.getTeamNum() == player.getBlob().getTeamNum() or this.getTeamNum() == 7)
	{
		if(this.getTeamNum() == 7)
		{
			if(tick == -1)
				tick = XORRandom(100)+50;
			else
				tick--;

			if(tick == 0)
			{
				this.SetVisible(false);
				this.SetLight(false);
			}
		}
		if(tick != -1 and this.getTeamNum() == player.getBlob().getTeamNum())
		{
			this.SetVisible(true);
			tick = -1;
			this.SetLight(true);
		}
		Vec2f pos = player.getBlob().getPosition();
		pos.y -= 16;
		Tile block;
		block.type = getMap().getTile(pos).type;
		if( block.type == CMap::tile_empty or
			block.type == CMap::tile_castle_back or
			block.type == CMap::tile_castle_back_moss or
			block.type == CMap::tile_wood_back or
			block.type == CMap::tile_ground_back)
			this.setPosition(pos);
		else
			this.setPosition(player.getBlob().getPosition());
	}
	else
	{
		Vec2f ppos = player.getBlob().getPosition(), bpos = this.getPosition();
		float r = 2;
		Vec2f vel;
		if(ppos.x > bpos.x)
			vel.x = 1;
		else
			vel.x = -1;

		if(ppos.y > bpos.y)
			vel.y = 1;
		else
			vel.y = -1;

		this.setVelocity(vel);
		if(ppos.x+r > bpos.x and ppos.x-r < bpos.x and ppos.y+r > bpos.y and ppos.y-r < bpos.y)
		{
			this.server_SetTimeToDie(1);
			this.server_Hit(player.getBlob(), this.getPosition(), Vec2f(0, 0), 50.0f, 0, true);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	return 0;
}
