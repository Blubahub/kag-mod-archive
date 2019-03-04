
#include "Hitters.as";
#include "SplashWater.as";

//config

const int splash_width = 9;
const int splash_height = 7;
const int splashes = 3;

//logic
void onInit(CBlob@ this)
{
	this.getSprite().ReloadSprites(0, 0);
	this.addCommandID("splash");
	//if(!this.exists("HasOil"))
	//	this.set_bool("HasOil",false);
	this.set_bool("HasOil",true);
}

void onTick(CBlob@ this)
{
	//(prevent splash when bought filled)
	if(this.getTickSinceCreated() < 10) {
		return;
	}

	/*u8 filled = this.get_u8("filled");
	if (filled < splashes && this.isInWater())
	{
		this.set_u8("filled", splashes);
		this.set_u8("water_delay", 30);
		this.getSprite().SetAnimation("full");
	}*/

	if (this.get_bool("HasOil"))
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");


		if (point.getOccupied() !is null && point.getOccupied().isMyPlayer() && point.getOccupied().isKeyJustPressed(key_action1) && !this.isInWater())
		{
			print("Im throwing oil!!!");
			this.SendCommand(this.getCommandID("splash"));
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.get_bool("HasOil"))
	{
		DoSplash(this);
	}
}

/*f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(damage > 0.0f && hitterBlob !is null)
	{
		//spam hit
		if(hitterBlob is this)
		{
			int id = this.getNetworkID();
			this.setVelocity(this.getVelocity() + Vec2f(1,0).RotateBy((id * 933) % 360));
			TakeWaterCount(this);
		}
	}
	return damage;
}*/

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("splash"))
	{
		DoSplash(this);
	}
}

/*void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if (solid && getNet().isServer() && this.getShape().vellen > 6.8f && this.get_u8("filled") > 0)
	{
		this.SendCommand(this.getCommandID("splash"));
	}

}*/

/*void TakeWaterCount(CBlob@ this)
{
	u8 filled = this.get_u8("filled");
	if (filled > 0)
		filled--;

	if (filled == 0)
	{
		filled = 0;
		this.getSprite().SetAnimation("empty");
	}
	this.set_u8("filled", filled);
}*/

const uint splash_halfwidth = splash_width / 2;
const uint splash_halfheight = splash_height / 2;
const f32 splash_offset = 0.7f;

void DoSplash(CBlob@ this)
{
	//Throw oil!
	if(isServer())
	{
		server_CreateBlob("oileffect",-1,this.getPosition());
		//Maybe have custom onInit stuff for later
	}
	
}


//sprite

/*void onInit(CSprite@ this)
{
	this.SetAnimation("empty");
	if (this.getBlob().get_u8("filled") > 0)
	{
		this.SetAnimation("full");
	}
}*/
