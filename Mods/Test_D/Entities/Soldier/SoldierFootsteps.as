#define CLIENT_ONLY

#include "SoldierCommon.as"
#include "MapCommon.as"
#include "LoadMapUtils.as"; // FUCK

void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_not_inwater;
}

void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    if (blob.isOnGround() || blob.wasOnGround())
    {
		Soldier::Data@ data;
		blob.get( "data", @data );
		if(data is null)
			return;

    	f32 vellen = blob.getShape().vellen;

    	if (data.dead || data.stunned)
    	{
    		if (blob.isOnGround() && !blob.wasOnGround() && vellen > 1.5f)
    		{
    			this.PlayRandomSound("BodyFall", Maths::Min( 0.2f + vellen, 1.0f ) );
    		}
    	}
    	else
    	{
	    	const bool moving = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));

	    	if (!blob.isOnWall())
	    	{
				if (( (blob.isOnGround() && !blob.wasOnGround())
					|| (!blob.isOnGround() && blob.wasOnGround())
					|| (vellen > 1.5f && (blob.getNetworkID() + getGameTime()) % (Maths::Ceil(vellen)*3) == 0)) )
				{
					f32 volume = 0.25f;

					TileType groundtile = blob.getMap().getTile( blob.getPosition() + Vec2f( 0.0f, blob.getRadius() + 4.0f )).type;
					if (groundtile == 0)
						 groundtile = blob.getMap().getTile( blob.getPosition() + Vec2f( 0.0f, blob.getRadius() + 8.0f )).type;
					TileType backtile = blob.getMap().getTile( blob.getPosition() ).type;

					if (TWMap::isTileBush(backtile)) {
						this.PlayRandomSound("BushStep", volume*2.0f );
					}
					else if (TWMap::isTileGrass(groundtile)){ // grass
						this.PlayRandomSound("GrassStep", volume );
					}
					else if (TWMap::isTileStone(groundtile)) {
						this.PlayRandomSound("ConcreteStep", volume );
					}
					else if (TWMap::isTileWood(groundtile)) {
						this.PlayRandomSound("WoodStep", volume*1.75f );
					}
					else { // ground
						this.PlayRandomSound("RubbleStep", volume );
					}
				}
			}

			if (moving && data.ledgeClimb && !data.oldLedgeClimb)
			{
				this.PlayRandomSound("Climb", 0.5f );
			}

			if (data.sliding && !data.oldSliding && vellen > 1.0f)
			{
				this.PlaySound("Slide", 0.35f);
			}
		}
    }
}
