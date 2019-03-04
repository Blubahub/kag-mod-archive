// TFlippy
// Doesn't really do anything

#include "ParticleSparks.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("buoy");
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	
	this.set_u8("gas",0);
	
	this.addCommandID("gas_up");
	this.addCommandID("gas_down");
}

void onTick(CBlob@ this)
{
	int Height = 1;
	int OldHeight = 1;
	CMap@ map = this.getMap();
	Vec2f surfacepos;
	for(int i = 0; i < 15; i += 1){
		if(!map.rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,16*i), surfacepos))Height += 1;
		else {
			this.set_u16("lastHeight",surfacepos.y);
			break;
		}
	}
	for(int i = 0; i < 15; i += 1){
		if(this.getPosition().y+16*i < this.get_u16("lastHeight"))OldHeight += 1;
		else {
			break;
		}
	}
	if(Height > 14)Height = OldHeight;
	this.AddForce(Vec2f(0, (-500/Height)*this.get_u8("gas")));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (this.isOnGround() || this.isOnWall());
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	caller.CreateGenericButton(16, Vec2f(0,0), this, this.getCommandID("gas_up"), "Turn up the heat", params);
	caller.CreateGenericButton(19, Vec2f(0,16), this, this.getCommandID("gas_down"), "Turn down the heat", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("gas_up")){
		this.set_u8("gas",this.get_u8("gas")+1);
	}
	if (cmd == this.getCommandID("gas_down")){
		if(this.get_u8("gas") > 0)this.set_u8("gas",this.get_u8("gas")-1);
	}
}