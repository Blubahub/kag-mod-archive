
#include "TribeCommon.as";

void onInit(CBlob@ this)
{
	
	TribeInfo tribe;
	this.set("TribeInfo", @tribe);
	
	tribe.MakeFiller();
	
	this.set_string("TribeName","Gomlin");
	
	for(int i = 0; i < 10; i += 1){
		CBlob @gom = server_CreateBlob("gomlin", this.getTeamNum(), this.getPosition());
		gom.set_string("TribeName",this.get_string("TribeName"));
	}
}

void onTick(CBlob@ this)
{
	TribeInfo @tribe;
	if (!this.get("TribeInfo", @tribe))
	{
		return;
	}
}