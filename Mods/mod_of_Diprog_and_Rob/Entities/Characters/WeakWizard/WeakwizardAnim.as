// wizard animations
#include "EmotesCommon.as";



void onTick( CSprite@ this)
{
    CBlob@ blob = this.getBlob();    
    
	// get facing
   	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	
	Vec2f vec;
	int direction = blob.getAimDirection(vec);

	if (inair)
	{
		Vec2f vel = blob.getVelocity();
		f32 vy = vel.y;
		
		if ( up ){
			this.SetAnimation("jump");
		}
		else if (vy < -1.5 || up) {
			this.SetAnimation("fall");
			this.animation.timer = 0;
			this.animation.frame = 18;
		}
		
	}
	else if (left || right ||
			 (blob.isOnLadder() && (up || down) ) )
	{
		this.SetAnimation("run");
	}
	else if (down){
		this.SetAnimation("crouch");
	}
	else if(is_emote(blob, 255, true))
	{
		
		this.SetAnimation("point");
		
		if (direction == 1) {
                this.animation.frame = 2;
        }
        else if (direction == -1){
                    this.animation.frame = 0;
        }
        else {
                this.animation.frame = 1;
        }
	}
	else
	{
		this.SetAnimation( blob.isKeyPressed(key_action1) ? "fire" : "default");
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
    CParticle@ Body     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 0, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    // CParticle@ Shield   = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 2, 0, Vec2f (16,16), 2.0f, 0, "Sounds/material_drop.ogg", team );
    // CParticle@ Sword    = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ), 3, 0, Vec2f (16,16), 2.0f, 0, "Sounds/material_drop.ogg", team );
}
