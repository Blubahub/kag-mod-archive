void onInit( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	
	::int num = XORRandom(5);
	
	if (blob.isInWater()) this.SetAnimation("inwater" + num);
	else this.SetAnimation("notinwater" + num);
	
	blob.set_u32("water plant type", num);
}

void onTick( CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	int num = blob.get_u32("water plant type");
	
	if (blob.isInWater()) this.SetAnimation("inwater" + num);
	else this.SetAnimation("notinwater" + num);
}