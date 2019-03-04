// draws a health bar on mouse hover

void onInit(CBlob@ this)
{
	this.set_s16("crown_amount",0);
}

void onRender(CSprite@ this)
{
	
	CBlob@ blob = this.getBlob();
	
	f32 Amount = blob.get_s16("crown_amount");
	f32 Max = 500;
	
	Vec2f center = blob.getPosition();
	Vec2f pos2d = blob.getScreenPos() + Vec2f(0, 20);
	Vec2f dim = Vec2f(24, 8);
	const f32 y = blob.getHeight() * 2.4f;
	if(!blob.hasTag("dead")){
		if (Max > 0.0f)
		{
			f32 perc = Amount / Max;
			if(perc > 1)perc = 1;
			if (perc >= 0.0f)
			{
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 2), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y + 2));
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y + 2), Vec2f(pos2d.x - dim.x + perc * 2.0f * dim.x - 2, pos2d.y + y + dim.y - 2), SColor(0xffD4AF37));
			}
		}
	}
}

void onTick(CBlob@ this)
{
	CBlob@ carried = this.getCarriedBlob();
	
	if(carried !is null){
		if(carried.getName() == "crown"){
			this.set_s16("crown_amount",this.get_s16("crown_amount")+1);
		}
	}
}