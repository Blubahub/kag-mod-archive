void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 5;

	//cannot fall out of map
	this.SetMapEdgeFlags(u8(CBlob::map_collide_sides));

	this.Tag("medium weight");
	
	Vec2f pos = this.getPosition();

	this.addCommandID("pickup");

	//special item - prioritise pickup
	this.Tag("special");

	//minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 2, Vec2f(8, 16));
}

bool canBePickedUp(CBlob@ this, CBlob@ by)
{
	return !this.isAttached() && by.hasTag("player") &&
	       this.getDistanceTo(by) < 32.0f;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	return 0.0f;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (this.isAttached()) return;
	if (!blob.hasTag("player")) return; //dont attach to non players

	blob.server_AttachTo(this, "PICKUP");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getShape().isStatic());
}