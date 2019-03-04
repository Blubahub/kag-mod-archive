const bool DECAY_DEBUG = false;

bool dissalowDecaying( CBlob@ this )
{
	return (
		this.getControls() !is null ||
		this.isInInventory() 
		// || (this.getShape() !is null && this.getShape().isStatic()) ||
		//this.isAttached()
		);	
}

void SelfDamage( CBlob@ this, f32 dmg )
{
	this.server_Hit( this, this.getPosition(), Vec2f_zero, dmg, 0);
}

void SelfDamage( CBlob@ this )
{
	const f32 initHealth = this.getInitialHealth();
	this.server_Hit( this, this.getPosition(), Vec2f_zero, 0.33f*initHealth, 0);
}