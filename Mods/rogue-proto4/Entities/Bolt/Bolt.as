#include "/Entities/Common/Attacks/Hitters.as";
void onInit(CBlob @ this)
{
	this.getShape().setDrag(0.1);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (!blob.hasTag("dead") && blob.hasTag("enemy"));
}

void onTick(CBlob@ this)
{
	if(this.getTickSinceCreated() == 1) 
	{
		Vec2f vel = this.getVelocity();
		f32 angle = vel.Angle();
		this.set_f32("init_angle", angle);
	}
	this.setAngleDegrees(-this.get_f32("init_angle")+90);
	this.SetFacingLeft(false);/*
	if(vel.Length() < 5)
	{
		//this.server_Die();
	}*/

}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(blob is null || !blob.hasTag("enemy")) return;
	this.server_Hit(blob, this.getPosition(), this.getVelocity(), this.get_f32("damage"), Hitters::arrow, true);
	blob.AddForce(this.getVelocity()*40);
	this.server_Die();
	print("jahas");
}
