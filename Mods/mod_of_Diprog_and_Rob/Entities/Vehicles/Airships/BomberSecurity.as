#include "GetAttached.as"
#include "VehicleCommon.as"

void onInit(CBlob@ this )
{
	this.addCommandID("own");
	this.addCommandID("lock");
	this.addCommandID("unlock");
	this.addCommandID("kick");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}

	if (attached !is null)
	{
		CBlob@ attachedattached = getAttached( attached, "PICKUP" );
		if (attachedattached !is null && (attachedattached.hasTag("heavy weight") || attachedattached.hasTag("medium weight")))
			attached.server_DetachAll();
		else 
		{
			if (!this.hasTag("locked"))
				Vehicle_onAttach( this, v, attached, attachedPoint );
		}
	}
}

//onDetach() is in Bomber.as

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	string owner = this.get_string("owner");
	
	if (!this.hasTag("owned"))
	{
		caller.CreateGenericButton( 0, Vec2f(-8,0), this, this.getCommandID("own"), "Set this bomber as yours.", params );
	}
	
	if (caller.getPlayer().getUsername() == owner && this.hasTag("owned"))
	{
		CBlob@ flyer = getAttached(this,"FLYER");
		if (flyer !is null && flyer.isAttached())
		{
			caller.CreateGenericButton( 1, Vec2f(-8,0), this, this.getCommandID("kick"), "Kick", params );
		}
		else if (this.hasTag("locked"))
		{
			caller.CreateGenericButton( 1, Vec2f(-8,0), this, this.getCommandID("unlock"), "Unlock", params );
		}
		else
		{
			caller.CreateGenericButton( 0, Vec2f(-8,0), this, this.getCommandID("lock"), "Lock", params );
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CPlayer@ player;
	CBlob@ blob = getBlobByNetworkID( params.read_netid() );
	if (blob !is null) @player = blob.getPlayer();

	if (cmd == this.getCommandID("lock"))
	{
		AttachmentPoint@ flyer = getFlyerPoint(this.getAttachments());
		flyer.offset = Vec2f(100000,100000);
		this.Tag("locked");
	}
	if (cmd == this.getCommandID("kick"))
	{
		CBlob@ flyer = getAttached(this,"FLYER");
		if (flyer !is null)
			flyer.server_DetachFrom(this);
	}
	if (cmd == this.getCommandID("unlock"))
	{
		AttachmentPoint@ flyer = getFlyerPoint(this.getAttachments());
		flyer.offset = Vec2f(0, -2);
		this.Untag("locked");
	}
	if (cmd == this.getCommandID("own"))
	{
		if (player !is null) this.set_string("owner", player.getUsername()); 
		this.Tag("owned");
	}
}

AttachmentPoint@ getFlyerPoint(CAttachment@ this)
{
	return this.getAttachmentPointByName("FLYER");
}