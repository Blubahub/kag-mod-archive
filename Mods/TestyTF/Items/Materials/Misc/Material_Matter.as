#include "Hitters.as";
#include "Explosion.as";
#include "LoaderUtilities.as";

// void onInit(CBlob@ this)
// {
	// this.set_string("custom_explosion_sound", "KegExplosion");
// }

// void DoExplosion(CBlob@ this, Vec2f velocity)
// {
	// if (this.hasTag("dead")) return;
	// this.Tag("dead");

	// f32 quantity = this.getQuantity();
		
	// for (int i = 0; i < 2 + XORRandom(3); i++)
	// {
		// Vec2f dir = Vec2f((100 - XORRandom(200)) / 100.0f, (100 - XORRandom(200)) / 100.0f);
		// // print("x: " + dir.x + "; y: " + dir.y);
		// LinearExplosion(this, dir, 1.1f * quantity, 0.2f * quantity, 4, 8.0f, Hitters::explosion);
	// }

	// this.server_Die();
	// this.getSprite().Gib();
// }

// f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
// {
	// if (customData == Hitters::fire || customData == Hitters::burn || customData == Hitters::bomb || customData == Hitters::explosion || customData == Hitters::keg)
	// {
		// print("boom");
		// DoExplosion(this, velocity);
	// }

	// return damage;
// }

// bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
// {
	// print("" + blob.getMass());

	// if (blob !is null)
	// {	
		// return this.getQuantity() > blob.getMass() * 2;
	// }
	// else return false;
// }

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	// if (blob !is null && this.getQuantity() > blob.getMass() * 2)
	// {
		// CBlob@ dust = server_CreateBlob("mat_matter", this.getTeamNum(), point1);
		// dust.server_SetQuantity(Maths::Max(0, blob.getMass() * 0.5f));
		
		// blob.server_Die();
	// }
	if (blob is null)
	{	
		CMap@ map = getMap();
		Vec2f pos = point2 - (normal * 4);
		Tile tile = map.getTile(pos);
		u16 type = tile.type;

		if (!map.isTileBedrock(type) && map.isTileSolid(pos) && (type < CMap::tile_matter || type > CMap::tile_matter_d2)) 
		{
			map.server_SetTile(pos, CMap::tile_matter);
			this.server_SetQuantity(Maths::Max(0, int(this.getQuantity()) - 1 - XORRandom(15)));
		}
	}
}