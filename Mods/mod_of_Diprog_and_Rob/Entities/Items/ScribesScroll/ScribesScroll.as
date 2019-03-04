
#include "RuneScrollLogic.as";
#include "RuneNames.as";

void onInit( CBlob@ this )
{
	this.addCommandID("use");
	this.set_s16("power",100);
}

void onTick( CBlob@ this )
{
	if(this.get_s16("power") < 100)this.set_s16("power",this.get_s16("power")+1);
	
	if(this.isInWater())if(!this.isAttached())this.server_Hit(this, this.getPosition(), this.getVelocity(), 0.25f, Hitters::suddengib, false);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("use"), "What will this scroll do?", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{
		if(this.get_s16("power") > 0){
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if(caller !is null){
				readRunes(this, caller, this.get_string("scroll"));
				//print("Used: " + this.get_string("scroll"));
			}
		}
	}
}

void onTick(CSprite@ this)
{
	this.SetAnimation("colour");
	if(this.getBlob().get_string("scroll") != ""){
		this.animation.frame = getRuneFromLetter(this.getBlob().get_string("scroll").substr(0,1));
	}
}