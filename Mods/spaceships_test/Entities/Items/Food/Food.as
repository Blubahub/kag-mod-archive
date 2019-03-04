void onInit( CBlob@ this )
{
	if (this.exists( "food name" )) {
		this.setInventoryName(this.get_string("food name"));  
	}

	if (this.exists( "food sprite" )) 
	{
		const u8 index = this.get_u8("food sprite");
		this.getSprite().SetFrameIndex( index );
		this.SetInventoryIcon( this.getSprite().getConsts().filename, index, Vec2f(16,16) );
	}
	
	this.Tag("food");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}			  
