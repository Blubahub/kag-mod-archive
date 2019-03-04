//builder HUD

#include "HumanoidCommon.as";

void ManageCursors(CBlob@ this)
{
	getHUD().SetDefaultCursor();
}

const f32 Scale = 2.0f;

const Vec2f HUD = Vec2f(getScreenWidth()-(29*2*Scale+3*Scale),3*Scale);

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	if(getLocalPlayer() !is player)return;

	ManageCursors(blob);

	GUI::DrawIcon("BaseBodyParts.png", 0, Vec2f(29, 29), HUD, Scale);
	
	int TorsoType = blob.get_s8("torso_type");
	int FrontLegType = blob.get_s8("front_leg_type");
	int BackLegType = blob.get_s8("back_leg_type");
	int MainArmType = blob.get_s8("main_arm_type");
	int SubArmType = blob.get_s8("sub_arm_type");
	
	f32 TorsoHealth = blob.get_f32("torso_hp");
	f32 FrontLegHealth = blob.get_f32("front_leg_hp");
	f32 BackLegHealth = blob.get_f32("back_leg_hp");
	f32 MainArmHealth = blob.get_f32("main_arm_hp");
	f32 SubArmHealth = blob.get_f32("sub_arm_hp");
	
	f32 TorsoMaxHealth = bodyPartMaxHealth(blob,"torso");
	f32 FrontLegMaxHealth = bodyPartMaxHealth(blob,"front_leg");
	f32 BackLegMaxHealth = bodyPartMaxHealth(blob,"back_leg");
	f32 MainArmMaxHealth = bodyPartMaxHealth(blob,"main_arm");
	f32 SubArmMaxHealth = bodyPartMaxHealth(blob,"sub_arm");
	
	int MaxHealth = (TorsoMaxHealth+FrontLegMaxHealth+BackLegMaxHealth+MainArmMaxHealth+SubArmMaxHealth)/10;
	int Health = 0;
	int PermaDamage = 0;
	
	if(TorsoHealth > 0)Health += TorsoHealth;
	if(FrontLegHealth > 0)Health += FrontLegHealth;
	if(BackLegHealth > 0)Health += BackLegHealth;
	if(MainArmHealth > 0)Health += MainArmHealth;
	if(SubArmHealth > 0)Health += SubArmHealth;
	
	if(TorsoHealth <= 0)PermaDamage += TorsoMaxHealth;
	if(FrontLegHealth <= 0)PermaDamage += FrontLegMaxHealth;
	if(BackLegHealth <= 0)PermaDamage += BackLegMaxHealth;
	if(MainArmHealth <= 0)PermaDamage += MainArmMaxHealth;
	if(SubArmHealth <= 0)PermaDamage += SubArmMaxHealth;
	
	Health = Health/10;
	PermaDamage = PermaDamage/10;
	
	for(int i = 0; i < MaxHealth; i += 1){
	
		int frame = 0;
		if(i+1 >= MaxHealth)frame = 1;
	
		GUI::DrawIcon("HealthBarParts.png", frame, Vec2f(29, 7), Vec2f(HUD.x,HUD.y)+(Vec2f(0,29+i*5)*Scale*2.0f), Scale);
		
		int HPFrame = 2;
		if(i > Health)HPFrame = 3;
		if(i >= MaxHealth-PermaDamage)HPFrame = 4;
		
		GUI::DrawIcon("HealthBarParts.png", HPFrame, Vec2f(29, 7), Vec2f(HUD.x,HUD.y)+(Vec2f(0,29+i*5)*Scale*2.0f), Scale);
	
	}
	
	f32 torsoHurt = blob.get_f32("torso_hit");
	f32 mainArmHurt = blob.get_f32("main_arm_hit");
	f32 subArmHurt = blob.get_f32("sub_arm_hit");
	f32 frontLegHurt = blob.get_f32("front_leg_hit");
	f32 backLegHurt = blob.get_f32("back_leg_hit");
	
	if(TorsoType >= 0){
		int frame = (1-(TorsoHealth/TorsoMaxHealth))*5.0f;
		if(TorsoHealth <= 0)frame = 5;
		GUI::DrawIcon("TorsoHealth.png", frame, Vec2f(29, 29), HUD, Scale);
		SColor torso_colour(0xffff0000);
		torso_colour.setAlpha(255*torsoHurt);
		GUI::DrawIcon("TorsoHealth.png", 4, Vec2f(29, 29), HUD, Scale, torso_colour);
	}
	
	if(MainArmType >= 0){
		int frame = (1-(MainArmHealth/MainArmMaxHealth))*5.0f;
		if(MainArmHealth <= 0)frame = 5;
		GUI::DrawIcon("MainArmHealth.png", frame, Vec2f(29, 29), HUD, Scale);
		SColor MArm_colour(0xffff0000);
		MArm_colour.setAlpha(255*mainArmHurt);
		GUI::DrawIcon("MainArmHealth.png", 4, Vec2f(29, 29), HUD, Scale, MArm_colour);
	}
	
	if(SubArmType >= 0){
		int frame = (1-(SubArmHealth/SubArmMaxHealth))*5.0f;
		if(SubArmHealth <= 0)frame = 5;
		GUI::DrawIcon("SubArmHealth.png", frame, Vec2f(29, 29), HUD, Scale);
		SColor SArm_colour(0xffff0000);
		SArm_colour.setAlpha(255*subArmHurt);
		GUI::DrawIcon("SubArmHealth.png", 4, Vec2f(29, 29), HUD, Scale, SArm_colour);
	}
	
	if(FrontLegType >= 0){
		int frame = (1-(FrontLegHealth/FrontLegMaxHealth))*5.0f;
		if(FrontLegHealth <= 0)frame = 5;
		GUI::DrawIcon("FrontLegHealth.png", frame, Vec2f(29, 29), HUD, Scale);
		SColor FLeg_colour(0xffff0000);
		FLeg_colour.setAlpha(255*frontLegHurt);
		GUI::DrawIcon("FrontLegHealth.png", 4, Vec2f(29, 29), HUD, Scale, FLeg_colour);
	}
	
	if(BackLegType >= 0){
		int frame = (1-(BackLegHealth/BackLegMaxHealth))*5.0f;
		if(BackLegHealth <= 0)frame = 5;
		GUI::DrawIcon("BackLegHealth.png", frame, Vec2f(29, 29), HUD, Scale);
		SColor BLeg_colour(0xffff0000);
		BLeg_colour.setAlpha(255*backLegHurt);
		GUI::DrawIcon("BackLegHealth.png", 4, Vec2f(29, 29), HUD, Scale, BLeg_colour);
	}
}
