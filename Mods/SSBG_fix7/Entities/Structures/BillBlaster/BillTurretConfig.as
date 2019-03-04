//set your turret values here


void onInit( CBlob@ this )
{	
	this.set_f32( "min_fire_distance", 2500.0f );
	this.set_u16( "shoot_interval", 40 );//plus a fixed 45 from the fuse
	this.set_u16( "target_lock_time", 25 );//values higher than 10 recommended to save on performance!
	this.set_bool( "arc360", true );//360 degrees firing?

	this.set_string( "projectile", "bullet_bill" );
	this.set_f32( "projectile_speed", 3.5f );
	this.set_f32( "projectile_lifetime", 0.75f );
	
	AttachmentPoint@ att = this.getAttachments().getAttachmentPointByName("PICKUP");
	att.SetKeysToTake( key_action1 );
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	bool firing = this.get_bool( "litFuse" );
	return ( !firing && this.getTeamNum() == byBlob.getTeamNum() );
}