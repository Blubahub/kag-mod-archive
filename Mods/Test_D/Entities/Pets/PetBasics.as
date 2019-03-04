#include "HoverMessage.as"
#include "Pets.as"

void onInit(CBlob@ this)
{
	this.Tag("pet");
	this.getShape().SetRotationsAllowed(false);
	//from client
	this.addCommandID("use");

	this.set_u32("last sound time", 0);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("use"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		if (blob is null) return;
		CBlob@ owner = getBlobByNetworkID(this.get_netid("owner"));
		if (owner is blob)
		{
			blob.server_AttachTo(this, 0);
		}
		else
		{
			if (owner !is null && owner.getPlayer() !is null){
				AddMessage(blob, "This is " + owner.getPlayer().getCharacterName() + "'s pet!" );
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	Vec2f pos = this.getPosition();
	if (blob !is null)
	{
		if (this.get_netid("owner") == blob.getNetworkID())
		{			
			if (PlayPetSound(this, "greet_sound")){
				AddMessage(this, this.get_string("greeting"));
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if (this.getTickSinceCreated() < 10)
	{
		PlayPetSound(this, "greet_sound");
	}
}
