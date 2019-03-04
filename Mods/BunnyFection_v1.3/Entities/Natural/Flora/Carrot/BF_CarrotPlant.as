// BF_CarrotPlant script
const u16 GROWTH_SPEED =  60 * 30;
const u8 GROWTH_MAX = 3;

void onInit(CBlob@ this)
{
    this.set_u8( "growth_level", 0 );
    this.getCurrentScript().tickFrequency = GROWTH_SPEED;
	//print( "initPLANTGrowLVL: " + this.get_u8( "growth_level" ) );
	this.getSprite().SetZ(9.0f);
	this.SetFacingLeft(XORRandom(2) == 0);
	this.Tag( "flora" );
}

void onTick(CBlob@ this)
{
	u8 nextLVL = this.get_u8( "growth_level" )  + 1;
    if ( nextLVL <= GROWTH_MAX )
    {
        this.set_u8( "growth_level", ( nextLVL ) );
        this.getSprite().SetFrameIndex( nextLVL );
		//print("::::onTick::::Growth_level = " + ( nextLVL ) );
    } else
		this.getCurrentScript().tickFrequency = 0;
}

void onDie( CBlob@ this )
{
	if (!getNet().isServer())
		return;
		
    CBlob@ bf_carrot = server_CreateBlobNoInit( "bf_carrot" );
    if (bf_carrot !is null)
	{
		bf_carrot.set_u8( "growth_level", this.get_u8( "growth_level" ) );
		bf_carrot.server_setTeamNum(0);
		bf_carrot.setPosition( this.getPosition() + Vec2f( 0, -1 ) );
		bf_carrot.Init();
	}
}