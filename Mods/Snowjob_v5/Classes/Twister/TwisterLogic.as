// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f); //When the class/blob reaches negative 3 hp, it explodes into gore.

	this.Tag("player"); //This is a player
	this.Tag("flesh"); //This class is also flesh. Tags like plant/stone/metal don't work unless you code them yourself

	CShape@ shape = this.getShape(); //Getting our physics variable
	shape.SetRotationsAllowed(false); //Let's not roll all over the place.
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.addCommandID("dash");
	
	this.set_u8("charge",0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16)); //This basically sets our score board icon.
	}
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{
	if(this.isInInventory()) //Are we in an inventory? 
		return; //Yes? Back the heck out. We can't use abilities in inventories.

	const bool ismyplayer = this.isMyPlayer(); //Is this our player?

	if(ismyplayer && getHUD().hasMenus()) //If this is our player AND we are in a menu...
	{
		return; //...back the heck out!
	}

	// activate/throw
	if(ismyplayer) //If this is our player
	{

		if(this.isKeyJustPressed(key_action3)) //And we hit action3(default spacebar)
		{
			CBlob@ carried = this.getCarriedBlob(); //Get what we are carrying
			if(carried is null) //If we are carrying something...
			{
				client_SendThrowOrActivateCommand(this); //...throw it! Or activate it.
			}
		}
	}
	
	bool Action1 = this.isKeyJustPressed(key_action1);
	bool Action2 = this.isKeyPressed(key_action2);
	
	if(Action1)if(!this.hasTag("dashing")){
		this.SendCommand(this.getCommandID("dash"));
	}
	
	{
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 1.5f;
		}
	}
	this.getShape().SetGravityScale(0.5);
	
	if(!this.hasTag("dashing")){
		if(Action2){
			if(this.get_u8("charge") < 30)this.set_u8("charge",this.get_u8("charge")+1);
			else {
				if(getGameTime() % 8 == 0){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b !is null)if(b.getTeamNum() != this.getTeamNum() && b !is this)
							this.server_Hit(b, b.getPosition(), Vec2f(0,-1), 0.5f, Hitters::sword, true);
						}
					}
				}
			}
			RunnerMoveVars@ moveVars;
			if (this.get("moveVars", @moveVars))
			{
				moveVars.jumpFactor *= 0.2f;
				moveVars.walkFactor *= 0.2f;
			}
		} else this.set_u8("charge",0);
	} else this.set_u8("charge",0);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("dash")){
		this.Tag("dashing");
		Vec2f pos = this.getPosition();
		Vec2f aimpos = this.getAimPos();
		Vec2f vec = aimpos - pos;
		vec.Normalize();
		this.setVelocity(vec*8);
		this.setPosition(this.getPosition()+Vec2f(0,-2));
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if(solid){
		if(this.hasTag("dashing"))
		if(blob !is null){
			this.server_Hit(blob, blob.getPosition(), this.getVelocity(), 0.75f, Hitters::sword, true);
		}
		
		this.Untag("dashing");
	}
}