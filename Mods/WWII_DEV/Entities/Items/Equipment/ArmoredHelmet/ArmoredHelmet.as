// scroll script that makes enemies insta gib within some radius

#include "Hitters.as";
void onInit( CBlob@ this )
{
	this.addCommandID( "armoredhelmet" );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("armoredhelmet"), "Use this to put on your armored helmet.", params );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
			u16 caller_id = params.read_u16();
		CBlob@ caller = getBlobByNetworkID( caller_id );

	if (cmd == this.getCommandID("armoredhelmet"))
	{
	caller.Tag("armoredhelmet");	
	this.server_Die();
	addHead(caller, "armoredhelmethead");
	}
}

void addHead(CBlob@ playerblob, string headname)	//Here you need to add head overriding. If you dont need to override head just ignore this part of script.
{
	if(playerblob.get_string("equipment_head") == "")
	{
		if(playerblob.get_u8("override head") != 0)
			playerblob.set_u8("last head", playerblob.get_u8("override head"));
		else	
			playerblob.set_u8("last head", playerblob.getHeadNum());
	}


	if(headname == "armoredhelmethead")
	playerblob.set_u8("override head", 6);

	playerblob.Tag(headname);
	playerblob.set_string("reload_script", headname);
	playerblob.AddScript(headname+"_effect.as");
	playerblob.set_string("equipment_head", headname);
	playerblob.Tag("update head");
}
