
#include "MakeSeed.as"
#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
	
	this.addCommandID("use");
	
	this.Tag("invincible");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("use"), "Extract Seed");
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{
		if(getNet().isServer()){
			server_MakeSeed(this.getPosition(), "grain_plant");
			this.server_Die();
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData == Hitters::burn || customData == Hitters::fire)return damage;

	return 0;
}
