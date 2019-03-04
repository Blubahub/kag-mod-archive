
void onInit(CBlob @ this){
	this.set_u8("MaxLevel",3);
}


void onTick(CBlob @ this)
{
	if(getGameTime() % 30 == 0)giveOxygen(this);
}

void giveOxygen(CBlob @ this){
	CBlob@[] blobs;
	
	getMap().getBlobsInRadius(this.getPosition(), 160, @blobs);

	for (u32 k = 0; k < blobs.length; k++)
	{
		CBlob@ blob = blobs[k];
		if(blob.hasTag("room")){
			if(!blob.hasTag("leaking")){
				if(blob.get_u16("oxygen") <= 1000.0-100.0*this.get_f32("Power"))blob.set_u16("oxygen",blob.get_u16("oxygen")+100.0*this.get_f32("Power"));
				else blob.set_u16("oxygen",1000);
				
			}
		}
	}
}