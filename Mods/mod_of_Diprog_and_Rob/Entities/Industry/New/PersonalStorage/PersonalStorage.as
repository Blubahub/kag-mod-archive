const Vec2f buttonOffset = Vec2f(6,0);
const Vec2f inventoryButtonOffset = Vec2f(-6,0);

void onInit( CBlob@ this )
{
	this.addCommandID("lock");
	this.addCommandID("unlock");
	this.addCommandID("own");
	
	this.set_TileType("background tile", CMap::tile_wood_back);
	this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;
	
	this.Tag("inventory access");
	this.inventoryButtonPos = inventoryButtonOffset;

	CShape@ shape = this.getShape();
	if(shape !is null)
	{
		this.set_u8("button_radius", Maths::Max(this.getRadius(), (shape.getWidth() + shape.getHeight()) / 2));
	}
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (!caller.isOverlapping(this)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	string owner = this.get_string("owner_username");
	string ownerName = this.get_string("owner_name");

	u8 radius = this.get_u8("button_radius");

	if (!this.hasTag("owned"))
	{
		CButton@ button = caller.CreateGenericButton( 0, buttonOffset, this, this.getCommandID("own"), "Set as yours", params );
		button.enableRadius = radius;
	}
	else if (caller.getPlayer().getUsername() == owner && !this.hasTag("locked") && this.hasTag("owned")) 
	{
		CButton@ button = caller.CreateGenericButton( 0, buttonOffset, this, this.getCommandID("lock"), "Lock", params );
		button.enableRadius = radius;
	}
	else if (caller.getPlayer().getUsername() == owner && this.hasTag("locked")) 
	{
		CButton@ button = caller.CreateGenericButton( 1, buttonOffset, this, this.getCommandID("unlock"), "Unlock", params );
		button.enableRadius = radius;
	}
	else if (caller.getPlayer().getUsername() != owner)
	{
		
		CButton@ button = caller.CreateGenericButton( 9, buttonOffset, this, 0, "You can't lock/unlock storage. The owner is " + ownerName );
		if (button !is null) 
		{
			button.SetEnabled( false );
			button.enableRadius = radius;
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{	
	if (cmd == this.getCommandID("own"))
	{
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		CPlayer@ player;
		if (blob !is null) @player = blob.getPlayer();
		if (player !is null) 
		{
			this.set_string("owner_username", player.getUsername());
			this.set_string("owner_name", player.getCharacterName());
		}
		this.Tag("owned");
	}
	else if (cmd == this.getCommandID("lock"))
	{
		this.Untag("inventory access");
		this.Tag("locked");
	}
	else if (cmd == this.getCommandID("unlock"))
	{
		this.Tag("inventory access");
		this.Untag("locked");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this) &&  this.hasTag("inventory access"));
}
