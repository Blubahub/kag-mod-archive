//Ghost logic

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "ElementalControl.as";
#include "ChangeClass.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, -152.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.Tag("ignore_flags");
	
	this.set_string("old_class","builder");
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(this.getPosition().y > getMap().tilemapheight*8-32)this.AddForce(Vec2f(0,-200));
	
	if(getNet().isServer())
	if(this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_action3)){
		CBlob @human = ChangeClass(this,this.get_string("old_class"),this.getPosition(),this.getTeamNum());
		human.Tag("BloodMenu");
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}