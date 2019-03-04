#include "SoldierCommon.as"
#include "PlayerStatsCommon.as"

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	if(map is null) return;

	f32 offset = (map.tilemapwidth-2) * map.tilesize - 2.0f;

	CBlob@[] blobs;
	getBlobs(@blobs);
	for(uint i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		Vec2f pos = b.getPosition();
		if(pos.x < map.tilesize)
		{
			pos.x += offset;
			b.setPosition(pos);
			StatMapLoop(b);
		}
		else if(pos.x > (map.tilemapwidth-1)*map.tilesize)
		{
			pos.x -= offset;
			b.setPosition(pos);
			StatMapLoop(b);
		}

		// wrap cursor
		// if (b.getName() == "soldier"){
		// 	Soldier::Data@ data = Soldier::getData( b );
		// 	if (data.crosshairMaxDist > 300.0f)
		// 	{
		// 		Vec2f cursorPos = data.pos + data.crosshairOffset;
		// 		if(cursorPos.x < map.tilesize)
		// 		{
		// 			cursorPos.x += offset;
		// 			data.crosshairOffset = cursorPos - data.pos;
		// 		}
		// 		else if(cursorPos.x > (map.tilemapwidth-1)*map.tilesize)
		// 		{
		// 			cursorPos.x -= offset;
		// 			data.crosshairOffset = cursorPos - data.pos;
		// 		}			
		// 	}
		// }
	}
}

void StatMapLoop(CBlob @blob)
{
	if (blob.getPlayer() is null)
		return;

	Stats@ stats = getStats(blob.getPlayer());
	if (stats is null)
		return;

	if (blob.hasTag("dead")){
		stats.screenWraps++;
	}
}