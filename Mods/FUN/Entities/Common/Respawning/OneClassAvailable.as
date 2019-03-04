#include "StandardRespawnCommand.as"

const string req_class = "required class";
void onInit(CBlob@ this)
{
	if(!this.exists(req_class))
		return;
	
	if(!this.exists("class button radius"))
	{
		CShape@ shape = this.getShape();
		if(shape !is null)
		{
			this.set_u8("class button radius", Maths::Max(this.getRadius(), (shape.getWidth() + shape.getHeight()) / 2));
		}
		else
		{
			this.set_u8("class button radius", 16);
		}
	}
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{

	string cfg = this.get_string(req_class);
    	if (canChangeClass(this,caller) && caller.getName() != cfg && (caller.getConfig() != "wizard" || caller.getConfig() != "crossbowman" || caller.getConfig() != "heavyknight")) 
    	{
		CBitStream params;
		write_classchange(params, caller.getNetworkID(), cfg);
		CButton@ button = caller.CreateGenericButton( "$change_class$", this.get_Vec2f("class offset"), this, SpawnCmd::changeClass, "Swap Class", params );

		button.enableRadius = this.get_u8("class button radius");
   	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	onRespawnCommand( this, cmd, params );
}

