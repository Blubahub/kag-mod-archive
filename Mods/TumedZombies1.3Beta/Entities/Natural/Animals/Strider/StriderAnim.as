//Minion2 Anim
void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();    
	// get facing
   	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	if ( blob.hasTag("dead") )
		this.SetAnimation("dead");
	else if ( blob.isKeyPressed(key_action1) )
	{
		this.SetAnimation("attack");
		
		if ( this.isFrameIndex(3) )
			this.PlaySound( "/ArrowHitFlesh.ogg", 1.1f, 0.6f );
	}
	else if (inair)
	{
		this.SetAnimation("fall");
		Vec2f vel = blob.getVelocity();
		f32 vy = vel.y;
		this.animation.timer = 0;

		if (vy < -1.5 || up) {
			this.animation.frame = 0;
		}
		else {
			this.animation.frame = 1;
		}
	}
	else if (left || right ||
			 (blob.isOnLadder() && (up || down) ) )
	{
		this.SetAnimation("run");
	}
	else
	{
		this.SetAnimation("default");
	}
}

void onGib(CSprite@ this)
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Arm1     = makeGibParticle( "/Mutant1Gibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "/Mutant1Gibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 2, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "/Mutant1Gibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 4, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
}