#include "Explosion.as";

void onInit( CBlob@ this )
{
	this.addCommandID("usesword");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("usesword"), "Be overcome with darkness!", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("usesword"))
	{
		
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			int bodies = 0;
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if    (b.hasTag("dead"))
					{
						bodies += 1;
						b.server_Die();
					}
				}
			}
			if(bodies > 0){
				CBlob @newBlob = server_CreateBlob("darkbeing", 9, this.getPosition());
				if (newBlob !is null)
				{
					// plug the soul
					newBlob.server_SetPlayer(caller.getPlayer());
					newBlob.setPosition(caller.getPosition());

					// no extra immunity after class change
					if (caller.exists("spawn immunity time"))
					{
						newBlob.set_u32("spawn immunity time", caller.get_u32("spawn immunity time"));
						newBlob.Sync("spawn immunity time", true);
					}

					if (caller.exists("knocked"))
					{
						newBlob.set_u8("knocked", caller.get_u8("knocked"));
						newBlob.Sync("knocked", true);
					}
					
					newBlob.set_s16("power",bodies*20);
					
					this.getSprite().PlaySound("/Thunder1", 2.0f, 0.70f); // TFlippy

					caller.Tag("switch class");
					caller.server_SetPlayer(null);
					caller.server_Die();
					this.server_Die();
				}
			}
		}
		
	}
}
