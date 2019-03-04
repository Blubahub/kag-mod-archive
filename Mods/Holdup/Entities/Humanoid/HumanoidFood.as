
#include "HumanoidCommon.as";

const f32 Scale = 1.0f;
const f32 PosScale = Scale*2.0f;

const Vec2f HUD = Vec2f(12,12);


void onTick(CBlob @this){

	this.getCurrentScript().tickFrequency = 30*18;

	u16 Starch = this.get_u8("food_starch");
	u16 Meat = this.get_u8("food_meat");
	u16 Plant = this.get_u8("food_plant");

	if(Meat >= Starch)if(Meat > 0)Meat -= 1;
	if(Plant >= Starch)if(Plant > 0)Plant -= 1;
	
	if(Starch > 0)Starch -= 1;

	this.set_u8("food_starch",Starch);
	this.set_u8("food_meat",Meat);
	this.set_u8("food_plant",Plant);
	
	if(getNet().isServer()){
		this.Sync("food_starch",true);
		this.Sync("food_meat",true);
		this.Sync("food_plant",true);
	}
	
	u16 TotalFood = Maths::Min(Meat,Plant);
	
	if(TotalFood >= 80){
		HealBody(this, 5);
	}
	
	if(this.isAttachedToPoint("BED")){
		if(TotalFood >= 60){
			HealBody(this, 5);
		}
	}
	
	if(TotalFood <= 20){
		StarveBody(this, 5);
	}
	
	if(!canBeHealed(this.get_s8("torso_type"))){
		this.RemoveScript("/HumanoidFood.as");
		if(this.getSprite() !is null)this.getSprite().RemoveScript("/HumanoidFood.as");
	}
}


void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	if(getLocalPlayer() !is player)return;
	
	u16 Starch = blob.get_u8("food_starch");
	u16 Meat = blob.get_u8("food_meat");
	u16 Plant = blob.get_u8("food_plant");
	
	if(Starch > 100)Starch = 100;
	if(Meat > 100)Meat = 100;
	if(Plant > 100)Plant = 100;

	GUI::DrawIcon("FoodBar.png", 0, Vec2f(32, 119), HUD, Scale);
	
	for(int i = 0;i < Plant;i++){
		if(i == 0)GUI::DrawIcon("FoodBar.png", 1, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,PosScale), Scale);
		GUI::DrawIcon("FoodBar.png", 2, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-i*(PosScale)), Scale);
		if(i == Plant-1)GUI::DrawIcon("FoodBar.png", 1, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-(i+1)*(PosScale)), Scale);
	}
	
	for(int i = 0;i < Starch;i++){
		if(i == 0)GUI::DrawIcon("FoodBar.png", 3, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,PosScale), Scale);
		GUI::DrawIcon("FoodBar.png", 4, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-i*(PosScale)), Scale);
		if(i == Starch-1)GUI::DrawIcon("FoodBar.png", 3, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-(i+1)*(PosScale)), Scale);
	}
	
	for(int i = 0;i < Meat;i++){
		if(i == 0)GUI::DrawIcon("FoodBar.png", 5, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,PosScale), Scale);
		GUI::DrawIcon("FoodBar.png", 6, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-i*(PosScale)), Scale);
		if(i == Meat-1)GUI::DrawIcon("FoodBar.png", 5, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-(i+1)*(PosScale)), Scale);
	}
	
	if(blob.isKeyPressed(keys::key_inventory)){
	
		GUI::DrawIcon("FoodBarHelp.png", 0, Vec2f(120, 120), HUD, Scale);
		
		SColor Text_colour(0xff130d1d);
		GUI::SetFont("menu");
		
		GUI::DrawText("Walking Speed", Vec2f(HUD.x,HUD.y)+Vec2f(33*PosScale,19*PosScale), Text_colour);
		GUI::DrawText("Health Regeneration", Vec2f(HUD.x,HUD.y)+Vec2f(33*PosScale,27*PosScale), Text_colour);
		
		GUI::DrawText("Running Speed", Vec2f(HUD.x,HUD.y)+Vec2f(33*PosScale,40*PosScale), Text_colour);
		GUI::DrawText("Health Regeneration\nin bed", Vec2f(HUD.x,HUD.y)+Vec2f(33*PosScale,47*PosScale), Text_colour);
		
		GUI::DrawText("Walking Speed", Vec2f(HUD.x,HUD.y)+Vec2f(33*PosScale,60*PosScale), Text_colour);
		
		GUI::DrawText("Slowed Speed", Vec2f(HUD.x,HUD.y)+Vec2f(33*PosScale,80*PosScale), Text_colour);
		
		GUI::DrawText("Crawling Speed", Vec2f(HUD.x,HUD.y)+Vec2f(33*PosScale,101*PosScale), Text_colour);
		GUI::DrawText("Starvation", Vec2f(HUD.x,HUD.y)+Vec2f(33*PosScale,109*PosScale), Text_colour);
	
	}
	
	GUI::DrawIcon("FoodBarCap.png", 0, Vec2f(32, 119), Vec2f(HUD.x,HUD.y)+Vec2f(0,-Maths::Min(Meat,Plant)*(PosScale)), Scale);
}
