#include "Hitters.as";
#include "ModHitters.as";
#include "TreeCommon.as";
#include "FireParticle.as"

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData == Hitters::muscles)
	if(XORRandom(8) == 0)
	{
		if (getNet().isServer())
		{
			CBlob @ stick = server_CreateBlob("stick", this.getTeamNum(), this.getPosition()-Vec2f(0,XORRandom(48)));
			stick.setVelocity(Vec2f(XORRandom(8)-4,XORRandom(8)-4));
		}
	}
	
	if (customData != Hitters::saw && customData != Hitters::axe && customData != Hitters::burn && customData != Hitters::fire)
	{
		damage = 0.0f;
	}
	
	if (customData != Hitters::burn && customData != Hitters::fire)
	if (damage > 0.05f || customData == Hitters::muscles) //sound for all damage
	{
		this.getSprite().PlayRandomSound("TreeChop");
		makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                0, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}

	if (customData == Hitters::burn || customData == Hitters::fire)if(damage > 0.05f){
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
						fire.SetOffset(layer.getWorldTranslation()-this.getPosition());
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
		
		this.set_s16("burn duration",1000);
		
		damage = this.getInitialHealth()/100.0f;
		
		this.getSprite().SetEmitSound("Inferno.ogg");
		this.getSprite().SetEmitSoundPaused(false);
		
		this.set_bool("cut_down_fall_side",XORRandom(2) == 0);
	}
	
	
	
	
	return damage;
}
