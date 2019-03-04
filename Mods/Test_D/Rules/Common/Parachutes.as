#include "ParachuteCommon.as";
#include "SoldierCommon.as";

int _randomOffset;

void onInit()
{
	Random random(Time());
	_randomOffset = random.NextRanged(100000);
}

void onTick(CRules@ this)
{
    CBlob@[] blobs;
    getBlobsByName( "soldier", @blobs ); // OPTIMIZATION HACK!
    getBlobsByName( "supply", @blobs );
    getBlobsByTag( "pet", @blobs );

    for (uint i=0; i < blobs.length; i++) 
    {
        CBlob@ b = blobs[i];
        CSprite@ s = b.getSprite();
        const bool para = b.hasTag("parachute");

        // remove

		if (b.isOnMap() || b.isAttached() || b.isOnLadder())
		{
			if (para){
				RemoveParachute( b );
			}
		}
		else // update
		if (para)
		{
			Vec2f vel = b.getVelocity();
			if (vel.y > 1.0f)
			{
				b.AddForce(Vec2f(Maths::Sin((getGameTime()+_randomOffset) / 31.0f) * 0.01f, -(vel.y - 1.0f)) * b.getMass() * 0.9f);
			}
		}         

        // add / remove layer

		if (s.getSpriteLayer(layername) is null)
		{
	        if (para)
	        {
				CSpriteLayer@ para = s.addSpriteLayer(layername, "powerup_parachute.png" , 32, 32);
				if (para !is null)
				{
					para.SetRelativeZ(-10.0f);
					para.SetOffset(Vec2f(0, -5));
					s.PlaySound("SupplyDrop");
				}
	        }			
		}        
        else {
        	if (!para)
        	{
        		s.RemoveSpriteLayer(layername);
        	}
        }       
    }
}