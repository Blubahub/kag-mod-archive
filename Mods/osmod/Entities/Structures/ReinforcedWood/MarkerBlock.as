
#include "ExtraSparks.as";

void onSetStatic(CBlob@ this, const bool isStatic)
{
	Mark(this);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if(this.hasTag("marker")) return false;
	return true;
}
void onDie(CBlob@ this)
{
	string blobname = this.getName();
	if(!getNet().isServer() || !this.getShape().isStatic()) return;
	CBlob@ blob = server_CreateBlob(blobname, this.getTeamNum(), this.getPosition());
	if(blob is null) return;
	blob.setAngleDegrees(this.getAngleDegrees());
	blob.SetFacingLeft(this.isFacingLeft());
	blob.getShape().SetStatic(true);
	
}
void Construct(CBlob@ this)
{

	this.Untag("marker");
	Vec2f pos = this.getPosition();
	mapSparks(pos, 0, 1.0f);
	//this.RemoveScript("IgnoreDamage.as");
	this.server_SetHealth(this.getInitialHealth());
	this.getSprite().setRenderStyle(RenderStyle::normal);
}
void Mark(CBlob@ this)
{

	this.Tag("marker");
	this.server_SetHealth(999);
	this.getSprite().setRenderStyle(RenderStyle::light);
	//this.AddScript("IgnoreDamage.as");
}