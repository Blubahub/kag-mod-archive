// Jjuggernaut animations

#include "JuggernautCommon.as";
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

const string shiny_layer = "shiny bit";

void onInit(CSprite@ this)
{
	// add blade
	this.RemoveSpriteLayer("chop");
	CSpriteLayer@ chop=this.addSpriteLayer("chop","Slash.png",64,64);
	if (chop !is null) {
		Animation@ anim=chop.addAnimation("default",0,true);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		chop.SetVisible(false);
		chop.SetRelativeZ(1000.0f);
		chop.SetColor(SColor(1.0f,1.0f,1.0f,0.1f));
	}

	// add shiny
	this.RemoveSpriteLayer(shiny_layer);
	CSpriteLayer@ shiny = this.addSpriteLayer(shiny_layer, "AnimeShiny.png", 16, 16);

	if(shiny !is null) {
		Animation@ anim = shiny.addAnimation("default", 2, true);
		int[] frames = {0, 1, 2, 3};
		anim.AddFrames(frames);
		shiny.SetVisible(false);
		shiny.SetRelativeZ(1.0f);
	}
	
	this.RemoveSpriteLayer("background");
	CSpriteLayer@ background=	this.addSpriteLayer("background","JuggernautBackground.png",64,64,2,2);
	if(background !is null) {
		Animation@ anim0=background.addAnimation("default",0,false);
		int[] frames0 = {0};
		anim0.AddFrames(frames0);
		
		Animation@ anim1=background.addAnimation("grabbedIdle",0,false);
		int[] frames1 = {32};
		anim1.AddFrames(frames1);
		
		Animation@ anim2=background.addAnimation("grabbedRun",4,true);
		int[] frames2 = {33,34,35,36};
		anim2.AddFrames(frames2);
		
		Animation@ anim3=background.addAnimation("grabbedFall",5,false);
		int[] frames3 = {37,38,39};
		anim3.AddFrames(frames3);
		
		background.SetVisible(true);
		background.SetRelativeZ(-10.0f);
	}
	this.RemoveSpriteLayer("victim");
	CSpriteLayer@ victim=	this.addSpriteLayer("victim","KnightVictim.png",64,64,2,2);
	if(victim !is null) {
		Animation@ anim=victim.addAnimation("default",0,false);
		int[] frames = {0};
		anim.AddFrames(frames);
		victim.SetVisible(false);
		victim.SetRelativeZ(-1.0f);
	}
	//fatality - Juggernaut
	this.RemoveSpriteLayer("fatality");
	CSpriteLayer@ fatality=this.addSpriteLayer("fatality","JuggernautFatality.png",48,48);
	if(fatality !is null) {
		Animation@ anim=fatality.addAnimation("default",4,false);
		int[] frames ={
			0,1,0,1,0,1,0,2,3,4,5,6,7,8,8,9,10,11,12,12,12,12,12,12,12,12,12,12
		};
		anim.AddFrames(frames);
		fatality.SetVisible(false);
		fatality.SetRelativeZ(0.0f);
	}
}

