#include "Hitters.as";
#include "BF_Costs.as"
//#include "Knocked.as";

const f32 PUSH_FORCE = 1.5f;//base value

void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = true;
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	this.Tag("projectile");
}


void onTick( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	Vec2f vel = this.getVelocity();
	vel.y *= -1;

	sprite.ResetTransform();
	sprite.RotateBy( vel.Angle(), Vec2f_zero );
}

void onTick( CShape@ this )
{
	this.SetGravityScale(0);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if ( solid || ( blob !is null && blob.hasTag( "mutant" ) && blob.hasTag( "building" ) ) )
	{
		if ( blob !is null )
			if ( blob.hasTag( "turret" ) || blob.getName() == "bf_bunny" )
				return;
			else if ( doesDamageBlob( this, blob ) )
				this.server_Hit( blob, point1, this.getOldVelocity(), DAMAGE_BALLISTA_ARROW, Hitters::arrow);
		
		this.server_Die();
	}
}

bool doesDamageBlob( CBlob@ this, CBlob@ blob )
{
	return this.getTeamNum() != blob.getTeamNum() && !blob.hasTag("dead");
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (this !is hitBlob && customData == Hitters::arrow)
	{
		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();

		f32 force = PUSH_FORCE * Maths::Sqrt( hitBlob.getMass() + 1 );
		
		hitBlob.AddForce( velocity * force );
	}
}

void onDie( CBlob@ this )
{
	this.getSprite().PlaySound( "destroy_wood", 0.4f );
}
