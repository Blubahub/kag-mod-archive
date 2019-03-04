
const f32 Scale = 1.0f;
const f32 PosScale = Scale*2.0f;
const int soul_x = 13;
const int body_x = -5;
const int armour_x = 14;
const int blood_x = 4;
const SColor Text_colour(0xff130d1d);

int bar_slots = 0;
int[] reserved_slots = {0,0,0,0,0,0,0,0};

Vec2f CreateBaseHUD(CSprite@ this, CBlob @blob, CPlayer @player){
	
	Vec2f HUD = Vec2f(getScreenWidth()-12-3*PosScale,12);
	
	GUI::SetFont("menu");
	
	bar_slots = 0;
	for(int i = 0;i < reserved_slots.length;i++)reserved_slots[i] = 0;
	
	return HUD;
}

void EndBaseHUD(CSprite@ this, CBlob @blob, CPlayer @player){

	GUI::DrawIcon("BaseHUDCap.png", 0, Vec2f(4, 54), Vec2f(getScreenWidth()-12-4*PosScale,12), Scale);

}

Vec2f CreateBloodHUD(CSprite@ this, CBlob @blob, CPlayer @player, Vec2f HUD){

	if(blob.hasTag("flesh")){

		HUD = HUD-Vec2f(21*PosScale,0);
		reserved_slots[bar_slots] = 1;
		bar_slots += 1;
		
		GUI::DrawIcon("BloodBaseHUD.png", 0, Vec2f(24, 54), HUD, Scale);

		if(blob.get_f32("bleed") > 0)if(getGameTime() % 30 > 15)GUI::DrawIcon("BleedingHUD.png", 0, Vec2f(24, 54), HUD, Scale);
		GUI::DrawText("Bld.", Vec2f(HUD.x,HUD.y)+Vec2f(blood_x*PosScale,4*PosScale), Text_colour);
		
		float blood_bar_segments = 30.0f;
		float blood = (Maths::Min(blob.get_s16("blood_amount"),100)*1.0f)/100.0f;
		
		for(int i = 0; i < blood_bar_segments*blood;i++){
			GUI::DrawIcon("HealthBloodBarHUD.png", (blood_bar_segments-1)-i, Vec2f(12, 1), HUD+Vec2f((blood_x+2)*PosScale,(12-i+36)*PosScale), Scale);
		}
		
		GUI::DrawTextCentered(""+Maths::Min(blob.get_s16("blood_amount"),100)+"%", Vec2f(HUD.x,HUD.y)+Vec2f((blood_x+7)*PosScale,15*PosScale), Text_colour);

	}
	
	return HUD;
}

Vec2f CreateBodyHUD(CSprite@ this, CBlob @blob, CPlayer @player, Vec2f HUD){

	if(blob.getName() != "w"){
		HUD = HUD-Vec2f(62*PosScale,0);
		bar_slots += 3;

		GUI::DrawIcon("BodyBaseHUD.png", 0, Vec2f(65, 54), HUD, Scale);
		
		if(blob.getName() == "humanoid")CreateHumanoidBodyHUD(this, blob, player, HUD);
		else {
			int HUDNum = 7;
			
			if(blob.getName() == "bison")HUDNum = 0;
			else if(blob.getName() == "chicken")HUDNum = 1;
			else if(blob.getName() == "shark")HUDNum = 2;
			else if(blob.getName() == "fishy")HUDNum = 3;
			
			CreateBodyHPHUD(this, blob, player, HUD);
			GUI::DrawIcon("AnimalBodyHUD.png", HUDNum, Vec2f(65, 54), HUD, Scale);
		}
		
		GUI::DrawText("Body", Vec2f(HUD.x,HUD.y)+Vec2f((body_x+28)*PosScale,4*PosScale), Text_colour);
	}
	
	return HUD;
}

