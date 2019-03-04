
#include "Health.as";
#include "RunnerCommon.as";
#include "FireParticle.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{

	this.set_s16("nature_regen",0);
	
	this.set_s16("golden_shield",0);
	
	this.set_s16("water_bubble",0);
	
	this.set_s16("poison",0);
	
	this.set_s16("invisible",0);
	
	this.set_s16("slow",0);
	this.set_f32("cold",1.0);
	this.set_s16("haste",0);
	this.set_s16("noknees",0);
	
	this.set_s16("weakend",0);
	
	this.set_s16("statis",0);
	this.set_s16("se_invincible",0);
	
	this.set_s16("blood_regen",0);
	this.set_s16("blood_strength",0);
	
	this.set_s16("effecttimer",0);
	this.Tag("status_effects");
}


void onTick(CBlob@ this)
{
	{
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			if(this.get_f32("cold") < 0.25)
			moveVars.jumpFactor *= this.get_f32("cold")*4;
			moveVars.walkFactor *= this.get_f32("cold");
		}
	}
	
	if(this.get_s16("statis") > 0){
		this.set_s16("statis",this.get_s16("statis")-1);
		
		if(getNet().isServer())this.Sync("statis",true);
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 0.0f;
			moveVars.walkFactor *= 0.0f;
		}
		this.set_s16("se_invincible",1);
	} else {
	
		if(this.get_s16("golden_shield") > 0){
			this.set_s16("golden_shield",this.get_s16("golden_shield")-1);
		}
		
		if(this.get_s16("water_bubble") > 0){
			this.set_s16("water_bubble",this.get_s16("water_bubble")-1);
		}
		
		if(this.get_s16("se_invincible") > 0){
			this.set_s16("se_invincible",this.get_s16("se_invincible")-1);
		}
		
		if(this.get_s16("invisible") > 0){
			this.set_s16("invisible",this.get_s16("invisible")-1);
		}
		
		if(this.get_s16("blood_strength") > 0){
			this.set_s16("blood_strength",this.get_s16("blood_strength")-1);
			this.Tag("cleanse");
		}
		
		if(this.get_s16("weakend") > 0){
			this.set_s16("weakend",this.get_s16("weakend")-1);
			if(XORRandom(5) == 0)ParticleAnimated(CFileMatcher("SmallSteam").getFirst(), this.getPosition() + Vec2f(XORRandom(12) - 6, XORRandom(16)-8), Vec2f(0,-0.01), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
		}
		
		if(this.get_s16("slow") > 0){
			this.set_s16("slow",this.get_s16("slow")-1);
		}
		if(this.get_s16("haste") > 0){
			this.set_s16("haste",this.get_s16("haste")-1);
		}
		if(this.get_s16("noknees") > 0){
			this.set_s16("noknees",this.get_s16("noknees")-1);
		}
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			if(this.get_s16("noknees") > 0)moveVars.jumpFactor *= 0.2f;
			if(this.get_s16("slow") > 0)moveVars.walkFactor *= 0.5f;
			if(this.get_s16("haste") > 0)moveVars.walkFactor *= 1.5f;
			if(this.get_s16("blood_strength") > 0){
				moveVars.walkFactor *= 1.5f;
				moveVars.jumpFactor *= 1.5f;
			}
		}
		
		if(this.hasTag("wind")){
			this.setVelocity(Vec2f(XORRandom(16)-8,-XORRandom(16)));
			this.Untag("wind");
		}
		
		if(this.hasTag("cleanse")){
			this.set_s16("poison",0);
			this.set_s16("slow",0);
			this.set_s16("noknees",0);
			this.set_s16("weakend",0);
			
			this.Untag("cleanse");
		}
		
		///Timer///////////////////////////////////////////////
		if(this.get_s16("effecttimer") <= 0){
		
			if(this.get_s16("nature_regen") > 0){
				Heal(this,0.25);
				this.set_s16("nature_regen",this.get_s16("nature_regen")-1);
			}
			
			if(this.get_s16("blood_regen") > 0){
				Heal(this,0.5);
				this.set_s16("blood_regen",this.get_s16("blood_regen")-1);
			}
			
			if(this.get_s16("poison") > 0){
				OverHeal(this,-0.25);
				this.set_s16("poison",this.get_s16("poison")-1);
			}

			if(getNet().isServer()){
				if(this.get_s16("nature_regen") > 0)this.Sync("nature_regen",true);
				if(this.get_s16("golden_shield") > 0)this.Sync("golden_shield",true);
				if(this.get_s16("water_bubble") > 0)this.Sync("water_bubble",true);
				if(this.get_s16("poison") > 0)this.Sync("poison",true);
				if(this.get_s16("invisible") > 0)this.Sync("invisible",true);
				
				if(this.get_s16("slow") > 0)this.Sync("slow",true);
				if(this.get_s16("haste") > 0)this.Sync("haste",true);
				if(this.get_s16("noknees") > 0)this.Sync("noknees",true);
				
				if(this.get_s16("weakend") > 0)this.Sync("weakend",true);
				
				if(this.get_s16("blood_regen") > 0)this.Sync("blood_regen",true);
				if(this.get_s16("blood_strength") > 0)this.Sync("blood_strength",true);
			}
			
			this.set_s16("effecttimer",15);
		} else this.set_s16("effecttimer",this.get_s16("effecttimer")-1);
	}
}



