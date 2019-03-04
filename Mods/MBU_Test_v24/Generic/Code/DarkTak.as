
#include "HumanoidCommon.as";
#include "AbilityCommon.as";
#include "ep.as";
#include "eleven.as"

void onInit(CBlob @this){

	if(!this.exists("dark_amount"))this.set_s16("dark_amount", 0);
	
	this.getCurrentScript().tickFrequency = 30;

}

void onTick(CBlob @this){
	
	int DarkAmount = this.get_s16("dark_amount");
	
	if(DarkAmount > 50)this.Tag("dark_knowledge");
	
	if(DarkAmount > 100)this.Tag("tainted");
	
	
	if(DarkAmount >= 100 && !this.hasTag("dark_blade_ability"))giveAbility(this,"dark_blade_ability","dark");
	else if(DarkAmount >= 150 && !this.hasTag("dark_pearl_ability"))giveAbility(this,"dark_pearl_ability","dark");
	else if(DarkAmount >= 200 && !this.hasTag("dark_recall_ability"))giveAbility(this,"dark_recall_ability","dark");
	else if(DarkAmount >= 250 && !this.hasTag("dark_infuse_ability"))giveAbility(this,"dark_infuse_ability","dark");
	else if(DarkAmount >= 400 && !this.hasTag("dark_growth_ability"))giveAbility(this,"dark_growth_ability","dark");
	else if(DarkAmount >= 500 && !this.hasTag("dark_fade_ability"))giveAbility(this,"dark_fade_ability","dark");
	
	bool MArm = this.get_s8("main_arm_type") == BodyType::Shadow;
	bool SArm = this.get_s8("sub_arm_type") == BodyType::Shadow;
	bool FLeg = this.get_s8("front_leg_type") == BodyType::Shadow;
	bool Bleg = this.get_s8("back_leg_type") == BodyType::Shadow;
	bool Tors = this.get_s8("torso_type") == BodyType::Shadow;
	
	if(isServer()){
		if(DarkAmount < 50){
			if(MArm)gibLimb(this,"main_arm");
			if(SArm)gibLimb(this,"sub_arm");
			if(FLeg)gibLimb(this,"front_leg");
			if(Bleg)gibLimb(this,"back_leg");
			if(Tors){
				gibLimb(this,"torso");
				server_CreateBlob("co",-1,this.getPosition());
			}
		}
	}
	
	int darklimbs = (MArm?1:0)+(SArm?1:0)+(FLeg?1:0)+(Bleg?1:0)+((Tors?1:0)*2);
	
	CInventory @inv = this.getInventory();
	if(inv !is null){
		for(int i = 0; i < inv.getItemsCount();i++){
			CBlob @item = inv.getItem(i);
			if(item.hasTag("tainted")){
				if(XORRandom(DarkAmount+darklimbs) < 4)darklimbs++;
			}
		}
	}

	DarkAmount += darklimbs;
	
	this.set_s16("dark_amount", DarkAmount);
	if(isServer())this.Sync("dark_amount",true);
	
	if(getNet().isClient())
	if(getLocalPlayer() is this.getPlayer()){
		if(this.hasTag("dark_sight"))getLocalPlayer().Tag("dark_sight");
		else getLocalPlayer().Untag("dark_sight");
	}

}