Vec2f CreateArmourHUD(CSprite@ this, CBlob @blob, CPlayer @player, Vec2f HUD){

	if(blob.getName() == "humanoid"){

		HUD = HUD-Vec2f(43*PosScale,0);
		bar_slots += 2;

		GUI::DrawIcon("ArmourBaseHUD.png", 0, Vec2f(46, 54), HUD, Scale);
		GUI::DrawText("Armour", Vec2f(HUD.x,HUD.y)+Vec2f((armour_x-5)*PosScale,4*PosScale), Text_colour);

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
			breastplate_type = breastplate.get_string("character_sprite_prefix");
		}
		if(leggings !is null){
			leggings_def = leggings.get_u8("defense");
			leggings_type = leggings.get_string("character_sprite_prefix");
		}

		GUI::DrawIcon(breastplate_type+"_hudshirt.png", 0, Vec2f(19, 12), HUD+Vec2f((armour_x+6)*PosScale,25*PosScale), Scale);
		GUI::DrawIcon(leggings_type+"_hudpants.png", 0, Vec2f(11, 10), HUD+Vec2f((armour_x+10)*PosScale,38*PosScale), Scale);
		
		GUI::DrawText(""+helmet_def, Vec2f(HUD.x,HUD.y)+Vec2f((armour_x-10)*PosScale,13*PosScale), Text_colour);
		GUI::DrawText(""+breastplate_def, Vec2f(HUD.x,HUD.y)+Vec2f((armour_x-10)*PosScale,25*PosScale), Text_colour);
		GUI::DrawText(""+leggings_def, Vec2f(HUD.x,HUD.y)+Vec2f((armour_x-10)*PosScale,40*PosScale), Text_colour);
	
	}
	
	return HUD;
}

Vec2f CreateSoulHUD(CSprite@ this, CBlob @blob, CPlayer @player, Vec2f HUD){

	HUD = HUD-Vec2f(41*PosScale,0);
	reserved_slots[bar_slots] = 2;
	reserved_slots[bar_slots+1] = 3;
	bar_slots += 2;

	int LifeAmount = Maths::Min(blob.get_s16("life_amount"),1000);
	int DeathAmount = Maths::Min(blob.get_s16("death_amount"),1000);
	
	GUI::DrawIcon("SoulBaseHUD.png", 0, Vec2f(44, 54), HUD, Scale);
	GUI::DrawText("Soul", Vec2f(HUD.x,HUD.y)+Vec2f(soul_x*PosScale,4*PosScale), Text_colour);
	
	if(DeathAmount > 5 || (DeathAmount > 0 && LifeAmount <= 0))GUI::DrawIcon("DeathSoulHUD.png", 0, Vec2f(128, 64), HUD, Scale);
	if(LifeAmount > 0)GUI::DrawIcon("LifeSoulHUD.png", 0, Vec2f(128, 64), HUD, Scale);
	
	if(LifeAmount >= 100 || DeathAmount >= 100)GUI::DrawText("100%", Vec2f(HUD.x,HUD.y)+Vec2f((soul_x)*PosScale,11*PosScale), Text_colour);
	else {
		GUI::DrawText(""+Maths::Max(LifeAmount,DeathAmount)+"%", Vec2f(HUD.x,HUD.y)+Vec2f((soul_x)*PosScale,11*PosScale), Text_colour);
	}
	
	if(blob.hasTag("alive"))GUI::DrawText("Alive", Vec2f(HUD.x,HUD.y)+Vec2f((soul_x)*PosScale,43*PosScale), Text_colour);
	else GUI::DrawText("Dead", Vec2f(HUD.x,HUD.y)+Vec2f((soul_x)*PosScale,43*PosScale), Text_colour);
	
	return HUD;
}


