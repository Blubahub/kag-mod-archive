
void onTick(CBlob@ this){
	if(this.hasTag("death_ability") && this.hasTag("soul")){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null && b.getName() == "e")
				if(b.get_u16("created") < getGameTime()-60 && !b.hasTag("taken")){
					Vec2f vec = this.getPosition()-b.getPosition();
					vec.Normalize();
					f32 force = 1.0f-(this.getDistanceTo(b)/160.0f);
					b.setVelocity(b.getVelocity()*0.99f);
					b.AddForce(vec*force*2.0f);
					
					b.server_SetTimeToDie(30);
					
					if(this.getDistanceTo(b) < 8){
						this.add_s16("death_amount", b.get_u8("worth"));
						b.Tag("taken");
						if(getNet().isServer()){
							this.Sync("death_amount",true);
							b.server_Die();
						}
					}
				}
			}
		}
	}
}