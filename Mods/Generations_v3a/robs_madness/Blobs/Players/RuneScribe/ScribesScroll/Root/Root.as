#include "RunnerCommon.as";

void onTick(CBlob @this){
	
	if(!this.hasTag("Rooted")){
	
		this.Tag("Rooted");
		
		if(getNet().isServer())this.Sync("Rooted",true);
		
		//this.set_u32("root_timer",getGameTime()+90);
		
		for(int i=0;i<5;i++)makeGibParticle("GenericGibs.png", this.getPosition()+Vec2f(XORRandom(8)-4,2+XORRandom(4)), Vec2f(XORRandom(4)-2,-XORRandom(2)), 7, 1+XORRandom(4), Vec2f(8, 8), 2.0f, 20, "Gurgle2", this.getTeamNum());
	}
	
	CSprite@ sprite = this.getSprite();
	
	if(sprite !is null)
	if(sprite.getSpriteLayer("roots") is null || sprite.getSpriteLayer("roots_back") is null){
		sprite.RemoveSpriteLayer("roots");
		CSpriteLayer@ roots = sprite.addSpriteLayer("roots", "Root.png", 32, 32);

		if (roots !is null)
		{
			Animation@ anim = roots.addAnimation("default", 0, false);
			int[] frames = {0};
			anim.AddFrames(frames);
			roots.SetRelativeZ(1.0f);
			roots.SetOffset(Vec2f(0,-8));
		}
		
		sprite.RemoveSpriteLayer("roots_back");
		CSpriteLayer@ roots_back = sprite.addSpriteLayer("roots_back", "Root.png", 32, 32);

		if (roots_back !is null)
		{
			Animation@ anim = roots_back.addAnimation("default", 0, false);
			int[] frames = {1};
			anim.AddFrames(frames);
			roots_back.SetRelativeZ(-1.0f);
			roots_back.SetOffset(Vec2f(0,-8));
		}
	}
	
	if(this.get_u32("root_timer") < getGameTime() || this.hasTag("Cleanse")){
		this.Untag("Rooted");
		this.RemoveScript("Root.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("roots");
			sprite.RemoveSpriteLayer("roots_back");
		}
		for(int i=0;i<5;i++)makeGibParticle("GenericGibs.png", this.getPosition()+Vec2f(XORRandom(8)-4,2+XORRandom(4)), Vec2f(XORRandom(4)-2,-XORRandom(2)), 7, 1+XORRandom(4), Vec2f(8, 8), 2.0f, 20, "Gurgle2", this.getTeamNum());
	}
	
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	
	moveVars.jumpFactor *= 0.0f;
	moveVars.walkFactor *= 0.0f;

}