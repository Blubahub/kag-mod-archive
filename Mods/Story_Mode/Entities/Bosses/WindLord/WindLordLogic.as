// Builder logic

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "MakeMat.as";
#include "Help.as";

void onInit(CBlob@ this)
{
	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	shape.SetGravityScale(0.0f);

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_u8("cooldown", 0);
	
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	Vec2f vel = this.getVelocity();
	
	Vec2f surfacepos;
	if(getMap().rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,60), surfacepos))this.setVelocity(Vec2f(vel.x,-2));

	int range = 1;
	
	this.set_u8("cooldown", this.get_u8("cooldown")+1);
	if(this.getHealth() <= this.getInitialHealth()/2){this.set_u8("cooldown", this.get_u8("cooldown")+1);range += 1;}
	if(this.getHealth() <= this.getInitialHealth()/4){this.set_u8("cooldown", this.get_u8("cooldown")+2);range += 1;}
	
	if(this.get_u8("cooldown") > 60){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f*range, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("player") && !b.hasTag("dead"))if(b.getTeamNum() != this.getTeamNum())
				{
					if(getNet().isServer()){
						CBlob @blob = server_CreateBlob("windbolt", this.getTeamNum(), this.getPosition());
						if (blob !is null)
						{
							Vec2f shootVel = b.getPosition()-this.getPosition();
							this.setAimPos(b.getPosition());
							shootVel.Normalize();
							blob.setVelocity(shootVel*(5+range));
						}
					}
					this.set_u8("cooldown", 0);
					
					if(getMap().getMapName() == "SkyLands.png"){
						if(!this.hasTag("said_intro")){
							this.Chat("Foolish! You dare come through my lands? For what purpose, to kill him? HAHA, good luck beating me first.");
							this.Tag("said_intro");
						}
						
						if(this.getHealth() <= this.getInitialHealth()/2)
						if(!this.hasTag("said_half")){
							this.Chat("Stop fighting! It's pointless, you can't defeat someone as powerful as I!");
							this.Tag("said_half");
						}
						
						if(this.getHealth() <= this.getInitialHealth()/4)
						if(!this.hasTag("said_quarter")){
							this.Chat("Fine, kill me if you must, but if I were you, I'd turn back now! Even I couldn't defeat him with this power...");
							this.Tag("said_quarter");
						}
					} else {
						if(!this.hasTag("said_intro")){
							this.Chat("Stay out of my way adventurers, or you'll end up like the village, ruined and destroyed.");
							this.Tag("said_intro");
						}
						
						if(this.getHealth() <= this.getInitialHealth()/2)
						if(!this.hasTag("said_half")){
							this.Chat("Stop fighting! Can't you see, I'm now strong enough to kill him once and for all!");
							this.Tag("said_half");
						}
						
						if(this.getHealth() <= this.getInitialHealth()/4)
						if(!this.hasTag("said_quarter")){
							this.Chat("You really want our precious world to go to ruin don't you!");
							this.Tag("said_quarter");
						}
					}
					
					
					this.setVelocity(Vec2f(XORRandom(11)-5,-2));
				}
			}
		}
	}
}