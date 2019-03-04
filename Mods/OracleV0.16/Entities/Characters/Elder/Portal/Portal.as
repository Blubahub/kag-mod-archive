// Lantern script
#include "Hitters.as"
void onInit(CBlob@ this)
{
   CShape@ shape = this.getShape();
   shape.SetGravityScale(0.0f);
   this.getCurrentScript().tickFrequency = 30;
   this.addCommandID("Teleport");
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	print("button call");
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
  
	CButton@ Fire_on = caller.CreateGenericButton( 4, Vec2f(0.0f,0.0f), this, this.getCommandID("Teleport"), "Teleport", params);
	if(caller.getDistanceTo(this) < 20.0f && this.getTeamNum() == caller.getTeamNum())
	{
		if(Fire_on != null)
		{
			Fire_on.SetEnabled(true);
		}
	}
	else
	{
			Fire_on.SetEnabled(false);
	}
	
	
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	u16 netID;
	if(!params.saferead_netid(netID))
	{
	    return;
	}
  CBlob@ caller = getBlobByNetworkID(netID);
   if(cmd == this.getCommandID("Teleport") &&  caller != null)
	{
		if(this.exists("Go"))
    {
      caller.setPosition(this.get_Vec2f("Go"));
    }
	}
}