void CreateBarsHUD(CSprite@ this, CBlob @blob, CPlayer @player){

	int LifeAmount = Maths::Min(blob.get_s16("life_amount"),1000);
	int DeathAmount = Maths::Min(blob.get_s16("death_amount"),1000);
	int FireAmount = Maths::Min(blob.get_s16("fire_amount"),100);
	int WaterAmount = Maths::Min(blob.get_s16("flow_amount"),100);
	int GoldAmount = Maths::Min(blob.get_s16("light_amount"),1000);
	int DarkAmount = Maths::Min(blob.get_s16("dark_amount"),1000);
	int NatureAmount = Maths::Min(blob.get_s16("nature_amount"),100);
	int BloodAmount = Maths::Max(Maths::Min(blob.get_s16("blood_amount")-100,1000),0);
	
	Vec2f Initial = Vec2f(-21*PosScale,60*PosScale)+Vec2f(getScreenWidth()-12-1*PosScale,0);
	
	Vec2f LifeBarX = 	Initial;
	Vec2f DeathBarX = 	Initial;
	Vec2f FireBarX = 	Initial;
	Vec2f WaterBarX = 	Initial;
	Vec2f GoldBarX = 	Initial;
	Vec2f DarkBarX = 	Initial;
	Vec2f NatureBarX = 	Initial;
	Vec2f BloodBarX = 	Initial;

	for(int i = 0;i < reserved_slots.length;i++){
	
		if(reserved_slots[i] == 1){
			if(blob.hasTag("blood_ability") || blob.hasTag("blood_sight") || blob.hasTag("blood_knowledge"))
				BloodBarX.x 	+= -i*21*PosScale;
			else reserved_slots[i] = 0;
		}
		if(reserved_slots[i] == 2){
			if(blob.hasTag("death_ability") || blob.hasTag("death_sight") || blob.hasTag("death_knowledge"))
				DeathBarX.x 	+= -i*21*PosScale;
			else reserved_slots[i] = 0;
		}
		if(reserved_slots[i] == 3){
			if(blob.hasTag("life_ability") || blob.hasTag("life_sight") || blob.hasTag("life_knowledge"))
				LifeBarX.x 	+= -i*21*PosScale;
			else reserved_slots[i] = 0;
		}
	
	}
	
	for(int i = 0;i < reserved_slots.length;i++){
	
		if(reserved_slots[i] == 0){
				 if(LifeBarX ==   Initial && (blob.hasTag("life_ability") || blob.hasTag("life_sight") || blob.hasTag("life_knowledge")))LifeBarX.x += 	-i*21*PosScale;
			else if(DeathBarX ==  Initial && (blob.hasTag("death_ability") || blob.hasTag("death_sight") || blob.hasTag("death_knowledge")))DeathBarX.x += 	-i*21*PosScale;
			else if(FireBarX ==   Initial && (blob.hasTag("fire_ability") || blob.hasTag("fire_sight") || blob.hasTag("fire_knowledge")))FireBarX.x += 	-i*21*PosScale;
			else if(WaterBarX ==  Initial && (blob.hasTag("water_ability") || blob.hasTag("water_sight") || blob.hasTag("water_knowledge")))WaterBarX.x += 	-i*21*PosScale;
			else if(GoldBarX ==   Initial && (blob.hasTag("gold_ability") || blob.hasTag("gold_sight") || blob.hasTag("gold_knowledge")))GoldBarX.x += 	-i*21*PosScale;
			else if(DarkBarX ==   Initial && (blob.hasTag("dark_ability") || blob.hasTag("dark_sight") || blob.hasTag("dark_knowledge")))DarkBarX.x += 	-i*21*PosScale;
			else if(NatureBarX == Initial && (blob.hasTag("natur_ability") || blob.hasTag("nature_sight") || blob.hasTag("nature_knowledge")))NatureBarX.x += 	-i*21*PosScale;
			else if(BloodBarX ==  Initial && (blob.hasTag("blood_ability") || blob.hasTag("blood_sight") || blob.hasTag("blood_knowledge")))BloodBarX.x += 	-i*21*PosScale;
		}
	}

	//blob.Tag("life_ability");
	if(blob.hasTag("life_ability")) {
		GUI::DrawIcon("LifeBarHUD.png", 3, Vec2f(21, 72), LifeBarX, Scale);
		for(int i=0;i<(LifeAmount/10);i++)GUI::DrawIcon("LifeBarHUD.png", 5, Vec2f(21, 72), LifeBarX+Vec2f(0,-(i*Scale)), Scale);
		GUI::DrawIcon("LifeBarHUD.png", 4, Vec2f(21, 72), LifeBarX, Scale);
		if(LifeAmount > 0)GUI::DrawTextCentered(""+LifeAmount, LifeBarX+Vec2f(9*PosScale, 5*PosScale), Text_colour);
	}
	else if(blob.hasTag("life_sight"))GUI::DrawIcon("LifeBarHUD.png", 1, Vec2f(21, 72), LifeBarX, Scale);
	else if(blob.hasTag("life_knowledge"))GUI::DrawIcon("LifeBarHUD.png", 0, Vec2f(21, 72), LifeBarX, Scale);
	
	
	
	//blob.Tag("death_ability");
	if(blob.hasTag("death_ability")) {
		GUI::DrawIcon("DeathBarHUD.png", 3, Vec2f(21, 72), DeathBarX, Scale);
		for(int i=0;i<(DeathAmount/10);i++)GUI::DrawIcon("DeathBarHUD.png", 5, Vec2f(21, 72), DeathBarX+Vec2f(0,-(i*Scale)), Scale);	
		GUI::DrawIcon("DeathBarHUD.png", 4, Vec2f(21, 72), DeathBarX, Scale);
		if(DeathAmount > 0)GUI::DrawTextCentered(""+DeathAmount, DeathBarX+Vec2f(9*PosScale, 5*PosScale), Text_colour);
	}
	else if(blob.hasTag("death_sight"))GUI::DrawIcon("DeathBarHUD.png", 1, Vec2f(21, 72), DeathBarX, Scale);
	else if(blob.hasTag("death_knowledge"))GUI::DrawIcon("DeathBarHUD.png", 0, Vec2f(21, 72), DeathBarX, Scale);
	
	
	
	//blob.Tag("fire_ability");
	if(blob.hasTag("fire_ability")) {
		GUI::DrawIcon("FireBarHUD.png", 3, Vec2f(21, 72), FireBarX, Scale);
		for(int i=0;i<(FireAmount);i++)GUI::DrawIcon("FireBarHUD.png", 5, Vec2f(21, 72), FireBarX+Vec2f(0,-(i*Scale)), Scale);
		GUI::DrawIcon("FireBarHUD.png", 4, Vec2f(21, 72), FireBarX, Scale);
		if(FireAmount > 0)GUI::DrawTextCentered(""+FireAmount, FireBarX+Vec2f(9*PosScale, 5*PosScale), Text_colour);
	}
	else if(blob.hasTag("fire_sight"))GUI::DrawIcon("FireBarHUD.png", 1, Vec2f(21, 72), FireBarX, Scale);
	else if(blob.hasTag("fire_knowledge"))GUI::DrawIcon("FireBarHUD.png", 0, Vec2f(21, 72), FireBarX, Scale);
	
	
	
	//blob.Tag("water_ability");
	if(blob.hasTag("water_ability")) {
		GUI::DrawIcon("WaterBarHUD.png", 3, Vec2f(21, 72), WaterBarX, Scale);
		for(int i=0;i<(WaterAmount/10);i++)GUI::DrawIcon("WaterBarHUD.png", 5, Vec2f(21, 72), WaterBarX+Vec2f(0,-(i*Scale)), Scale);
		GUI::DrawIcon("WaterBarHUD.png", 4, Vec2f(21, 72), WaterBarX, Scale);
		if(WaterAmount > 0)GUI::DrawTextCentered(""+WaterAmount, WaterBarX+Vec2f(9*PosScale, 5*PosScale), Text_colour);
	}
	else if(blob.hasTag("water_sight"))GUI::DrawIcon("WaterBarHUD.png", 1, Vec2f(21, 72), WaterBarX, Scale);
	else if(blob.hasTag("water_knowledge"))GUI::DrawIcon("WaterBarHUD.png", 0, Vec2f(21, 72), WaterBarX, Scale);
	
	
	//blob.Tag("light_ability");
	if(blob.hasTag("light_ability")) {
		GUI::DrawIcon("GoldBarHUD.png", 3, Vec2f(21, 72), GoldBarX, Scale);
		for(int i=0;i<(GoldAmount/10);i++)GUI::DrawIcon("GoldBarHUD.png", 5, Vec2f(21, 72), GoldBarX+Vec2f(0,-(i*Scale)), Scale);
		GUI::DrawIcon("GoldBarHUD.png", 4, Vec2f(21, 72), GoldBarX, Scale);
		if(GoldAmount > 0)GUI::DrawTextCentered(""+GoldAmount, GoldBarX+Vec2f(9*PosScale, 5*PosScale), Text_colour);
	}
	else if(blob.hasTag("light_sight"))GUI::DrawIcon("GoldBarHUD.png", 1, Vec2f(21, 72), GoldBarX, Scale);
	else if(blob.hasTag("light_knowledge"))GUI::DrawIcon("GoldBarHUD.png", 0, Vec2f(21, 72), GoldBarX, Scale);
	
	
	//blob.Tag("dark_ability");
	if(blob.hasTag("dark_ability")) {
		GUI::DrawIcon("DarkBarHUD.png", 3, Vec2f(21, 72), DarkBarX, Scale);
		for(int i=0;i<(DarkAmount/10);i++)GUI::DrawIcon("DarkBarHUD.png", 5, Vec2f(21, 72), DarkBarX+Vec2f(0,-(i*Scale)), Scale);
		GUI::DrawIcon("DarkBarHUD.png", 4, Vec2f(21, 72), DarkBarX, Scale);
		if(DarkAmount > 0)GUI::DrawTextCentered(""+DarkAmount, DarkBarX+Vec2f(9*PosScale, 5*PosScale), Text_colour);
	}
	else if(blob.hasTag("dark_sight"))GUI::DrawIcon("DarkBarHUD.png", 1, Vec2f(21, 72), DarkBarX, Scale);
	else if(blob.hasTag("dark_knowledge"))GUI::DrawIcon("DarkBarHUD.png", 0, Vec2f(21, 72), DarkBarX, Scale);
	
	
	//blob.Tag("nature_ability");
	if(blob.hasTag("nature_ability")) {
		GUI::DrawIcon("NatureBarHUD.png", 3, Vec2f(21, 72), NatureBarX, Scale);
		for(int i=0;i<(NatureAmount/10);i++)GUI::DrawIcon("NatureBarHUD.png", 5, Vec2f(21, 72), NatureBarX+Vec2f(0,-(i*Scale)), Scale);
		GUI::DrawIcon("NatureBarHUD.png", 4, Vec2f(21, 72), NatureBarX, Scale);
		if(NatureAmount > 0)GUI::DrawTextCentered(""+NatureAmount, NatureBarX+Vec2f(9*PosScale, 5*PosScale), Text_colour);
	}
	else if(blob.hasTag("nature_sight"))GUI::DrawIcon("NatureBarHUD.png", 1, Vec2f(21, 72), NatureBarX, Scale);
	else if(blob.hasTag("nature_knowledge"))GUI::DrawIcon("NatureBarHUD.png", 0, Vec2f(21, 72), NatureBarX, Scale);
	
	
	//blob.Tag("blood_ability");
	if(blob.hasTag("blood_ability")) {
		GUI::DrawIcon("BloodBarHUD.png", 3, Vec2f(21, 72), BloodBarX, Scale);
		for(int i=0;i<(BloodAmount/10);i++)GUI::DrawIcon("BloodBarHUD.png", 5, Vec2f(21, 72), BloodBarX+Vec2f(0,-(i*Scale)), Scale);
		GUI::DrawIcon("BloodBarHUD.png", 4, Vec2f(21, 72), BloodBarX, Scale);
		if(blob.get_s16("blood_amount") > 0)GUI::DrawTextCentered(""+blob.get_s16("blood_amount"), BloodBarX+Vec2f(9*PosScale, 5*PosScale), Text_colour);
	}
	else if(blob.hasTag("blood_sight"))GUI::DrawIcon("BloodBarHUD.png", 1, Vec2f(21, 72), BloodBarX, Scale);
	else if(blob.hasTag("blood_knowledge"))GUI::DrawIcon("BloodBarHUD.png", 0, Vec2f(21, 72), BloodBarX, Scale);
	
}



