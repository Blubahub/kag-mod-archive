#include "Hitters.as"
#include "HumanoidCommon.as"

void onTick(CSprite@ this)
{
	this.SetZ(100.0f);
}

void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
	
	//this.addCommandID("use");
}
/*
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	//if(caller.getCarriedBlob() is this){
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(22, Vec2f(0,0), this, this.getCommandID("use"), "Heals light wounds", params);
	//}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("use"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			//if(hold !is null){
				if(getNet().isServer()){
					HealBody(caller,3);
					this.server_Die();
				}
			//}
		}
	}
}*/