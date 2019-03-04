
#include "EmotesCommon.as";


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("talk"))
	{
		string need = this.get_string("need");
		string give = this.get_string("give");
		CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ needed = blobsInRadius[i];
				if (needed !is null)
				{
					if (needed.getName() == need)
					{
						needed.server_Die();
						this.Chat("Good job sir. Take this " + give + ".");
						CBlob@ reward = server_CreateBlob(give, this.getTeamNum(), this.getPosition());
						set_emote(this, Emotes::thumbsup, 150);
						this.server_SetTimeToDie(5);
						return;
					}
				}
			}
		}
		this.Chat("Bring me a " + need + ", and I will give you a " + give);
		//this.getSprite().PlaySound("/DetachModule.ogg");
	}
}
void onInit(CBlob@ this)
{
	this.set_string("need", "boulder");
	this.set_string("give", "ballista");
	this.addCommandID("talk");
	this.set_string("type", "barter");
	this.set_string("information", "I am looking for something...\nMaybe you can help?");
	this.set_string("skinname", "Wanderer");
	this.Tag("type skin");
	CBlob@ carry = server_CreateBlob("crate", 0, this.getPosition());
	if(carry !is null)
	{
		this.server_Pickup(carry);
	}
}
void onTick(CBlob@ this)
{	
	this.getCurrentScript().tickFrequency = 250;
	if(XORRandom(16) > 10)
	{
		Vec2f targetposold = this.get_Vec2f("targetpos");
		targetposold.x = targetposold.x - 50 + XORRandom(100);
		this.set_Vec2f("targetpos", targetposold);

	}
	if(this.hasTag("targetpos set")) return;
	CBlob@[] spawns;
	if(getBlobsByTag("spawn point", @spawns))
	{
		for(uint i = 0; i < spawns.length; i++)
		{
			CBlob@ spawn = spawns[i];
			CMap@ map = getMap();
			if(spawn !is null && map !is null)
			{
				Vec2f pos = spawn.getPosition();
				f32 randomx = XORRandom(map.tilemapwidth * map.tilesize);
				Vec2f targetpos = Vec2f(randomx, pos.y+200);
				//print("pos: "+pos.x +", "+pos.y);
				this.set_Vec2f("targetpos", targetpos);
				this.setAimPos(targetpos);
				this.Tag("targetpos set");
				//print("targetpos set barter");
			}
		}
	}

}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{


	CButton@ button = caller.CreateGenericButton(
	"$pushbutton_1$",                           // icon token
	Vec2f_zero,                                 // button offset
	this,                                       // button attachment
	this.getCommandID("talk"),              // command id
	"Talk");                                // description

	button.radius = 16.0f;
	button.enableRadius = 32.0f;
}
