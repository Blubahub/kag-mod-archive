//builder HUD

#include "HumanoidCommon.as";

void ManageCursors(CBlob@ this)
{
	getHUD().SetDefaultCursor();
}

const Vec2f HUD = Vec2f(getScreenWidth()-(29*3+3*2),6);

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	if(getLocalPlayer() !is player)return;

	ManageCursors(blob);

	GUI::DrawIcon("BaseBodyParts.png", 0, Vec2f(29, 29), HUD, 1.5f);
	
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
	
		GUI::DrawIcon("HealthBarParts.png", frame, Vec2f(29, 7), Vec2f(HUD.x,HUD.y)+(Vec2f(0,29+i*5)*1.5f*2.0f), 1.5f);
		
		int HPFrame = 2;
		if(i > Health)HPFrame = 3;
		if(i >= MaxHealth-PermaDamage)HPFrame = 4;
		
		GUI::DrawIcon("HealthBarParts.png", HPFrame, Vec2f(29, 7), Vec2f(HUD.x,HUD.y)+(Vec2f(0,29+i*5)*1.5f*2.0f), 1.5f);
	
	}
	
	if(TorsoType >= 0){
		int frame = (1-(TorsoHealth/TorsoMaxHealth))*5.0f;
		if(TorsoHealth <= 0)frame = 5;
		GUI::DrawIcon("TorsoHealth.png", frame, Vec2f(29, 29), HUD, 1.5f);
	}
	
	if(MainArmType >= 0){
		int frame = (1-(MainArmHealth/MainArmMaxHealth))*5.0f;
		if(MainArmHealth <= 0)frame = 5;
		GUI::DrawIcon("MainArmHealth.png", frame, Vec2f(29, 29), HUD, 1.5f);
	}
	
	if(SubArmType >= 0){
		int frame = (1-(SubArmHealth/SubArmMaxHealth))*5.0f;
		if(SubArmHealth <= 0)frame = 5;
		GUI::DrawIcon("SubArmHealth.png", frame, Vec2f(29, 29), HUD, 1.5f);
	}
	
	if(FrontLegType >= 0){
		int frame = (1-(FrontLegHealth/FrontLegMaxHealth))*5.0f;
		if(FrontLegHealth <= 0)frame = 5;
		GUI::DrawIcon("FrontLegHealth.png", frame, Vec2f(29, 29), HUD, 1.5f);
	}
	
	if(BackLegType >= 0){
		int frame = (1-(BackLegHealth/BackLegMaxHealth))*5.0f;
		if(BackLegHealth <= 0)frame = 5;
		GUI::DrawIcon("BackLegHealth.png", frame, Vec2f(29, 29), HUD, 1.5f);
	}
}
