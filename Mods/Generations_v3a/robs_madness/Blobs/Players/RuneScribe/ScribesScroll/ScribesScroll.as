
#include "Hitters.as";
#include "Knocked.as";
#include "EnergyCommon.as";
#include "AbilityEffects.as";
#include "RunesCommon.as";

void onInit( CBlob@ this )
{
	this.addCommandID("use");
	
	this.set_u8("primary_ability",0);
	this.set_u8("secondary_ability",0);
	
	this.set_f32("power",0.0f);
	this.set_u8("cost",0);
	
	this.set_u8("heat",0);
	this.set_u8("flow",0);
	this.set_u8("holy",0);
	this.set_u8("complexity",0);
}

void onTick( CBlob@ this )
{
	if(this.isInWater())if(!this.isAttached())this.server_Hit(this, this.getPosition(), this.getVelocity(), 0.25f, Hitters::suddengib, false);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	string text = "Don't trust the idiot that wrote this";
	
	if(this.get_u8("complexity") > 10)text = "An insanely complex scroll, better not read it";
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("use"), text, params);
	button.SetEnabled(this.isAttachedTo(caller) && this.get_u8("cost") <= getEnergy(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		
		if( this.get_u8("heat") > 10){
			if(getNet().isServer())
			if(caller !is null)
			this.server_Hit(caller, this.getPosition(), Vec2f(0,0), 0.5f, Hitters::fire, false);
		}
		
		if( this.get_u8("complexity") > 10){
			if(getNet().isServer())
			if(caller !is null){
				this.server_Hit(caller, this.getPosition(), Vec2f(0,0), 0.5f, Hitters::suddengib, false);
				SetKnocked(caller, 30, true);
			}
		}
		
		if(caller !is null)
		if(!caller.hasTag("RuneNullify")){
			
			bool canCast = true;
			
			int HeatRequirement = AbilityHeatRequirement(this.get_u8("primary_ability"));
			int FlowRequirement = AbilityFlowRequirement(this.get_u8("primary_ability"));
			int HolyRequirement = AbilityHolyRequirement(this.get_u8("primary_ability"));
			bool HeatLargerOrEqual = AbilityHeatRequirementLarger(this.get_u8("primary_ability"));
			bool FlowLargerOrEqual = AbilityFlowRequirementLarger(this.get_u8("primary_ability"));
			bool HolyLargerOrEqual = AbilityHolyRequirementLarger(this.get_u8("primary_ability"));
			
			
			if(this.get_u8("heat") > 10)canCast = false;
			if(this.get_u8("complexity") > 10)canCast = false;
			if(this.get_u8("cost") > getEnergy(caller))canCast = false;
			
			if(HeatRequirement > 0){
				if(HeatLargerOrEqual){
					if(this.get_u8("heat") < HeatRequirement)canCast = false;
				} else {
					if(this.get_u8("heat") >= HeatRequirement)canCast = false;
				}
			}
			
			if(HolyRequirement > 0){
				if(HolyLargerOrEqual){
					if(this.get_u8("holy") < HolyRequirement)canCast = false;
				} else {
					if(this.get_u8("holy") >= HolyRequirement)canCast = false;
				}
			}
			
			if(FlowRequirement > 0){
				if(FlowLargerOrEqual){
					if(this.get_u8("flow") < FlowRequirement)canCast = false;
				} else {
					if(this.get_u8("flow") >= FlowRequirement)canCast = false;
				}
			}
			
			if(canCast){
				addEnergy(caller,-this.get_u8("cost"));
				
				for(int i = 0; i < this.get_u8("cost");i++)
				ParticleAnimated("EnergyParticle.png", this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), this.getVelocity()/10+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.2, XORRandom(360), 1.0f, 1, -0.01, true);
				
				PrimaryAbility(this, caller, this.get_u8("primary_ability"), this.get_f32("power"), this.get_u8("heat"),this.get_u8("flow"),this.get_u8("holy"),this.get_u8("complexity"));
				SecondaryAbility(this, caller, this.get_u8("secondary_ability"), this.get_u8("heat"),this.get_u8("flow"),this.get_u8("holy"),this.get_u8("complexity"));
			}
		}
		
		
	}
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("top");
	CSpriteLayer@ top = this.addSpriteLayer("top", "ScribesScrollTop.png", 16, 13);

	if (top !is null)
	{
		Animation@ anim = top.addAnimation("default", 0, false);
		int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
		anim.AddFrames(frames);
		top.SetOffset(Vec2f(0,3));
		top.SetRelativeZ(0.1f);
	}
}

void onTick(CSprite@ this)
{
	if(this.getBlob().get_string("scroll") != ""){
		this.SetFrame(getRuneFromLetter(this.getBlob().get_string("scroll").substr(0,1))-4);
	}
	int frame = getRuneFromLetter(this.getBlob().get_string("scroll").substr(1,1));
	if(frame < 0)frame = getRuneFromLetter(this.getBlob().get_string("scroll").substr(0,1));
	if(this.getSpriteLayer("top") !is null){
		this.getSpriteLayer("top").SetFrameIndex(frame-4);
	}
}