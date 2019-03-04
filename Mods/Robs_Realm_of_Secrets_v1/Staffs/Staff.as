// Drill.as

#include "Hitters.as";

void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
	this.addCommandID("mod");
}

void onTick(CBlob@ this)
{

	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder is null) return;

		this.getSprite().SetOffset(Vec2f(7,1));
		
		this.getShape().SetRotationsAllowed(false);


		if (holder.get_u8("knocked") > 0)
		{
			if(point.isKeyPressed(key_action1)){
				
			}
		}
	}
	else
	{
		this.getSprite().SetOffset(Vec2f(0,0));
		this.getShape().SetRotationsAllowed(true);
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("mod"), "Enchant staff.", params);
	button.SetEnabled(caller.getCarriedBlob() !is null);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("mod"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(hold.getName() == "lantern"){
					CBlob@ staff = server_CreateBlob("fire_staff", hold.getTeamNum(), this.getPosition());
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "heart"){
					CBlob@ staff = server_CreateBlob("blood_staff", hold.getTeamNum(), this.getPosition());
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				
				if(hold.getName() == "ghost_shard"){
					CBlob@ staff = server_CreateBlob("death_staff", hold.getTeamNum(), this.getPosition());
					caller.server_Pickup(staff);
					
					CBlob @newBlob = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
					if (newBlob !is null)
					{
						if(hold.getPlayer() !is null){
							newBlob.server_SetPlayer(hold.getPlayer());
							hold.Tag("switch class");
							hold.server_SetPlayer(null);
							staff.set_string("ghost",hold.getPlayer().getUsername());
						}
					}
					
					hold.server_Die();
					this.server_Die();
				}
			}
		}
	}
}