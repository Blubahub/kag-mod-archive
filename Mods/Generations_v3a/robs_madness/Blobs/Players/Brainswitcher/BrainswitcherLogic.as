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
	
	this.set_s16("braintimer",0);
	this.set_s16("braintimer2",0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 12, Vec2f(16, 16));
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
	
	if (getNet().isServer())
	if(this.get_s16("braintimer") < 1){
		if(this.isKeyPressed(key_action1))
		{
			CBlob @blob = server_CreateBlob("convert", this.getTeamNum(), this.getPosition());
			if (blob !is null)
			{
			
				Vec2f smiteVel = this.getAimPos()-this.getPosition();
				smiteVel.Normalize();
				blob.setVelocity(smiteVel*2.0f);
			}
			this.set_s16("braintimer",30);
			this.set_u16("CooldownOne",getGameTime()+30);
		}
	}
	this.set_s16("braintimer",this.get_s16("braintimer")-1);
	
	if (getNet().isServer())
	if(this.get_s16("braintimer2") < 1){
		if(this.isKeyPressed(key_action2))
		{	
			CPlayer@ ply = this.getPlayer();
			
			if (ply !is null)
			{
				CBlob@ blob = server_CreateBlob("switch", this.getTeamNum(), this.getPosition());
				if (blob !is null)
				{
					blob.set_u16("owner_id", ply.getNetworkID());
					// print("" + ply.getNetworkID());
					
					Vec2f smiteVel = this.getAimPos()-this.getPosition();
					smiteVel.Normalize();
					blob.setVelocity(smiteVel*4.0f);
				}
				this.set_s16("braintimer2",150);
				this.set_u16("CooldownTwo",getGameTime()+150);
			}
		}
	}
	this.set_s16("braintimer2",this.get_s16("braintimer2")-1);
}
