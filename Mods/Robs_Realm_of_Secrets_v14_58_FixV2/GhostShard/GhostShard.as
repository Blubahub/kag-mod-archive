
void onTick(CSprite@ this)
{
	int clean = 0;
	if(this.getBlob().get_s16("corruption") > 250){
		clean = 1;
	}
	if(this.getBlob().get_s16("corruption") > 750){
		clean = 2;
	}
	this.SetFrame(clean);
}