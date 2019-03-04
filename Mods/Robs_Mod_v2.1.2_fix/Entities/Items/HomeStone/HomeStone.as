/* ScrollReturning.as
 * Original author: Aphelion (scroll of returning)
 * Edited by: Pirate-Rob
 * Shame on me(Rob) for using this as a base
 */

void onInit( CBlob@ this )
{
	this.addCommandID("tp home");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("tp home"), "Teleports you to your team's tent", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("tp home"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
            CBlob@[] tents;
            getBlobsByName("hall", @tents);
			getBlobsByName("tent", @tents);
			for(uint i = 0; i < tents.length; i++)
			{
			    if(tents[i].getTeamNum() == caller.getTeamNum())
				{
					caller.setPosition(tents[i].getPosition());
					caller.setVelocity( Vec2f_zero );			  
					caller.getShape().PutOnGround();
					
					break;
				}
			}
		}
		
	}
}
