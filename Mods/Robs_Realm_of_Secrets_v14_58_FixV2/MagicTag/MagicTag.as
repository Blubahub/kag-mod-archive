
void onInit(CBlob @this){

	this.set_string("Tag","no tag");

	this.set_u8("option",0);
	// 0 - None, tag dissapears
	// 1 - Self
	// 2 - AOE
	// 3 - none player touched

	this.set_u8("image_index",0);
	
	this.Untag("PickedUp");
	
	this.addCommandID("self");
	this.addCommandID("aoe");
	this.addCommandID("touched");
}

void onTick(CBlob @this){

	if (getGameTime() % 2 == 0)
	if(this.getSprite().isAnimation("activate")){
		if(this.get_u8("image_index") < 15)this.set_u8("image_index",this.get_u8("image_index")+1);
		this.getSprite().SetFrame(this.get_u8("image_index"));
	}
	
	if(this.isAttached()){
		this.Tag("PickedUp");
	} else {
		if(this.hasTag("PickedUp")){
			if(this.get_u8("image_index") == 15){
			
				if(this.get_u8("option") == 2){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							b.Tag(this.get_string("Tag"));
						}
					}
				}
			
				this.server_Die();
			
			}
		}
	}

}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() is this){
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(19, Vec2f(0,-8), this, this.getCommandID("self"), "Self", params);
		}
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("aoe"), "AoE", params);
		}
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(9, Vec2f(0,8), this, this.getCommandID("touched"), "Touch", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{	
	if (cmd == this.getCommandID("self")){
		this.set_u8("option",1);
		if(this.isAttached()){
			if(this.getAttachments().getAttachedBlob("PICKUP") !is null){
				this.getAttachments().getAttachedBlob("PICKUP").Tag(this.get_string("Tag"));
				this.getAttachments().getAttachedBlob("PICKUP").DropCarried();
			}
		}
	}
	if (cmd == this.getCommandID("aoe")){
		this.set_u8("option",2);
	}
	if (cmd == this.getCommandID("touched")){
		this.set_u8("option",3);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	if(!this.hasTag("PickedUp"))
	if(blob.getPlayer() !is null){
		if(blob.getPlayer().isMod() || blob.getPlayer().getUsername() == "Pirate-Rob"){
			return true;
		}
	}
	
	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(solid && this.hasTag("PickedUp") && !this.isAttached())
	{
		if(this.getSprite().isAnimation("default")){
			this.getSprite().SetAnimation("activate");
		}
	}
	if(blob !is null){
		if(!blob.hasTag("player")){
			if(this.get_u8("option") == 3){
				blob.Tag(this.get_string("Tag"));
			}
		}
	}
}