
#include "OrbCommon.as";
#include "Hitters2.as";
#include "WizardCommon.as";
#include "TeamColour.as";

void onInit( CBlob@ this )
{
    this.set_u8("custom_hitter", Hitters::orb);
	this.Tag("exploding");
	this.set_f32("explosive_radius", 12.0f );
	this.set_f32("explosive_damage", 2.0f);
	this.set_f32("map_damage_radius", 15.0f);
	this.set_f32("map_damage_ratio", -1.0f); //heck no!
}	

void onTick( CBlob@ this )
{     
	if(this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale( 0.0f );
		this.server_SetTimeToDie(8);
		this.SetLight( true );
		this.SetLightRadius( 32.0f );
		this.SetLightColor( getTeamColor(this.getTeamNum()) );
		this.set_string("custom_explosion_sound", "OrbExplosion.ogg");
		this.getSprite().PlaySound("OrbFireSound.ogg");
		this.getSprite().SetZ(1000.0f);
		
		//makes a stupid annoying sound
		//ParticleZombieLightning( this.getPosition() );
		
		// done post init
		this.getCurrentScript().tickFrequency = 3;
	}
	
	
	Vec2f target;
	bool targetSet;
	bool brake;
	
	CPlayer@ p = this.getDamageOwnerPlayer();
	if( p !is null)	{
		CBlob@ b = p.getBlob();
		if( b !is null)	{
			target = b.getAimPos();
			targetSet = true;
			brake = b.isKeyPressed( key_action3 );
		}
	}
	
	if(targetSet){
		Vec2f vel = this.getVelocity();
		Vec2f dir = target-this.getPosition();
		if(!brake){
			float perc = 1.0f - Maths::Min((Maths::Max(dir.Length(), 24.0f)-24.0f)/48.0f, 1.0f);
			dir.Normalize();
			vel += dir * 1.4f * perc;
			if(vel.Length() > ORB_SPEED){
				vel.Normalize();
				vel *= ORB_SPEED;
			}
		} else {
			float perc = Maths::Min((Maths::Max(dir.Length(), 24.0f)-24.0f)/48.0f, 1.0f);
			if(vel.Length() > ORB_SPEED * perc){
				vel.Normalize();
				vel *= ORB_SPEED * perc;
			}
		}
		
		this.setVelocity(vel);
	}
}	

bool doesCollideWithBlob( CBlob@ this, CBlob@ b )
{
	return (
		isEnemy(this, b) 
		|| b.hasTag("door") 
		|| b.hasTag("door") 
		|| b.getShape().getConsts().platform
		|| (b.getPlayer() !is null 
			&& b.getPlayer() is this.getDamageOwnerPlayer() //the wizard
		|| b.getName() == this.getName() &&	b.getTeamNum() == this.getTeamNum() //other own orbs
		)
	); 
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (solid){
		if(blob !is null && blob.getTeamNum() != this.getTeamNum() && !blob.getShape().getConsts().platform){
			this.server_Die();
		} else {
			Vec2f vel = this.getVelocity();
			//this.setVelocity(vel/1.5f);
			//this.setVelocity( normal.RotateBy((getGameTime() % 60 > 30) ? 90 : -90));
		}
	}
}