void onInit(CSprite@ this)
{

	{
		this.RemoveSpriteLayer("nature_regen");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("nature_regen", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(0);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("golden_shield");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("golden_shield", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(1);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("water_bubble");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("water_bubble", "StatusEffects.png" , 32, 32, 0, this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(2);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("poison");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("poison", "StatusEffects.png" , 32, 32, 0, this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(3);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("blood_strength");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("blood_strength", "StatusEffects.png" , 32, 32, 0, this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(4);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("blood_regen");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("blood_regen", "StatusEffects.png" , 32, 32, 0, this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(5);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
}

void onTick(CSprite@ this)
{
	
	this.getSpriteLayer("nature_regen").SetVisible(false);
	if(this.getBlob().get_s16("nature_regen") > 0)this.getSpriteLayer("nature_regen").SetVisible(true);
	
	this.getSpriteLayer("golden_shield").SetVisible(false);
	if(this.getBlob().get_s16("golden_shield") > 0)this.getSpriteLayer("golden_shield").SetVisible(true);
	
	this.getSpriteLayer("water_bubble").SetVisible(false);
	if(this.getBlob().get_s16("water_bubble") > 0)this.getSpriteLayer("water_bubble").SetVisible(true);
	
	this.getSpriteLayer("poison").SetVisible(false);
	if(this.getBlob().get_s16("poison") > 0)this.getSpriteLayer("poison").SetVisible(true);
	
	this.getSpriteLayer("blood_strength").SetVisible(false);
	if(this.getBlob().get_s16("blood_strength") > 0)this.getSpriteLayer("blood_strength").SetVisible(true);
	
	this.getSpriteLayer("blood_regen").SetVisible(false);
	if(this.getBlob().get_s16("blood_regen") > 0)this.getSpriteLayer("blood_regen").SetVisible(true);
	
	
	
	if(this.getBlob().get_s16("invisible") > 1 && !this.getBlob().isKeyPressed(key_action1) && (!this.getBlob().isKeyPressed(key_action2) || this.getBlob().getName() != "builder")){
		this.SetVisible(false);
			if(this.getSpriteLayer("quiver") !is null)
			this.getSpriteLayer("quiver").SetVisible(false);
			if(this.getSpriteLayer("hook") !is null)
			this.getSpriteLayer("hook").SetVisible(false);
			if(this.getSpriteLayer("rope") !is null)
			this.getSpriteLayer("rope").SetVisible(false);
	} else if(this.getBlob().get_s16("invisible") == 1){
		this.SetVisible(true);
		if(this.getSpriteLayer("quiver") !is null)
		this.getSpriteLayer("quiver").SetVisible(true);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;

	dmg *= Defense(this);
	
	if(this.get_u8("race") == 3)if(customData == Hitters::fall)dmg = 0;
	
	if(this.get_s16("se_invincible") > 0)dmg = 0;
	
	return dmg;
}
