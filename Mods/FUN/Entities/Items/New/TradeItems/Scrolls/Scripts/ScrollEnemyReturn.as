int teleportTargets = 1;
void onInit( CBlob@ this )
{
	this.addCommandID( "teleport enemies" );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("teleport enemies"), "Teleport one enemy.", params );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("teleport enemies"))
	{
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		ParticleZombieLightning( this.getPosition() );
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius( this.getPosition(), 80.0f, @blobsInRadius )) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (b.getTeamNum() != caller.getTeamNum() && b.hasTag("player") && b !is null)
				{
					CBlob@[] tents;
					getBlobsByName("tent", @tents);
					for (int n = 0; n < tents.length; n++)
					{
						if (tents[n] !is null && tents[n].getTeamNum() == b.getTeamNum())
						{
							if (b.isAttached() || b.hasAttached()) 
							{
								b.server_DetachAll();
								b.server_DetachFromAll();
							}
							b.setPosition(tents[n].getPosition());
							ParticleZombieLightning( caller.getPosition() ); 
						}
					}
					this.server_Die();
				}
			}
		}
		
	}
}