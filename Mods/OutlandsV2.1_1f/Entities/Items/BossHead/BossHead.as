void onInit(CBlob @ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
	this.Tag("ZombieHead");
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.getSprite().PlaySound( "Entities/Characters/Knight/ShieldHit.ogg" );
    return 0;
}