void onTick(CSprite@ this)
{
	//print(this.getSpriteLayer(0).name);
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f aimpos;

	JuggernautInfo@ juggernaut;
	if (!blob.get("JuggernautInfo", @juggernaut))
	{
		return;
	}

	const u8 knocked = getKnocked(blob);

	bool pressed_a1 = blob.isKeyPressed(key_action1);
	bool pressed_a2 = blob.isKeyPressed(key_action2);

	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));

	aimpos = blob.getAimPos();
	bool inair = (!blob.isOnGround() && !blob.isOnLadder());

	Vec2f vel = blob.getVelocity();

	if (blob.hasTag("dead"))
	{
		if (this.animation.name != "dead")
		{
			this.RemoveSpriteLayer(shiny_layer);
			this.SetAnimation("dead");
		}
		Vec2f oldvel = blob.getOldVelocity();

		//TODO: trigger frame one the first time we server_Die()()
		if (vel.y < -1.0f)
		{
			this.SetFrameIndex(1);
		}
		else if (vel.y > 1.0f)
		{
			this.SetFrameIndex(3);
		}
		else
		{
			this.SetFrameIndex(2);
		}

		CSpriteLayer@ chop = this.getSpriteLayer("chop");

		if (chop !is null)
		{
			chop.SetVisible(false);
		}

		return;
	}

	// get the angle of aiming with mouse
	Vec2f vec;
	int direction = blob.getAimDirection(vec);

	// set facing
	bool facingLeft = this.isFacingLeft();
	// animations
	bool ended = this.isAnimationEnded() || this.isAnimation("shield_raised");
	bool wantsChopLayer = false;
	s32 chopframe = 0;
	f32 chopAngle = 0.0f;

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);

	bool shinydot = false;
	
	bool grabbed=juggernaut.state==JuggernautStates::grabbed;
	
	if(juggernaut.state!=JuggernautStates::fatality){
		CSpriteLayer@ fatality=this.getSpriteLayer("fatality");
		if(fatality !is null){
			fatality.SetVisible(false);
			this.SetVisible(true);
		}
	}
	
	if(juggernaut.state==JuggernautStates::fatality){
		CSpriteLayer@ fatality=this.getSpriteLayer("fatality");
		if(fatality !is null){
			this.SetVisible(false);
			fatality.SetAnimation("default");
			if(fatality.animation.frame>=fatality.animation.getFramesCount()-1){
				fatality.animation.frame=0;
			}
			fatality.SetFacingLeft(this.getBlob().get_bool("wasFacingLeft"));
			fatality.SetOffset(Vec2f(-8.0f,-7.0f));
			fatality.SetVisible(true);
		}else{
			print("null");
		}
	}else if(juggernaut.state==JuggernautStates::stun)
	{
		this.SetAnimation("crouch");
	}
	else if (blob.hasTag("seated"))
	{
		this.SetAnimation("crouch");
	}
	else if (juggernaut.state == JuggernautStates::charging)
	{
		this.SetAnimation("charging");
		/*if(juggernaut.chargeTimer<(JuggernautVars::chargeTime/3)) {
			this.animation.frame=0;
		}else if(juggernaut.chargeTimer<(JuggernautVars::chargeTime/3)*2) {
			this.animation.frame=1;
		}else{
			this.animation.frame=2;
		}*/
	}else if (juggernaut.state == JuggernautStates::chargedAttack) {
		this.SetAnimation("chargedAttack");
		/*if(this.animation.frame<3){
			wantsChopLayer=	true;
			chopAngle=		-vec.Angle();
			chopframe=	this.animation.frame;
		}*/
	}else if (juggernaut.state == JuggernautStates::kickAttack) {
		this.SetAnimation("kickAttack");
	}else if (juggernaut.state == JuggernautStates::grabbing) {
		this.SetAnimation("grabbing");
	}else if (juggernaut.state == JuggernautStates::throwing) {
		this.SetAnimation("throwing");
	}
	else if (inair)
	{
		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}
		f32 vy = vel.y;
		if (vy < -0.0f && moveVars.walljumped)
		{
			this.SetAnimation(grabbed ? "grabbedRun" : "run");
		}
		else
		{
			this.SetAnimation(grabbed ? "grabbedFall" : "fall");
			this.animation.timer = 0;

			if (vy < -1.5)
			{
				this.animation.frame = 0;
			}
			else if (vy > 1.5)
			{
				this.animation.frame = 2;
			}
			else
			{
				this.animation.frame = 1;
			}
		}
	}
	else if (walking ||
	         (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down))))
	{
		this.SetAnimation(grabbed ? "grabbedRun" : "run");
	}
	else if(grabbed){
		this.SetAnimation("grabbedIdle");
	}
	else
	{
		defaultIdleAnim(this,blob,direction);
	}

	CSpriteLayer@ chop = this.getSpriteLayer("chop");

	if (chop !is null)
	{
		chop.SetVisible(wantsChopLayer);
		if (wantsChopLayer)
		{
			f32 choplength = 5.0f;

			chop.animation.frame = chopframe;
			Vec2f offset = Vec2f(choplength, 0.0f);
			offset.RotateBy(chopAngle, Vec2f_zero);
			if (!this.isFacingLeft())
				offset.x *= -1.0f;
			offset.y += this.getOffset().y * 0.5f;

			chop.SetOffset(offset);
			chop.ResetTransform();
			if (this.isFacingLeft())
				chop.RotateBy(180.0f + chopAngle, Vec2f());
			else
				chop.RotateBy(chopAngle, Vec2f());
		}
	}

	//set the shiny dot on the sword

	CSpriteLayer@ shiny = this.getSpriteLayer(shiny_layer);

	/*if (shiny !is null)
	{
		shiny.SetVisible(shinydot);
		if (shinydot)
		{
			f32 range = (JuggernautVars::slash_charge_limit - JuggernautVars::slash_charge_level2);
			f32 count = (juggernaut.attackTimer - JuggernautVars::slash_charge_level2);
			f32 ratio = count / range;
			shiny.RotateBy(10, Vec2f());
			shiny.SetOffset(Vec2f(12, -2 + ratio * 8));
		}
	}*/

	//set the head anim
	if (knocked > 0)
	{
		blob.Tag("dead head");
	}
	else if (blob.isKeyPressed(key_action1))
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}

	
	int nextFrame=this.animation.frame+1;
	if(nextFrame>=this.animation.getFramesCount()){
		nextFrame=0;
	}
	
	CSpriteLayer@ background=this.getSpriteLayer("background");
	if(background !is null){
		if(grabbed && !blob.hasTag("dead")){
			background.SetAnimation(this.animation.name);
			background.animation.frame=	nextFrame;
		}else{
			background.SetAnimation("default");
		}
	}
	CSpriteLayer@ victim=this.getSpriteLayer("victim");
	if(victim !is null){
		Vec2f vec=Vec2f(0.0f,0.0f);
		if(nextFrame==1 || nextFrame==3){
			vec.y=-1.0f;
		}else if(nextFrame==5 || nextFrame==6 || nextFrame==7){
			vec.y=-2.0f;
		}
		victim.SetOffset(vec);
		victim.SetVisible(grabbed);
	}
}

void onGib(CSprite@ this)
{
	/*CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0f;
	const u8 team = blob.getTeamNum();

	CParticle@ Body     = makeGibParticle("Entities/Characters/Jjuggernaut/JjuggernautGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm      = makeGibParticle("Entities/Characters/Jjuggernaut/JjuggernautGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Entities/Characters/Jjuggernaut/JjuggernautGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Entities/Characters/Jjuggernaut/JjuggernautGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);*/
}


// render cursors

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}

	// draw tile cursor

	if (blob.isKeyPressed(key_action1))
	{
		CMap@ map = blob.getMap();
		Vec2f position = blob.getPosition();
		Vec2f cursor_position = blob.getAimPos();
		Vec2f surface_position;
		map.rayCastSolid(position, cursor_position, surface_position);
		Vec2f vector = surface_position - position;
		f32 distance = vector.getLength();
		Tile tile = map.getTile(surface_position);

		if ((map.isTileSolid(tile) || map.isTileGrass(tile.type)) && map.getSectorAtPosition(surface_position, "no build") is null && distance < 16.0f)
		{
			DrawCursorAt(surface_position, cursorTexture);
		}
	}
}
