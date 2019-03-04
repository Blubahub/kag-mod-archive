void onInit( CBlob@ this )
{
	this.addCommandID("take coins");
	this.addCommandID("add coins");
	this.addCommandID("own");
	
	this.set_u32("coins", 0);
	
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;
	
	AddIconToken( "$plus$", "BankIcons.png", Vec2f(16,16), 0 );
	AddIconToken( "$minus$", "BankIcons.png", Vec2f(16,16), 1 );
	
	
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	string owner = this.get_string("owner");
	int coinsinbank = this.get_u32("coins");
	if (!this.hasTag("owned"))
	{
		caller.CreateGenericButton( 0, Vec2f(0,0), this, this.getCommandID("own"), "Set this bank as yours", params );
	}
	else 
	{
		if (caller.getPlayer().getUsername() == owner && this.hasTag("owned")) 
		{
			caller.CreateGenericButton( "$minus$", Vec2f(2,0), this, this.getCommandID("take coins"), "Take 50 coins. Bank has " + coinsinbank + " coins", params );
			caller.CreateGenericButton( "$plus$", Vec2f(-2,0), this, this.getCommandID("add coins"), "Add 50 coins to bank. Bank has " + coinsinbank + " coins", params );
		}
		else if (caller.getPlayer().getUsername() != owner)
		{
			CButton@ button = caller.CreateGenericButton( 9, Vec2f(0,0), this, 0, "You can't add/take coins. Owner is " + owner );
			if (button !is null) button.SetEnabled( false );
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{	
	int coinsInBank = this.get_u32("coins");
	
	CPlayer@ player;
	CBlob@ blob = getBlobByNetworkID( params.read_netid() );
	if (blob !is null) @player = blob.getPlayer();

	if (cmd == this.getCommandID("own"))
	{
		if (player !is null) this.set_string("owner", player.getUsername()); 
		this.Tag("owned");
	}
	if (cmd == this.getCommandID("take coins"))
	{
		if (coinsInBank >= 50)
		{
			coinsInBank -= 50;
			player.server_setCoins((player.getCoins() + 50));
		}
		else
		{
			player.server_setCoins((player.getCoins() + coinsInBank));
			coinsInBank = 0;
		}
		this.set_u32("coins", coinsInBank);
	}
	else if (cmd == this.getCommandID("add coins"))
	{
		if (coinsInBank >= 0 && player.getCoins() >= 50)
		{
			coinsInBank += 50;
			player.server_setCoins((player.getCoins() - 50));
		}
		else
		{
			coinsInBank += player.getCoins();
			player.server_setCoins(0);
		}
		this.set_u32("coins", coinsInBank);
	}
}

void onDie(CBlob@ this)
{
	server_DropCoins(this.getPosition(), this.get_u32("coins"));
}