void CreateBodyHPHUD(CSprite@ this, CBlob @blob, CPlayer @player, Vec2f HUD){

	GUI::DrawIcon("BodyHPBaseHUD.png", 0, Vec2f(65, 54), HUD, Scale);
	
	f32 HP = blob.getHealth();
	f32 MaxHP = blob.getInitialHealth();
	
	GUI::DrawTextCentered(""+((HP/MaxHP)*100)+"%", Vec2f(HUD.x+16*PosScale,HUD.y+21*PosScale), Text_colour);
	GUI::DrawTextCentered(""+(HP)+" HP", Vec2f(HUD.x+48*PosScale,HUD.y+21*PosScale), Text_colour);
}



void CreateHumanoidBodyHUD(CSprite@ this, CBlob @blob, CPlayer @player, Vec2f HUD){

	GUI::DrawIcon("HumanoidBodyBaseHUD.png", 0, Vec2f(65, 54), HUD, Scale);
	
	GUI::DrawIcon("EyesHUD.png", getLeftEye(blob)*2, Vec2f(7, 7), HUD+Vec2f((body_x+14)*PosScale,15*PosScale), Scale);
	GUI::DrawIcon("EyesHUD.png", getRightEye(blob)*2+1, Vec2f(7, 7), HUD+Vec2f((body_x+23)*PosScale,15*PosScale), Scale);
	
	int HeadType = blob.get_s8("head_type")+1;
	int TorsoType = blob.get_s8("torso_type")+1;
	int MainArmType = blob.get_s8("main_arm_type")+1;
	int SubArmType = blob.get_s8("sub_arm_type")+1;
	int FrontLegType = blob.get_s8("front_leg_type")+1;
	int BackLegType = blob.get_s8("back_leg_type")+1;
	
	if(getLocalPlayer() is null || !getLocalPlayer().hasTag("death_sight")){
		if(HeadType == 2)HeadType = 0;
		if(TorsoType == 2)TorsoType = 0;
		if(MainArmType == 2)MainArmType = 0;
		if(SubArmType == 2)SubArmType = 0;
		if(FrontLegType == 2)FrontLegType = 0;
		if(BackLegType == 2)BackLegType = 0;
	}
	
	
	f32 torsoHurt = blob.get_f32("torso_hit");
	f32 mainArmHurt = blob.get_f32("main_arm_hit");
	f32 subArmHurt = blob.get_f32("sub_arm_hit");
	f32 frontLegHurt = blob.get_f32("front_leg_hit");
	f32 backLegHurt = blob.get_f32("back_leg_hit");
	
	GUI::DrawIcon("HeadHUD.png", HeadType, Vec2f(13, 14), HUD+Vec2f((body_x+31)*PosScale,12*PosScale), Scale);
	GUI::DrawIcon("TorsoHUD.png", TorsoType, Vec2f(13, 14), HUD+Vec2f((body_x+31)*PosScale,24*PosScale), Scale);
	
	GUI::DrawIcon("MainArmHUD.png", MainArmType, Vec2f(7, 15), HUD+Vec2f((body_x+25)*PosScale,25*PosScale), Scale);
	GUI::DrawIcon("SubArmHUD.png", SubArmType, Vec2f(7, 15), HUD+Vec2f((body_x+43)*PosScale,25*PosScale), Scale);
	
	GUI::DrawIcon("FrontLegHUD.png", FrontLegType, Vec2f(8, 12), HUD+Vec2f((body_x+30)*PosScale,37*PosScale), Scale);
	GUI::DrawIcon("BackLegHUD.png", BackLegType, Vec2f(8, 12), HUD+Vec2f((body_x+37)*PosScale,37*PosScale), Scale);
	
	SColor torso_colour(0xffff0000);
	torso_colour.setAlpha(255.0f*torsoHurt);
	GUI::DrawIcon("HeadHurtHUD.png", 0, Vec2f(13, 14), HUD+Vec2f((body_x+31)*PosScale,12*PosScale), Scale, torso_colour);
	GUI::DrawIcon("TorsoHurtHUD.png", 0, Vec2f(13, 14), HUD+Vec2f((body_x+31)*PosScale,24*PosScale), Scale, torso_colour);
	
	SColor MArm_colour(0xffff0000);
	MArm_colour.setAlpha(255.0f*mainArmHurt);
	SColor SArm_colour(0xffff0000);
	SArm_colour.setAlpha(255.0f*subArmHurt);
	
	GUI::DrawIcon("MainArmHurtHUD.png", 0, Vec2f(7, 15), HUD+Vec2f((body_x+25)*PosScale,25*PosScale), Scale, MArm_colour);
	GUI::DrawIcon("SubArmHurtHUD.png", 0, Vec2f(7, 15), HUD+Vec2f((body_x+43)*PosScale,25*PosScale), Scale, SArm_colour);
	
	SColor FLeg_colour(0xffff0000);
	FLeg_colour.setAlpha(255.0f*frontLegHurt);
	SColor BLeg_colour(0xffff0000);
	BLeg_colour.setAlpha(255.0f*backLegHurt);
	
	GUI::DrawIcon("FrontLegHurtHUD.png", 0, Vec2f(8, 12), HUD+Vec2f((body_x+30)*PosScale,37*PosScale), Scale, FLeg_colour);
	GUI::DrawIcon("BackLegHurtHUD.png", 0, Vec2f(8, 12), HUD+Vec2f((body_x+37)*PosScale,37*PosScale), Scale, BLeg_colour);
	
	
	int TorsoHealth = Maths::Ceil(blob.get_f32("torso_hp"))-1;
	int FrontLegHealth = Maths::Ceil(blob.get_f32("front_leg_hp"))-1;
	int BackLegHealth = Maths::Ceil(blob.get_f32("back_leg_hp"))-1;
	int MainArmHealth = Maths::Ceil(blob.get_f32("main_arm_hp"))-1;
	int SubArmHealth = Maths::Ceil(blob.get_f32("sub_arm_hp"))-1;
	
	int TorsoMaxHealth = bodyPartMaxHealth(TorsoType,"torso");
	int FrontLegMaxHealth = bodyPartMaxHealth(FrontLegType,"front_leg");
	int BackLegMaxHealth = bodyPartMaxHealth(BackLegType,"back_leg");
	int MainArmMaxHealth = bodyPartMaxHealth(MainArmType,"main_arm");
	int SubArmMaxHealth = bodyPartMaxHealth(SubArmType,"sub_arm");
	
	if(TorsoType != 0 && TorsoType != BodyType::Ghost+1)GUI::DrawTextCentered(""+TorsoHealth, Vec2f(HUD.x,HUD.y)+Vec2f((body_x+60.5f)*PosScale,15*PosScale), Text_colour);
	if(SubArmType != 0 && SubArmType != BodyType::Ghost+1)GUI::DrawTextCentered(""+SubArmHealth, Vec2f(HUD.x,HUD.y)+Vec2f((body_x+60.5f)*PosScale,28*PosScale), Text_colour);
	if(BackLegType != 0 && BackLegType != BodyType::Ghost+1)GUI::DrawTextCentered(""+BackLegHealth, Vec2f(HUD.x,HUD.y)+Vec2f((body_x+60.5f)*PosScale,43*PosScale), Text_colour);
	
	if(MainArmType != 0 && MainArmType != BodyType::Ghost+1)GUI::DrawTextCentered(""+MainArmHealth, Vec2f(HUD.x,HUD.y)+Vec2f((body_x+12)*PosScale,28*PosScale), Text_colour);
	if(FrontLegType != 0 && FrontLegType != BodyType::Ghost+1)GUI::DrawTextCentered(""+FrontLegHealth, Vec2f(HUD.x,HUD.y)+Vec2f((body_x+12)*PosScale,43*PosScale), Text_colour);
	
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
	
	if(TorsoType == 0 || TorsoType == BodyType::Ghost+1)TorsoHeart = 2;
	if(MainArmType == 0 || MainArmType == BodyType::Ghost+1)MainArmHeart = 2;
	if(SubArmType == 0 || SubArmType == BodyType::Ghost+1)SubArmHeart = 2;
	if(FrontLegType == 0 || FrontLegType == BodyType::Ghost+1)FrontLegHeart = 2;
	if(BackLegType == 0 || BackLegType == BodyType::Ghost+1)BackLegHeart = 2;
	
	if(blob.hasTag("death_sight")){
		if(TorsoType == BodyType::Ghost+1)TorsoHeart = 3;
		if(MainArmType == BodyType::Ghost+1)MainArmHeart = 3;
		if(SubArmType == BodyType::Ghost+1)SubArmHeart = 3;
	}
	
	if(TorsoType == BodyType::Wraith+1)TorsoHeart = 3;
	if(MainArmType == BodyType::Wraith+1)MainArmHeart = 3;
	if(SubArmType == BodyType::Wraith+1)SubArmHeart = 3;
	if(FrontLegType == BodyType::Wraith+1)FrontLegHeart = 3;
	if(BackLegType == BodyType::Wraith+1)BackLegHeart = 3;
	
	GUI::DrawIcon("HeartHUD.png", TorsoHeart, Vec2f(7, 7), HUD+Vec2f((body_x+50)*PosScale,12*PosScale), Scale);
	GUI::DrawIcon("HeartHUD.png", SubArmHeart, Vec2f(7, 7), HUD+Vec2f((body_x+50)*PosScale,25*PosScale), Scale);
	GUI::DrawIcon("HeartHUD.png", BackLegHeart, Vec2f(7, 7), HUD+Vec2f((body_x+50)*PosScale,40*PosScale), Scale);
	
	GUI::DrawIcon("HeartHUD.png", MainArmHeart, Vec2f(7, 7), HUD+Vec2f((body_x+18)*PosScale,25*PosScale), Scale);
	GUI::DrawIcon("HeartHUD.png", FrontLegHeart, Vec2f(7, 7), HUD+Vec2f((body_x+18)*PosScale,40*PosScale), Scale);

}