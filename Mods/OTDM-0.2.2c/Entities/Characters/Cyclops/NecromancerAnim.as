// Builder animations

void onInit(CSprite@ this)
{
	CSpriteLayer@ gun = this.addSpriteLayer("gun", "Turret.png", 16, 16);

	if (gun !is null)
	{
		Animation@ anim = gun.addAnimation("default", 0, false);
		anim.AddFrame(1);
		gun.SetOffset(Vec2f(0, -8));
	}

}
void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();    
    
	// get facing
   	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	CSpriteLayer@ gun = this.getSpriteLayer("gun");
	/*if (gun !is null)
	{

		bool facing_left = this.isFacingLeft();
		//f32 rotation = angle * (facing_left ? -1 : 1);
		/*gun.ResetTransform();
		gun.SetFacingLeft(facing_left);
		gun.SetRelativeZ(1.0f);
	//	gun.SetOffset(arm_offset); (facing_left ? -1 : 1)
		Vec2f blobPos = blob.getPosition();
		Vec2f aimPos = blob.getAimPos();
		Vec2f aimDir =  aimPos - blobPos;
		f32 aimdirx= aimDir.x;
		f32 aimdiry= aimDir.y;
	//	printf("aimDir: "+aimdirx, aimdiry);
		//arm.RotateBy(rotation, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
		f32 aimangle = aimDir.Angle();
   		//gun.setAngleDegrees(aimangle);
		gun.RotateBy(0, Vec2f(10, -10));
		gun.RotateBy(aimangle, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
		print(""+aimangle);
	}*/

	if (inair)
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
//    CParticle@ Body     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 0, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
 //   CParticle@ Arm1     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
//    CParticle@ Arm2     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
//    CParticle@ Shield   = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 2, 0, Vec2f (16,16), 2.0f, 0, "Sounds/material_drop.ogg", team );
 //   CParticle@ Sword    = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ), 3, 0, Vec2f (16,16), 2.0f, 0, "Sounds/material_drop.ogg", team );
}
