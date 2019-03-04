#include "CopyTatoos.as";

void onInit(CBlob@ this)
{

	this.Tag("polymorphed");
	this.set_string("oldtype","builder");
	this.set_s16("time",1);

}


void onTick(CBlob@ this)
{
	if (!getNet().isServer())
	{
		return;
	}
	if(this.get_s16("time") < 0 || this.hasTag("cleanse")){
	
		CBlob @newBlob = server_CreateBlob(this.get_string("oldtype"), this.getTeamNum(), this.getPosition());

		if (newBlob !is null)
		{
			// copy health and inventory
			// make sack
			CInventory @inv = this.getInventory();

			if (inv !is null)
			{
				this.MoveInventoryTo(newBlob);
			}

			// plug the soul
			newBlob.server_SetPlayer(this.getPlayer());
			newBlob.setPosition(this.getPosition());

			// no extra immunity after class change
			if (this.exists("spawn immunity time"))
			{
				newBlob.set_u32("spawn immunity time", this.get_u32("spawn immunity time"));
				newBlob.Sync("spawn immunity time", true);
			}

			if (this.exists("knocked"))
			{
				newBlob.set_u8("knocked", this.get_u8("knocked"));
				newBlob.Sync("knocked", true);
			}
			copyTatoos(this,newBlob);
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
			this.server_Die();
		}
	
	} else {
		this.set_s16("time",this.get_s16("time")-1);
	}
}