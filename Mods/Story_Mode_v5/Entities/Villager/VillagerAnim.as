void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	if (blob.getShape().isStatic()) //check frozen
	{
		this.SetAnimation("default");
		return;
	}

	if(!blob.hasTag("set_sprite")){
		if(blob.get_u8("type") == 0){
			this.ReloadSprite("../Mods/Story_Mode/Entities/Villager/VillagerMale.png");
		}
		if(blob.get_u8("type") == 1){
			this.ReloadSprite("../Mods/Story_Mode/Entities/Villager/VillagerFemale.png");
		}
		if(blob.get_u8("type") == 2){
			this.ReloadSprite("../Mods/Story_Mode/Entities/Villager/VillagerMaleOld.png");
		}
		if(blob.get_u8("type") == 3){
			this.ReloadSprite("../Mods/Story_Mode/Entities/Villager/VillagerFemaleOld.png");
		}
		if(blob.get_u8("type") == 4){
			this.ReloadSprite("../Mods/Story_Mode/Entities/Villager/VillagerKid.png");
		}
	
		blob.Tag("set_sprite");
	}
	
	
	if (blob.hasTag("dead")) //check dead
	{
		Vec2f vel = blob.getVelocity();
		this.SetAnimation("dead");

		if (vel.y < -1.0f)
		{
			this.SetFrameIndex(0);
		}
		else
		{
			this.SetFrameIndex(1);
		}
		return;
	}

	// get facing
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);

	if (inair)
	{
		this.SetAnimation("fall");
		Vec2f vel = blob.getVelocity();
		f32 vy = vel.y;
		this.animation.timer = 0;

		if (vy < -1.5 || up)
		{
			this.animation.frame = 0;
		}
		else
		{
			this.animation.frame = 1;
		}
	}
	else if (left || right ||
	         (blob.isOnLadder() && (up || down)))
	{
		this.SetAnimation("run");
		if(left)blob.SetFacingLeft(true);
		if(right)blob.SetFacingLeft(false);
	}
	else
	{
		this.SetAnimation("default");
	}

	//set the attack/dead heads when needed
	if (blob.isKeyPressed(key_action2) || blob.isInFlames())
	{
		blob.Tag("attack head");
	}
	else //default head
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
	CParticle@ Body     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm1     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm2     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}
