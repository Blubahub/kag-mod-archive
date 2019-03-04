
#include "BombCommon.as";

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.bullet = true;
	consts.net_threshold_multiplier = 4.0f;
	this.Tag("projectile");

	//dont collide with top of the map
	this.SetMapEdgeFlags(0);

	this.server_SetTimeToDie(100);
	
	this.getSprite().SetLighting(false);
	this.getSprite().SetZ(-49.0f);
	
	this.SetLight(true);
	this.SetLightRadius(8);
	this.SetLightColor(SColor(255, 0, 255, 255));
	
	
	
	this.set_u16("birth",getMap().getTimeSinceStart());
}

void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();

	f32 angle;

	angle = (this.getVelocity()).Angle();
	this.setAngleDegrees(-angle);

	shape.SetGravityScale(0.0f);
	
	if(this.get_u16("birth") < getMap().getTimeSinceStart()-10){
		CBlob @laser = server_CreateBlob(this.getName(),this.getTeamNum(),this.getPosition());
		if(laser !is null)laser.setVelocity(this.getVelocity());
		this.server_Die();
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(blob !is null)
	if(blob.getName() == "shield" && this.getTeamNum() != blob.getTeamNum())
	{
		blob.server_Die();
		Sound::Play("shield_pop.ogg");
		Sound::Play("ion_hit.ogg");
		this.server_Die();
	}
	
	if(this !is null && blob !is null)
	if(blob.getName() == "turret" && this.getTeamNum() != blob.getTeamNum())
	{
		Sound::Play("ion_hit.ogg");
		this.server_Die();
	}
	
	if(solid){
		Sound::Play("ion_hit.ogg");
		this.server_Die();
	}
	
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("projectile"))
	{
		return false;
	}
	
	if(blob.getName() == "shield" && this.getTeamNum() != blob.getTeamNum())
	{
		return true;
	}

	bool check = this.getTeamNum() != blob.getTeamNum();
	if (!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (check)
	{
		if (this.getShape().isStatic() ||
		        this.hasTag("collided") ||
		        blob.hasTag("dead") ||
		        blob.hasTag("ignore_arrow"))
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	return false;
}

void onDie(CBlob@ this)
{
	
	CBlob@[] blobs;
	
	int radius = 40;
	
	if(this.getName() == "ion2")radius = 80;
	
	getMap().getBlobsInRadius(this.getPosition(), 40, blobs);
	
	for (u32 k = 0; k < blobs.length; k++)
	{
		CBlob@ blob = blobs[k];
		if(blob.getName() == "shield"){
			blob.server_Die();
		}
		if(blob.hasTag("room")){
			
			int amount = 1;
			
			if(this.getName() == "ion2")amount = 2;
			
			blob.set_u16("IonTime",blob.get_u16("IonTime")+5*amount);
			blob.set_u16("IonDamage",blob.get_u16("IonDamage")+amount);
		}
		if(blob.getName() == "turret"){
			
			int amount = 1;
			
			if(this.getName() == "ion2")amount = 2;
			
			if(blob.get_u16("charge_time") > 150*amount)
				blob.set_u16("charge_time",blob.get_u16("charge_time")-150*amount);
			else
				blob.set_u16("charge_time",0);
		}
	}
	
}