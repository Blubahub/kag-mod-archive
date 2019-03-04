
#include "AbilityCommon.as";
#include "eleven.as"
#include "HumanoidCommon.as";
#include "ep.as";

void onInit(CBlob @this){

	if(!this.exists("blood_amount"))this.set_s16("blood_amount", 0);
	
	this.set_f32("bleed",0);
	
	this.getCurrentScript().tickFrequency = 30;
	
	this.set_u8("blood_addiction", 0);

}

void onTick(CBlob @this){

	int blood = this.get_s16("blood_amount");

	if(this.get_f32("bleed") > 0 && blood > 0){
		this.sub_f32("bleed",1.0f);
		
		if(!this.hasTag("blood_ability")){
			blood -= 1;
			if(getNet().isServer()){
				CBlob @b = server_CreateBlob("b",-1,this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5));
				if(b !is null)b.setVelocity((Vec2f(XORRandom(33)-16,XORRandom(33)-16)/16.0f));
			}
		}
	} else {
		this.set_f32("bleed",0);
	}
	
	if(blood >= 150 && !this.hasTag("hemoric_yank_ability"))giveAbility(this,"hemoric_yank_ability","blood");
	else if(blood >= 200 && !this.hasTag("hemoric_healing_ability"))giveAbility(this,"hemoric_healing_ability","blood");
	else if(blood >= 250 && !this.hasTag("hemoric_strength_ability"))giveAbility(this,"hemoric_strength_ability","blood");
	else if(blood >= 300 && !this.hasTag("hemoric_spikes_ability"))giveAbility(this,"hemoric_spikes_ability","blood");
	else if(blood >= 350 && !this.hasTag("hemoric_infuse_ability"))giveAbility(this,"hemoric_infuse_ability","blood");
	else if(blood >= 400 && !this.hasTag("hemoric_growth_ability"))giveAbility(this,"hemoric_growth_ability","blood");
	else if(blood >= 450 && !this.hasTag("hemoric_armour_ability"))giveAbility(this,"hemoric_armour_ability","blood");
	else if(blood >= 500 && !this.hasTag("hemoric_wings_ability"))giveAbility(this,"hemoric_wings_ability","blood");
	
	
	//giveAbility(this,"hemoric_morph_ability","blood");
	
	if(blood > 50){
		if(this.hasTag("hemoric_healing")){
			int Mod = getPowerMod(this,"blood");
			blood -= HealBody(this, Mod)*4;
			for(int i = 0;i < Mod*4;i++){
				hp(this.getPosition()+Vec2f(XORRandom(13)-6,XORRandom(17)-8), true);
			}
		}
		if(this.hasTag("hemoric_strength")){
			blood -= 2;
			if(getLocalPlayer() !is null && getLocalPlayer().hasTag("blood_sight"))
			if(this.getSprite().getSpriteLayer("blood_buff") is null){
				CSpriteLayer @bb = this.getSprite().addSpriteLayer("blood_buff", "bbuff.png", 24, 24);
				
				if(bb !is null){
					bb.setRenderStyle(RenderStyle::additive);
					bb.SetRelativeZ(-50.0f);
				}
			}
		}
	}  else {
		this.Untag("hemoric_healing");
		this.Untag("hemoric_strength");
	}

	
	if(this.get_u8("blood_addiction") >= 5){
		this.AddScript("HumanoidBloodAddict.as");
		this.getSprite().AddScript("HumanoidBloodAddict.as");
		
		if(!this.exists("food_blood"))this.set_u8("food_blood",50);
	}
	
	if(blood > 100){
		this.Tag("blood_ability");
		this.Tag("blood_sight");
	}
	
	this.set_s16("blood_amount",blood);
	
	if(getNet().isServer()){
		this.Sync("blood_amount",true);
		this.Sync("bleed",true);
	}
	
	if(getNet().isClient())
	if(getLocalPlayer() is this.getPlayer()){
		if(this.hasTag("blood_sight"))getLocalPlayer().Tag("blood_sight");
		else getLocalPlayer().Untag("blood_sight");
	}

}
