#include "CustomBlocks.as"
#include "Hitters.as"

void onTick(CBlob@ this)
{
	f32 vely = this.getOldVelocity().y;

	if (vely > 0)
	{
		Vec2f pos = this.getPosition();
		CMap@ map = this.getMap();
		
		Vec2f[] vectors = {	pos + Vec2f(this.getShape().getConsts().radius-1, this.getShape().getConsts().radius+3),
									pos + Vec2f(0-this.getShape().getConsts().radius+1, this.getShape().getConsts().radius+3),
									pos + Vec2f(0, this.getShape().getConsts().radius+3)};
		bool hit = false;

		for (uint i = 0; i < 3; i++)
		{
			Vec2f temp = vectors[i];
			if (map.getTile(temp).type == CMap::tile_ice_spike || map.getTile(temp).type == CMap::tile_ice_spike_v0)
			{
				map.server_DestroyTile(temp, 1.0f);
				hit = true;
			}
		}

		if (hit) this.server_Hit(this, pos, this.getOldVelocity(), 1.0f, Hitters::spikes);
	}
	return;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (solid && blob is null)
	{
		f32 vely = this.getOldVelocity().y;

		if (vely > 3.0f)
		{
			Vec2f pos = this.getPosition();
			Vec2f oldvel = this.getOldVelocity();
			CMap@ map = this.getMap();
			bool addvel = false;
			Vec2f[] vectors = {	pos + Vec2f(0, this.getShape().getConsts().radius+5),
								pos + Vec2f(8, this.getShape().getConsts().radius+5),
								pos + Vec2f(-8, this.getShape().getConsts().radius+5),};

			if (isTileIce(map.getTile(vectors[0]).type))
			{
				map.server_DestroyTile(vectors[0], 1.0f);
				addvel = true;
			}
			if (isTileIce(map.getTile(vectors[1]).type))
			{
				map.server_DestroyTile(vectors[1], 1.0f);
			}
			if (isTileIce(map.getTile(vectors[2]).type))
			{
				map.server_DestroyTile(vectors[2], 1.0f);
			}
			if(addvel)
			this.setVelocity(oldvel);
		}
	}
}
