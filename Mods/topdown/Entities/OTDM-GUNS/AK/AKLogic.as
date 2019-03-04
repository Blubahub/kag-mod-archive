/*
void onInit(CBlob@ this)
{
	return;
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action1);
}*/

#include "Hitters.as";
void onInit(CBlob@ this)
{	if(this.getShape() !is null) this.getShape().SetOffset(Vec2f(0, -6));
	this.Tag("no falldamage");
	this.set_u32("ammunition", 100);
	//this.Tag("super heavy weight");
	this.getShape().getConsts().collideWhenAttached = true;

	// Because BlobPlacement.as is *AMAZING*
	this.Tag("custom rotate");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action3);
	this.getCurrentScript().runFlags |= Script::tick_attached;
	this.Tag("weapon");
	this.set_string("weapon type", "slash");
	//this.set_string("hit state", "none");
}/*

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
	if(holder is null) return;


}*/


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	//this.getCurrentScript().runFlags |= Script::tick_attached;
	string hitstate = this.get_string("hit state");
	if(blob !is null && this.isAttached() && hitstate == "slashing" && blob.getTeamNum() != this.getTeamNum())
	{
		Vec2f diff = (blob.getPosition() - this.getPosition())*10;
		//this.AddForce(diff);
		diff.Normalize();
		diff *= 1000;
		print("sword hit");
		f32 hitpower = this.get_f32("hitpower");
		f32 damage = 1+(hitpower);
		//f32 damage =  Maths::Min(1, hitpower/45);
		print("damage: "+damage);
		this.server_Hit(blob, Vec2f_zero, diff, 1.0f, Hitters::sword, false);
		//blob.server_Die();
	}
}
	//return this.isAttached() && blob.getTeamNum() != this.getTeamNum() && 
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}