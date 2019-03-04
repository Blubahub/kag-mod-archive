
#include "Hitters.as";
#include "FireParticle.as";

void onInit(CBlob@ this)
{
	this.Tag("left");
	this.Tag("right");
	this.Tag("top_left");
	this.Tag("top_right");
}

void onTick(CBlob @ this){

	CBlob @blob = getLocalPlayerBlob();
	CSprite @sprite = this.getSprite();

	if(blob !is null && sprite !is null){
		if(this.isOverlapping(blob) && !this.hasTag("glass_vision")){
			if(sprite.getSpriteLayer("middle_leaf") !is null)sprite.getSpriteLayer("middle_leaf").SetFrame(17);
			if(sprite.getSpriteLayer("left_leaf") !is null)sprite.getSpriteLayer("left_leaf").SetFrame(5);
			if(sprite.getSpriteLayer("right_leaf") !is null)sprite.getSpriteLayer("right_leaf").SetFrame(14);
			if(sprite.getSpriteLayer("top_left_leaf") !is null)sprite.getSpriteLayer("top_left_leaf").SetFrame(8);
			if(sprite.getSpriteLayer("top_right_leaf") !is null)sprite.getSpriteLayer("top_right_leaf").SetFrame(11);
			this.Tag("glass_vision");
		}
		if(!this.isOverlapping(blob) && this.hasTag("glass_vision")){
			if(sprite.getSpriteLayer("middle_leaf") !is null)sprite.getSpriteLayer("middle_leaf").SetFrame(16);
			if(sprite.getSpriteLayer("left_leaf") !is null)sprite.getSpriteLayer("left_leaf").SetFrame(4);
			if(sprite.getSpriteLayer("right_leaf") !is null)sprite.getSpriteLayer("right_leaf").SetFrame(13);
			if(sprite.getSpriteLayer("top_left_leaf") !is null)sprite.getSpriteLayer("top_left_leaf").SetFrame(7);
			if(sprite.getSpriteLayer("top_right_leaf") !is null)sprite.getSpriteLayer("top_right_leaf").SetFrame(10);
			this.Untag("glass_vision");
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	
	if (customData == Hitters::burn || customData == Hitters::fire){
		if(!this.hasTag("added_burn_sprites")){

			for (uint i = 0; i < this.getSprite().getSpriteLayerCount(); i++)
			{
				CSpriteLayer@ layer = this.getSprite().getSpriteLayer(i);

				if (layer !is null)
				if(layer.name != "fire"){
					CSpriteLayer@ fire = this.getSprite().addSpriteLayer("fire", "Entities/Effects/Sprites/LargeFire.png", 16, 16, -1, -1);
					if (fire !is null)
					{
						fire.SetRelativeZ(100);
						{
							Animation@ anim = fire.addAnimation("bigfire", 4, true);
							anim.AddFrame(5);
							anim.AddFrame(6);
							anim.AddFrame(4);
						}
						fire.SetVisible(true);
						fire.SetOffset(Vec2f(XORRandom(35)-17,5-XORRandom(30)));
						fire.SetRelativeZ(2000.0f);
						fire.SetFacingLeft(layer.isFacingLeft());
						fire.SetLighting(false);
					}
				}
			}
			this.Tag("added_burn_sprites");
		}
	
		if(getNet().isServer())
		for (uint i = 0; i < this.getSprite().getSpriteLayerCount(); i++)
		{
			CSpriteLayer@ layer = this.getSprite().getSpriteLayer(i);

			if (layer !is null)
			if(layer.name != "fire"){

				for(int i = 0; i < XORRandom(5)+2; i+= 1){
					makeFireParticle (layer.getWorldTranslation() + Vec2f(XORRandom(25)-12,(-XORRandom(24)*(i/10.0f))+6));
				}
				
				if(XORRandom(50) == 0){
					CBlob@ smokey = server_CreateBlobNoInit("smoke");
					if(smokey !is null){
						smokey.setPosition(layer.getWorldTranslation() + Vec2f(0, -10));
						smokey.setVelocity(Vec2f((XORRandom(1000)-500.0f)/2000.0f,0));
						smokey.server_setTeamNum(-1);
						smokey.set_f32("toxicity", 0.40f); // Healthy wooden smoke
						smokey.Init();
					}
				}
			}
		}
		
		damage = this.getInitialHealth()/10.0f;
		
		this.getSprite().SetEmitSound("Inferno.ogg");
		this.getSprite().SetEmitSoundPaused(false);
		
		return damage;
	}
	
	Vec2f angle = hitterBlob.getPosition()-this.getPosition();
	
	if(angle.Angle() >= 360-45 || angle.Angle() < 45){
		if(this.hasTag("top_right"))removeLeaf(this, "top_right");
		else if(this.hasTag("right"))removeLeaf(this, "right");
	}
	if(angle.Angle() >= 45 && angle.Angle() < 90){
		if(this.hasTag("top_right"))removeLeaf(this, "top_right");
	}
	if(angle.Angle() >= 90 && angle.Angle() <= 135){
		if(this.hasTag("top_left"))removeLeaf(this, "top_left");
	}
	if(angle.Angle() > 135 && angle.Angle() < 225){
		if(this.hasTag("top_left"))removeLeaf(this, "top_left");
		else if(this.hasTag("left"))removeLeaf(this, "left");
	}
	
	return damage;
}


void onInit(CSprite@ this)
{
	this.SetZ(-50.0f);
	
	{
		CSpriteLayer @leaf = this.addSpriteLayer("back_left_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(3);
			leaf.SetRelativeZ(0.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
	{
		CSpriteLayer @leaf = this.addSpriteLayer("back_right_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(12);
			leaf.SetRelativeZ(0.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
	{
		CSpriteLayer @leaf = this.addSpriteLayer("back_top_left_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(6);
			leaf.SetRelativeZ(0.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
	{
		CSpriteLayer @leaf = this.addSpriteLayer("back_top_right_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(9);
			leaf.SetRelativeZ(0.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
	
	
	{
		CSpriteLayer @leaf = this.addSpriteLayer("middle_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(16);
			leaf.SetRelativeZ(200.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
	{
		CSpriteLayer @leaf = this.addSpriteLayer("left_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(4);
			leaf.SetRelativeZ(200.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
	{
		CSpriteLayer @leaf = this.addSpriteLayer("right_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(13);
			leaf.SetRelativeZ(200.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
	{
		CSpriteLayer @leaf = this.addSpriteLayer("top_left_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(7);
			leaf.SetRelativeZ(200.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
	{
		CSpriteLayer @leaf = this.addSpriteLayer("top_right_leaf", "BigBush.png", 46, 36);
		if(leaf !is null){
			leaf.SetFrame(10);
			leaf.SetRelativeZ(200.0f);
			leaf.SetOffset(this.getOffset());
		}
	}
}

void removeLeaf(CBlob @this, string name){
	CSprite @sprite = this.getSprite();
	
	if(sprite !is null){
		sprite.RemoveSpriteLayer(name+"_leaf");
		sprite.RemoveSpriteLayer("back_"+name+"_leaf");
	}
	
	this.Untag(name);
}