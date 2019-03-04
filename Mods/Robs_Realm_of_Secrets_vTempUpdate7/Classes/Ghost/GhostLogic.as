//Ghost logic

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "ElementalControl.as";
#include "ClassChangeDataCopy.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);
	
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("player");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, -152.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_s16("corruption",0);
	
	this.set_s16("invisible",1);
	
	this.Tag("ghost");
	this.Tag("spirit_view");
	this.Tag("ignore_flags");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("GhostIcon.png", 0, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(this.getPosition().y > getMap().tilemapheight*8-32)this.AddForce(Vec2f(0,-200));
	
	if(this.isKeyPressed(key_action2) || this.isKeyPressed(key_action1)){
		ControlElements(1,this.getAimPos(),false,false,false,false,false,false,false,true,false,false,false);
	}
	
	if(this.get_s16("death") <= 0){
		this.set_s16("invisible",1);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return ((blob.getName() == "goldenstatue" && !this.hasTag("goldenstatue")) || blob.getName() == "ectoplasm");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(blob !is null)
	{
		if(blob.getName() == "ectoplasm"){
			this.set_s16("death",this.get_s16("death")+blob.getQuantity());
			blob.server_Die();
		}
		if(blob.getName() == "death_blob" && blob.get_u8("moldable") <= 0){
			this.set_s16("death",this.get_s16("death")+blob.get_s16("size"));
			blob.server_Die();
		}
	}
}