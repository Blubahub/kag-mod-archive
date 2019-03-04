
void onTick(CBlob @ this){

	this.getShape().SetGravityScale(0);

	CBlob@[] blobs;
	
	getBlobsByName("gravity_generator", blobs);
	
	for (u32 k = 0; k < blobs.length; k++)
	{
		CBlob@ blob = blobs[k];
		if(Maths::Sqrt(Maths::Pow(this.getPosition().x-blob.getPosition().x, 2)+Maths::Pow(this.getPosition().y-blob.getPosition().y, 2)) < 64){
			this.getShape().SetGravityScale(1);
		}
	}


}