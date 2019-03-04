
#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.server_setTeamNum(0);
	
	this.addCommandID("use");
	
	this.set_s8("contents", -1);
}

void onTick(CBlob @this){
	if(this.getSprite() !is null){
		this.getSprite().animation.frame = this.get_s8("contents")+1;
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(22, Vec2f(0,0), this, this.getCommandID("use"), "Drink", params);
	} else
	if(caller.getCarriedBlob() !is null){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("use"), "Use", params);
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "flower_bundle"){
						this.set_s8("contents", hold.getTeamNum());
						this.Sync("contents",true);
						hold.server_Die();
					}
					if(hold.hasTag("can_dye")){
						hold.server_setTeamNum(this.get_s8("contents"));
						this.set_s8("contents", -1);
						this.Sync("contents",true);
					}
				}
			}
			
			if(hold is this && this.get_s8("contents") != -1){
				Sound::Play("puke.ogg", caller.getPosition(), 1.0f);
			}
			
			if(getNet().isServer())
			if(hold is this && this.get_s8("contents") != -1){
				caller.set_u8("cloth_colour",this.get_s8("contents"));
				caller.Sync("cloth_colour",true);
				this.set_s8("contents", -1);
				this.Sync("contents",true);
				caller.DropCarried();
				SetKnocked(caller,60,true);
			}
			
			
		}
	}
}