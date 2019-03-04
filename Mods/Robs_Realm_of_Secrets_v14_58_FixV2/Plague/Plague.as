
#include "Health.as";
#include "RunnerCommon.as";

void onInit(CBlob@ this)
{

	this.set_s16("poison_plague",0);
	

	this.set_s16("plaguetimer",0);
	this.Tag("plagues");
}


void onTick(CBlob@ this)
{
	if(!this.hasTag("dead"))
	if(this.get_s16("statis") <= 0){
	
		if(this.get_s16("poison_plague") > 0){
			this.set_s16("poison_plague",this.get_s16("poison_plague")-1);
		}
		
		///Timer///////////////////////////////////////////////
		if(this.get_s16("plaguetimer") <= 0){
		
			if(this.get_s16("poison_plague") > 0){
				OverHeal(this,-0.25);
			}


			if(getNet().isServer()){
				if(this.get_s16("poison_plague") > 0)this.Sync("poison_plague",true);
			}
			
			this.set_s16("plaguetimer",30);
		} else this.set_s16("plaguetimer",this.get_s16("effecttimer")-1);
	}
}



void onInit(CSprite@ this)
{
	{
		this.RemoveSpriteLayer("plague");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("plague", "Plague.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 4, true);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(5.0f);
		}
	}
}

void onTick(CSprite@ this)
{
	this.getSpriteLayer("plague").SetVisible(false);
	if(this.getBlob().get_s16("poison_plague") > 0)this.getSpriteLayer("plague").SetVisible(true);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(XORRandom(5) == 0)
	if(blob.hasTag("plagues"))
	{
		if(this.get_s16("poison_plague") > blob.get_s16("poison_plague")){
			blob.set_s16("poison_plague",this.get_s16("poison_plague"));
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(hitterBlob is null)return damage;

	if(XORRandom(2) == 0)
	if(hitterBlob.get_s16("poison_plague") > this.get_s16("poison_plague")){
		this.set_s16("poison_plague",hitterBlob.get_s16("poison_plague"));
	}

	return damage;
}