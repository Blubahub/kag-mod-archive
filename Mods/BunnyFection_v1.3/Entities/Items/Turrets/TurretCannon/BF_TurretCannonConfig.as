//set your turret values here

void onInit( CBlob@ this )
{
	this.set_f32( "min_fire_distance", 110.0f );
	this.set_u16( "shoot_interval", 30 );//plus a fixed 45 from the fuse
	this.set_u16( "target_lock_time", 20 );//values higher than 10 recommended to save on performance!
	this.set_bool( "arc360", false );//360 degrees firing?

	this.set_string( "projectile", "bf_cannonball" );
	this.set_f32( "projectile_speed", 10.0f );
	this.set_f32( "projectile_lifetime", 0.75f );
	
	///global settings below
	this.Tag( "heavy weight" );
	this.Tag( "turret" );
	this.Tag( "place norotate" );
}

/*
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	bool firing = this.get_bool( "litFuse" );
	return ( !firing && this.getTeamNum() == byBlob.getTeamNum() );
}
*/

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}