
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getSprite().animation.frame = 0;
	this.server_setTeamNum(-1);
	
	this.addCommandID("use");
	
	this.set_u8("state",0);
	this.set_u8("heat",0);
	this.set_u8("nearfire",0);
	
	this.getCurrentScript().tickFrequency = 10;
}

void onTick(CBlob @ this){

	int frame = 0;
	
	frame = this.get_u8("state")*2;
	
	if(this.get_u8("heat") > 50)frame += 1;
	
	this.getSprite().SetFrame(frame);
	
	if(this.get_u8("heat") > 75){
		this.set_u8("state",2);
		if(getNet().isServer())this.Sync("state",true);
	}
	
	if(this.get_u8("nearfire") > 0){
		
		if(this.get_u8("nearfire") > 0)this.set_u8("nearfire",this.get_u8("nearfire")-1);
		if(this.get_u8("heat") < 100)this.set_u8("heat",this.get_u8("heat")+1);
		
	} else if(this.get_u8("heat") > 0)this.set_u8("heat",this.get_u8("heat")-1);

	if(this.get_u8("heat") > 45)if(getNet().isServer())this.Sync("heat",true);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire)
	{
		this.set_u8("nearfire",4);
		damage = 0;
	}

	if (customData == Hitters::water)
	{
		this.set_u8("heat",0);
	}

	return damage;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this && this.isOverlapping(caller) && this.get_u8("heat") < 50){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(19, Vec2f(0,0), this, this.getCommandID("use"), "Use", params);
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("use"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "metalore")
					if(this.get_u8("state") == 0){
						this.set_u8("state",1);
						this.Sync("state",true);
						hold.server_Die();
					}
					
				}
			}
			if(getNet().isServer()){
				if(this.get_u8("state") == 2){
					this.set_u8("state",0);
					server_CreateBlob("metalbar",-1,this.getPosition());
					this.Sync("state",true);
				}
			}
		}
	}
}