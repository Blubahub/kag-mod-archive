// Blob merging   // requires set_u16("max");

#define SERVER_ONLY

void onInit( CBlob@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_onground;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 49;			 
}

void onTick( CBlob@ this )
{
    if (this.isInInventory()) {
        return;
    }				  
    if (this.getQuantity() < this.maxQuantity )
    {
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius( this.getPosition(), this.getRadius()*6.0f, @blobsInRadius )) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @blob = blobsInRadius[i];

				if (blob !is this && blob.isOnGround() &&
					!blob.isAttached() && !blob.isInInventory() &&
					blob.getQuantity() < blob.maxQuantity &&
					blob.getName() == this.getName() &&
					!blob.hasTag("merged")
					) // same name = merge
				{
					if (this.getQuantity() < blob.getQuantity())
					{
						blob.server_SetQuantity( blob.getQuantity() + this.getQuantity() );
						this.server_Die();
						this.Tag("merged");
					}
					else
					{
						this.server_SetQuantity( blob.getQuantity() + this.getQuantity() );
						blob.server_Die();
						blob.Tag("merged");
					}

					return; // one at a time
				}
			}
        }
    }
}

