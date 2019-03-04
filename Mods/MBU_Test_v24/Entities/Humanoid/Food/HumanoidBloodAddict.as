
#include "HumanoidCommon.as";

const f32 Scale = 1.0f;
const f32 PosScale = Scale*2.0f;

const Vec2f HUD = Vec2f(12,12+PosScale*32+12);


void onTick(CBlob @this){

	{
		this.Tag("does_not_eat");
		this.Tag("blood_addict");
		this.Tag("blood_sight");
		if(this.getSprite() !is null)this.getSprite().RemoveScript("/HumanoidFood.as");
		this.RemoveScript("/HumanoidFood.as");
	}

	this.getCurrentScript().tickFrequency = 30*18;

	u16 Blood = this.get_u8("food_blood");
	
	if(Blood > 0){
		this.sub_u8("food_blood",1);
	}
	
	if(getNet().isServer()){
		this.Sync("food_blood",true);
	}

	if(Blood >= 50){
		HealBody(this, 5);
	}
	
	if(this.isAttachedToPoint("BED")){
		if(Blood >= 25){
			HealBody(this, 5);
		}
	}
	
	if(Blood <= 10){
		StarveBody(this, 8);
	}
}


void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	if(getLocalPlayer() !is player)return;
	
	u16 Blood = blob.get_u8("food_blood");
	
	if(Blood > 100)Blood = 100;

	GUI::DrawIcon("BloodFoodBar.png", 0, Vec2f(22, 119), HUD, Scale);
	
	if(Blood < 10)if(getGameTime() % 20 < 10)GUI::DrawIcon("BloodFoodBar.png", 1, Vec2f(22, 119), HUD, Scale);
	
	for(int i = 0;i < Blood;i++){
		if(i == 0)GUI::DrawIcon("BloodFoodBar.png", 3, Vec2f(22, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,PosScale), Scale);
		GUI::DrawIcon("BloodFoodBar.png", 2, Vec2f(22, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-i*(PosScale)), Scale);
		if(i == Blood-1)GUI::DrawIcon("BloodFoodBar.png", 3, Vec2f(22, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-(i+1)*(PosScale)), Scale);
	}
}
