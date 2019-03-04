#include "ChangeClass.as";

void onInit( CBlob@ this )
{
	this.Tag("sword");
	this.addCommandID("equip");
	
	this.set_u8("sword_id",0);
	this.set_f32("sword_damage_multi",1);
}


void onTick( CBlob@ this )
{
	if(this.getAttachments() !is null){
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("SWORD");
		if(point !is null){
			CBlob@ holder = point.getOccupied();
			
			if (holder !is null){
				if(holder.getName() == "knight")this.getSprite().SetVisible(false);
				else this.getSprite().SetVisible(true);
			} else {
				this.getSprite().SetVisible(true);
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("equip"), "Equip sword", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if(caller !is null)
	{
		if (cmd == this.getCommandID("equip"))
		{
			if(caller.getName() != "knight"){
				if(getNet().isServer()){
					CBlob@ blob = ChangeClass(caller,"knight",caller.getPosition(),caller.getTeamNum());
					if(blob !is null){
						blob.server_AttachTo(this, "SWORD");
						if(this.get_u8("sword_id") == 4){ //Shadow blade hack. Makes the wielder become a 'slave'
							blob.set_string("boss",this.get_string("boss"));
						}
					}
				}
			} else {
				caller.DropCarried();
				caller.server_AttachTo(this, "SWORD");
				if(this.get_u8("sword_id") == 4){ //Shadow blade hack. Makes the wielder become a 'slave'
					caller.set_string("boss",this.get_string("boss"));
				}
			}
		}
	}
}