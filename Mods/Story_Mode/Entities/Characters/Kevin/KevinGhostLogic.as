//Ghost logic

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));
	
	this.set_s8("offset",0);
	this.set_u8("timer",0);
}

void onTick(CBlob@ this)
{
	
	getRules().Tag("killedkevin");
	
	if(this.get_u8("timer") > 150){
		this.set_s8("offset",XORRandom(64)-32);
		this.set_u8("timer",0);
		
		
		if(!this.hasTag("mapintro")){
			this.Tag("mapintro");
			if(getMap().getMapName() == "KevinsPass.png")this.Chat("Oh, well, red didn't look good on me anyway.");
		} else {
			
			bool alone = true;
			bool deadbodies = false;
			
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 80.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b !is null){
						if(b.getTeamNum() == 0){
							if(b.hasTag("player") && !b.hasTag("dead"))alone = false;
							if(b.hasTag("player") && b.hasTag("dead"))deadbodies = true;
						}
					}
				}
			}
			
			if(!alone && deadbodies){
				if(XORRandom(2) == 0)this.Chat("Tell your friend lying on the ground to wake up now.");
				else if(XORRandom(2) == 0)this.Chat("Wakey wakey sleeping beauty~");
				else this.Chat("Your friend on the ground there is pretty lazy.");
			}
			else
			if(alone && deadbodies){
				if(XORRandom(2) == 0)this.Chat("C'mon guys, get up, we need to go adventuring.");
				else if(XORRandom(2) == 0)this.Chat("Stop sleeping around!");
				else if(XORRandom(2) == 0)this.Chat("You lazy bums.");
				else if(XORRandom(2) == 0)this.Chat("You can't rest in the middle of a battle!");
				else this.Chat("You can't be that tired.");
			}
			else
			if(alone){
				if(XORRandom(2) == 0)this.Chat("H-Hey! Don't leave me!");
				else if(XORRandom(2) == 0)this.Chat("Don't leave meeeeeee!");
				else if(XORRandom(2) == 0)this.Chat("You're forgetting something!");
				else this.Chat("Hellooo?");
			}
			else 
			{
				if(XORRandom(2) == 0)this.Chat("So, where we going?");
				else if(XORRandom(2) == 0)this.Chat("Careful of all that dirt!");
				else if(XORRandom(2) == 0)this.Chat("Ew, someone stinks.");
				else if(XORRandom(2) == 0)this.Chat("Wait, what do you mean I won't revive here?");
				else if(XORRandom(2) == 0)this.Chat("I almost died once, ya know that?");
				else if(XORRandom(2) == 0)this.Chat("Be careful around trees! They could fall on you and block your vision or something.");
				else this.Chat("ZZZzzz");
			}
		}
	}
	this.set_u8("timer",this.get_u8("timer")+1);
	
	
	
	
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 80.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null)
			if(b.hasTag("player") && !b.hasTag("dead") && b.getTeamNum() == 0)
			{

				Vec2f shootVel = (b.getPosition()+Vec2f(this.get_s8("offset"),-24))-this.getPosition();
				this.setAimPos(b.getPosition());
				if(shootVel.x > 12 || shootVel.x < -12 || shootVel.y > 12 || shootVel.y < -12){
					shootVel.Normalize();
					this.setVelocity(shootVel*3);
				}
				break;
			}
		}
	}
	
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}