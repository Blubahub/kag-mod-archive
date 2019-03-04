
void onTick(CBlob @ this){

	f32 grav = getRules().get_f32("gravity");
	
	if(!getNet().isServer())if(grav < 1.5)grav = grav*3;
	
	if(this.hasTag("gravity_field") || this.getName() == "floatkeg" || this.getName() == "floatbomb")return;
	
	this.getShape().SetGravityScale((getRules().get_f32("gravity")+grav)/4.0f);

	CBlob@[] blobs;
	
	getBlobsByTag("gravity_field", blobs);
	
	for (u32 k = 0; k < blobs.length; k++)
	{
		CBlob@ blob = blobs[k];
		if(Maths::Sqrt(Maths::Pow(this.getPosition().x-blob.getPosition().x, 2)+Maths::Pow(this.getPosition().y-blob.getPosition().y, 2)) < blob.get_u16("field_size")){
			this.getShape().SetGravityScale(-1);
		}
	}


}