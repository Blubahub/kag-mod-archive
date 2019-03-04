//builder HUD

#include "HumanoidCommon.as";
#include "EquipCommon.as";

void ManageCursors(CBlob@ this)
{
	getHUD().SetDefaultCursor();
}

const f32 Scale = 1.0f;
const f32 PosScale = Scale*2.0f;

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	if(getLocalPlayer() !is player)return;
	
	Vec2f HUD = Vec2f(getScreenWidth()-(170*PosScale+12),12);

	ManageCursors(blob);

	GUI::DrawIcon("BaseHPHUD.png", 0, Vec2f(170, 128), HUD, Scale);
	
	SColor Text_colour(0xff130d1d);
	GUI::SetFont("menu");
	
	GUI::DrawText("Body", Vec2f(HUD.x,HUD.y)+Vec2f(128*PosScale,4*PosScale), Text_colour);
	GUI::DrawText("Armour", Vec2f(HUD.x,HUD.y)+Vec2f(61*PosScale,4*PosScale), Text_colour);
	GUI::DrawText("Soul", Vec2f(HUD.x,HUD.y)+Vec2f(8*PosScale,4*PosScale), Text_colour);
	
	
	int HeadType = blob.get_s8("head_type")+1;
	int TorsoType = blob.get_s8("torso_type")+1;
	int MainArmType = blob.get_s8("main_arm_type")+1;
	int SubArmType = blob.get_s8("sub_arm_type")+1;
	int FrontLegType = blob.get_s8("front_leg_type")+1;
	int BackLegType = blob.get_s8("back_leg_type")+1;
	
	
	GUI::DrawIcon("HeadHUD.png", HeadType, Vec2f(13, 14), HUD+Vec2f(131*PosScale,12*PosScale), Scale);
	GUI::DrawIcon("TorsoHUD.png", TorsoType, Vec2f(13, 14), HUD+Vec2f(131*PosScale,24*PosScale), Scale);
	
	GUI::DrawIcon("MainArmHUD.png", MainArmType, Vec2f(7, 15), HUD+Vec2f(125*PosScale,25*PosScale), Scale);
	GUI::DrawIcon("SubArmHUD.png", SubArmType, Vec2f(7, 15), HUD+Vec2f(143*PosScale,25*PosScale), Scale);
	
	GUI::DrawIcon("FrontLegHUD.png", FrontLegType, Vec2f(8, 12), HUD+Vec2f(130*PosScale,37*PosScale), Scale);
	GUI::DrawIcon("BackLegHUD.png", BackLegType, Vec2f(8, 12), HUD+Vec2f(137*PosScale,37*PosScale), Scale);
	
	
	
	
	
	
	int TorsoHealth = blob.get_f32("torso_hp");
	int FrontLegHealth = blob.get_f32("front_leg_hp");
	int BackLegHealth = blob.get_f32("back_leg_hp");
	int MainArmHealth = blob.get_f32("main_arm_hp");
	int SubArmHealth = blob.get_f32("sub_arm_hp");
	
	int TorsoMaxHealth = bodyPartMaxHealth(blob,"torso");
	int FrontLegMaxHealth = bodyPartMaxHealth(blob,"front_leg");
	int BackLegMaxHealth = bodyPartMaxHealth(blob,"back_leg");
	int MainArmMaxHealth = bodyPartMaxHealth(blob,"main_arm");
	int SubArmMaxHealth = bodyPartMaxHealth(blob,"sub_arm");
	
	
	if(TorsoType != 0 && TorsoType != 2)GUI::DrawText(""+TorsoHealth, Vec2f(HUD.x,HUD.y)+Vec2f(157*PosScale,12*PosScale), Text_colour);
	if(SubArmType != 0 && SubArmType != 2)GUI::DrawText(""+SubArmHealth, Vec2f(HUD.x,HUD.y)+Vec2f(157*PosScale,25*PosScale), Text_colour);
	if(BackLegType != 0 && BackLegType != 2)GUI::DrawText(""+BackLegHealth, Vec2f(HUD.x,HUD.y)+Vec2f(157*PosScale,40*PosScale), Text_colour);
	
	if(MainArmType != 0 && MainArmType != 2)GUI::DrawText(""+MainArmHealth, Vec2f(HUD.x,HUD.y)+Vec2f(108*PosScale,25*PosScale), Text_colour);
	if(FrontLegType != 0 && FrontLegType != 2)GUI::DrawText(""+FrontLegHealth, Vec2f(HUD.x,HUD.y)+Vec2f(108*PosScale,40*PosScale), Text_colour);
	
	int TorsoHeart = 0;
	int MainArmHeart = 0;
	int SubArmHeart = 0;
	int FrontLegHeart = 0;
	int BackLegHeart = 0;
	
	if(TorsoHealth <= 0)TorsoHeart = 1;
	if(MainArmHealth <= 0)MainArmHeart = 1;
	if(SubArmHealth <= 0)SubArmHeart = 1;
	if(FrontLegHealth <= 0)FrontLegHeart = 1;
	if(BackLegHealth <= 0)BackLegHeart = 1;
	
	if(TorsoType == 0 || TorsoType == 2)TorsoHeart = 2;
	if(MainArmType == 0 || MainArmType == 2)MainArmHeart = 2;
	if(SubArmType == 0 || SubArmType == 2)SubArmHeart = 2;
	if(FrontLegType == 0 || FrontLegType == 2)FrontLegHeart = 2;
	if(BackLegType == 0 || BackLegType == 2)BackLegHeart = 2;
	
	GUI::DrawIcon("HeartHUD.png", TorsoHeart, Vec2f(7, 7), HUD+Vec2f(150*PosScale,12*PosScale), Scale);
	GUI::DrawIcon("HeartHUD.png", SubArmHeart, Vec2f(7, 7), HUD+Vec2f(150*PosScale,25*PosScale), Scale);
	GUI::DrawIcon("HeartHUD.png", BackLegHeart, Vec2f(7, 7), HUD+Vec2f(150*PosScale,40*PosScale), Scale);
	
	GUI::DrawIcon("HeartHUD.png", MainArmHeart, Vec2f(7, 7), HUD+Vec2f(118*PosScale,25*PosScale), Scale);
	GUI::DrawIcon("HeartHUD.png", FrontLegHeart, Vec2f(7, 7), HUD+Vec2f(118*PosScale,40*PosScale), Scale);
	
	
	
	CBlob @helmet = getEquippedBlob(blob,"head");
	f32 helmet_def = 0;
	string helmet_type = "none";
	CBlob @breastplate = getEquippedBlob(blob,"torso");
	f32 breastplate_def = 0;
	string breastplate_type = "none";
	CBlob @leggings = getEquippedBlob(blob,"legs");
	f32 leggings_def = 0;
	string leggings_type = "none";
	
	if(helmet !is null){
		helmet_def = helmet.get_u8("defense");
		helmet_type = helmet.getName();
	}
	if(breastplate !is null){
		breastplate_def = breastplate.get_u8("defense");
		breastplate_type = breastplate.getName();
	}
	if(leggings !is null){
		leggings_def = leggings.get_u8("defense");
		leggings_type = leggings.getName();
	}

	GUI::DrawText(""+helmet_def, Vec2f(HUD.x,HUD.y)+Vec2f(51*PosScale,13*PosScale), Text_colour);
	GUI::DrawText(""+breastplate_def, Vec2f(HUD.x,HUD.y)+Vec2f(51*PosScale,25*PosScale), Text_colour);
	GUI::DrawText(""+leggings_def, Vec2f(HUD.x,HUD.y)+Vec2f(51*PosScale,40*PosScale), Text_colour);
	
	GUI::DrawIcon(getSpritePrefix(breastplate_type)+"_hudshirt.png", 0, Vec2f(19, 12), HUD+Vec2f(67*PosScale,25*PosScale), Scale);
	GUI::DrawIcon(getSpritePrefix(leggings_type)+"_hudpants.png", 0, Vec2f(11, 10), HUD+Vec2f(71*PosScale,38*PosScale), Scale);
	
	
	GUI::DrawIcon("DeathSoulHUD.png", 0, Vec2f(128, 64), HUD, Scale);
	GUI::DrawIcon("LifeSoulHUD.png", 0, Vec2f(128, 64), HUD, Scale);
	
	GUI::DrawText("100%", Vec2f(HUD.x,HUD.y)+Vec2f(8*PosScale,11*PosScale), Text_colour);
	GUI::DrawText("Alive", Vec2f(HUD.x,HUD.y)+Vec2f(8*PosScale,40*PosScale), Text_colour);
	
	
	/*
	
	int TorsoType = blob.get_s8("torso_type");
	int FrontLegType = blob.get_s8("front_leg_type");
	int BackLegType = blob.get_s8("back_leg_type");
	int MainArmType = blob.get_s8("main_arm_type");
	int SubArmType = blob.get_s8("sub_arm_type");

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
	}*/
}
