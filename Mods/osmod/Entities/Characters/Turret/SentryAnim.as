// Builder animations

void onInit(CSprite@ this)
{
	CSpriteLayer@ gun = this.addSpriteLayer("gun", "Sentry.png", 16, 16);

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
	if (gun !is null)
	{

		bool facing_left = this.isFacingLeft();
		//f32 rotation = angle * (facing_left ? -1 : 1);
		gun.ResetTransform();
		//gun.SetFacingLeft(facing_left);
		gun.SetRelativeZ(1.0f);
	//	gun.SetOffset(arm_offset); (facing_left ? -1 : 1)
		Vec2f blobPos = blob.getPosition();
		Vec2f aimPos = blob.get_Vec2f("target position");
		Vec2f aimDir =  aimPos - blobPos;
		f32 aimdirx= aimDir.x;
		f32 aimdiry= aimDir.y;
	//	printf("aimDir: "+aimdirx, aimdiry);
		f32 aimangle = aimDir.Angle();
		aimangle*= (facing_left ? 1 : -1);
		gun.ResetTransform();
		//gun.RotateBy(0, Vec2f(10, -10));
		gun.RotateBy(aimangle, Vec2f(0, 0));
		//print(""+aimangle);
	}
}
