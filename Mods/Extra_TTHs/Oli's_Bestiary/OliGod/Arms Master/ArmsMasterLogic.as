// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.
#include "Explosion.as";

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
	this.set_u8("chakrams", 2);
	this.set_bool("loaded", false);
	this.set_u32("loading timer", 0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16)); //This basically sets our score board icon.
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(blob !is null)
	{
		if(blob.getName() == "chakram" && blob.getTeamNum() == this.getTeamNum())
		{
			if (getNet().isServer() && getGameTime() > blob.get_u32("pickup timer"))
			{
				blob.server_Die();
				this.set_u8("chakrams", Maths::Min(this.get_u8("chakrams")+1, 2));
				Sound::Play("PutInInventory.ogg", this.getPosition());
			}
		}
	}
}
void onDie( CBlob@ this )
{
	this.Tag("nu");
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
		if(getNet().isServer())
		{
			this.server_Heal(4.0f);
		}
		if(getGameTime() > this.get_u32("loading timer") && this.get_bool("loading") == true)
		{
			this.set_bool("loaded", true);
			this.set_bool("loading", false);
			Sound::Play("StoneFall2.ogg", this.getPosition());
		}
		if(this.isKeyJustPressed(key_action3)) //And we hit action3(default spacebar)
		{
			CBlob@ carried = this.getCarriedBlob(); //Get what we are carrying
			if(carried is null) //If we are carrying something...
			{
				client_SendThrowOrActivateCommand(this); //...throw it! Or activate it.
			}
		}
		//Throw chakrams on left click!
		if(this.isKeyJustPressed(key_action2) && this.get_u32("loading timer") < getGameTime())
		{
				if (getNet().isServer())
				{
					Vec2f thisway = this.getAimPos() - this.getPosition();
					thisway.Normalize();
					CBlob@ chakram = server_CreateBlob("chakram", this.getTeamNum(), this.getPosition()+thisway*4);
					chakram.setVelocity(thisway*10);
					this.set_u8("chakrams", this.get_u8("chakrams")-1);
					CPlayer@ player = this.getPlayer();
					chakram.SetDamageOwnerPlayer(player);
					Sound::Play("BolterFire.ogg", this.getPosition());
					
				}
		}
		//Shoot the hand cannon on right click, if the player is loaded!
		if(this.isKeyJustPressed(key_action1) && this.get_u32("loading timer") < getGameTime())
		{
			if (this.get_bool("loaded"))
			{
				Vec2f thisway = this.getAimPos() - this.getPosition();
				thisway.Normalize();
				if(getNet().isServer())
				{
					server_CreateBlob("explode", this.getTeamNum(), this.getPosition()+thisway*15);
				}
				this.setVelocity(-thisway*6);
				this.set_bool("loaded", false);
				return;
			}
			else
			{
				this.set_u32("loading timer", getGameTime()+5);
				this.set_bool("loading", true);
			}
		}
		else
		{
			RunnerMoveVars@ moveVars;
			if (!this.get("moveVars", @moveVars))
			{
				return;
			} 
			if(moveVars !is null)
			{
				moveVars.walkFactor *= 3.0f;
				moveVars.jumpFactor *= 5.0f;
			}
		}
	}
	/////////////////////////////
	//That's it for the template class. You would usually add your code for abilities or attacks here.
	
	//If you wanna check if the player is pressing left click, use: if(this.isKeyPressed(key_action1))
	//Similarily, right click is: if(this.isKeyPressed(key_action2))
	
	//I can't really help or explain more. Making classes is hard and difficult. Every class is different, so there's no method to make every class.
	//Hope these files helped!
	//////////////////////////////
}