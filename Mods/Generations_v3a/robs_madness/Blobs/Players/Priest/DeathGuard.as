
void onInit(CBlob@ this)
{
	
	this.set_u16("self_raise",0);
}

void onTick(CBlob@ this)
{

	if(this.getPlayer() !is null){
		this.set_string("username",this.getPlayer().getUsername());
	}

	if(this.hasTag("dead")){
		if(this.get_u16("self_raise") > 2*30){
				if(getPlayerByUsername(this.get_string("username")) !is null)
				if(getPlayerByUsername(this.get_string("username")).getBlob() is null){
					if(getNet().isServer()){
						CBlob @ blob = server_CreateBlob(this.getName(),this.getTeamNum(),this.getPosition());
						blob.server_SetPlayer(getPlayerByUsername(this.get_string("username")));
						blob.RemoveScript("DeathGuard.as");
						this.server_Die();
					}
					
					Vec2f vec = Vec2f(32,0);
					for(int r = 0; r < 360; r += 10){
						vec.RotateBy(r);
						Vec2f dir = this.getPosition()-(this.getPosition()+vec);
						dir.Normalize();
						ParticleAnimated("HolyParticle.png", this.getPosition()+vec, Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 1+XORRandom(3), 0.0f, true);
					}
				}
		} else this.set_u16("self_raise",this.get_u16("self_raise")+1);
	}
	
	
	if(!this.hasTag("Halo")){
	
		this.Tag("Halo");
	
		CSprite@ sprite = this.getSprite();
	
		if(sprite !is null){
			sprite.RemoveSpriteLayer("halo_front");
			CSpriteLayer@ halo_front = sprite.addSpriteLayer("halo_front", "Halo.png", 32, 32);

			if (halo_front !is null)
			{
				Animation@ anim = halo_front.addAnimation("default", 0, false);
				int[] frames = {0};
				anim.AddFrames(frames);
				halo_front.SetRelativeZ(1.0f);
				halo_front.SetOffset(Vec2f(0,0));
				halo_front.setRenderStyle(RenderStyle::additive);
			}
			
			sprite.RemoveSpriteLayer("halo_back");
			CSpriteLayer@ halo_back = sprite.addSpriteLayer("halo_back", "Halo.png", 32, 32);

			if (halo_back !is null)
			{
				Animation@ anim = halo_back.addAnimation("default", 0, false);
				int[] frames = {1};
				anim.AddFrames(frames);
				halo_back.SetRelativeZ(-1.0f);
				halo_back.SetOffset(Vec2f(0,0));
				halo_back.setRenderStyle(RenderStyle::additive);
			}
		}
	}

}

void onDie(CBlob@ this){
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		sprite.RemoveSpriteLayer("halo_front");
		sprite.RemoveSpriteLayer("halo_back");
	}
}