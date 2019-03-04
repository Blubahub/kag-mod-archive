// scroll script that makes enemies insta gib within some radius

#include "Hitters.as";

void onInit( CBlob@ this )
{
	this.addCommandID( "transform" );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("transform"), "Transform fishes into sharks in 30 blocks radius .", params );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("transform"))
	{
		ParticleZombieLightning( this.getPosition() );

		bool hit = false;
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if (caller !is null)
		{
			const int team = caller.getTeamNum();
			CBlob@[] blobsInRadius;	 
			
			if (this.getMap().getBlobsInRadius( this.getPosition(), 240.0f, @blobsInRadius )) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					if (b.getTeamNum() == this.getTeamNum())
					{
						b.server_Heal(10.0f);
						hit = true;
					}
				}
			}
		}

		if (hit)
		{
			this.server_Die();
		}
	}
}