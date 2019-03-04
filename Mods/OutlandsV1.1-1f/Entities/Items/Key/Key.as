#include "Friend.as";

void onInit( CBlob@ this )
{
	this.addCommandID("Use");
	this.set_u8("cooldown", 40);
	this.Sync("cooldown", true);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	//if(caller)
	if(this.get_u8("cooldown") == 1)
	{
		CButton@ button = caller.CreateGenericButton(3, Vec2f_zero, this, this.getCommandID("Use"), "Use this key.", params);
		if (this.isAttachedTo(caller))
		{
			button.SetEnabled(true);
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("Use"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CPlayer@ p = caller.getPlayer();
		CRules@ rules = getRules();
		if (caller !is null && rules !is null)
		{
			//p.set_bool("key"+this.getTeamNum(), true);
			//p.set_u8("Key"+this.getTeamNum(),1);
			//p.Sync("Key"+this.getTeamNum(), true);
			//ReloadFriends(p.getBlob());
			addFriend(rules, caller.getTeamNum(), this.getTeamNum());
			this.server_Die();
		}	
	}
}

void onTick(CBlob@ this)
{
	if(this.get_u8("cooldown") > 1)
	{
		this.set_u8("cooldown", this.get_u8("cooldown") - 1);
	}
}
