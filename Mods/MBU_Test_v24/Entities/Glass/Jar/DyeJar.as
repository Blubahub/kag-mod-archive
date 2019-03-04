
#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.server_setTeamNum(0);
	
	this.set_s8("contents", -1);
	
	this.set_u8("meat",0);
	this.set_u8("plant",10);
	this.set_u8("starch",0);
}

void onTick(CBlob @this){
	if(this.getSprite() !is null){
		this.getSprite().animation.frame = this.get_s8("contents");
		if(this.get_s8("contents") < 0 || this.get_s8("contents") > 6)this.getSprite().animation.frame = 7;
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is null && caller.getCarriedBlob() !is this)
	if(caller.getCarriedBlob().hasTag("can_dye")){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(20, Vec2f(0,0), this, this.getCommandID("fill"), "Dye", params);
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("drink"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && !this.hasTag("drank"))
		{
			Sound::Play("puke.ogg", caller.getPosition(), 1.0f);
			caller.Chat("Blergh, not worth it...");
			
			this.Tag("drank");
			
			if(getNet().isServer()){
				if(this.get_s8("contents") != -1){
					caller.set_u8("cloth_colour",this.get_s8("contents"));
					caller.Sync("cloth_colour",true);
				}
				this.server_Die();
				server_CreateBlob("jar",0,this.getPosition());
				SetKnocked(caller,60,true);
			}
			
			
		}
	}
}