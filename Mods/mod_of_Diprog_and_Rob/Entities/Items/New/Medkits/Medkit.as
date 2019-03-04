#include "GetAttached.as"
#include "Help.as"

const int unpackHeartCount = 6;

void onInit( CBlob@ this )
{
	this.Tag("dont deactivate");
	this.set_u32("unpack heart count", unpackHeartCount);
	
	SetHelp( this, "help use carried", "", "Press Space to unpack","", 20); 
}

void onTick( CBlob@ this )
{
	if (this.getConfig() == "auto_medkit")
	{
		CBlob@ attached = getAttached(this, "PICKUP");
		if (attached !is null)
		{
			f32 initHP = attached.getInitialHealth();
			f32 HP = attached.getHealth();
			if (HP < initHP/1.5)
				for (f32 i = HP; i <= initHP; i++)
					unpackHeart(this);
		}
	}
	
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{	
	
	if (cmd == this.getCommandID("activate"))
		unpackHeart(this);
}

void unpackHeart(CBlob@ this)
{
	int heartCount = this.get_u32("unpack heart count");
	if (heartCount > 0)
	{
		if(getNet().isServer())
		{
			CBlob@ heart = server_CreateBlob( "heart", this.getTeamNum(), Vec2f(this.getPosition().x, this.getPosition().y - 2.0)); 
			heart.setVelocity(Vec2f((XORRandom(16)-8)*0.2f, -2 -XORRandom(8)*0.2f ));
			heartCount--;
			this.set_u32("unpack heart count", heartCount);
		}
	}
	else this.server_Die();
}