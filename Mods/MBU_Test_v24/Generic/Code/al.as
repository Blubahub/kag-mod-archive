

void onTick(CBlob@ this)
{
	if(this.get_u8("type") == 1){
		CBlob@[] blobs;	   
		getBlobsByName("gorb", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is null){
				if(this.getDistanceTo(b) < 128){
					Vec2f dir = (this.getPosition()+Vec2f(0,-64))-b.getPosition();
					dir.Normalize();
					b.setVelocity(b.getVelocity()/2.0f+dir*0.1f);
				}
			}
		}
	}
}