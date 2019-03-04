
#include "Hitters.as";
#include "NPCChat.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetGravityScale(0.0f);
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetLighting(false);
	
	this.SetLight(false);
	this.SetLightColor(SColor(255, 255, 255, 255));
	this.SetLightRadius(96.0f);
	
	this.set_Vec2f("guard",this.getPosition());
	
	this.Tag("no hands");
	this.Tag("death_sight");
	this.Tag("death_ability");
	this.Tag("death_conservative");
	
	if(!this.exists("death_amount") || this.get_s16("death_amount") <= 0)this.set_s16("death_amount", 50);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this){
	
	this.getSprite().SetVisible((!(getLocalPlayer() is null || !getLocalPlayer().hasTag("death_sight"))) || this.hasTag("ghost_stone") || getLocalPlayer() is this.getPlayer());
	this.getSprite().SetZ(1000.0f);
	
	this.SetLight(this.getSprite().isVisible());
	
	this.Untag("ghost_stone");
	
	f32 VelX = this.getVelocity().x;
	f32 VelY = this.getVelocity().y;
	
	if(isServer())if(this.get_s16("death_amount") <= 0)this.server_Die();
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null && b.getName() == "humanoid"){
				Vec2f vec = b.getPosition()-this.getPosition();
				vec.Normalize();
				this.AddForce(vec*2.0f);
				
				b.Tag("death_seed");
				
				if(getGameTime() % 100 == 0){
					if(b.get_s16("death_amount") > 0){
						b.sub_s16("death_amount",1);
						if(this.get_s16("death_amount") > 25){
							if(getNet().isServer()){
								CBlob @e = server_CreateBlob("e",-1,b.getPosition());
								if(e !is null){
									e.setVelocity(Vec2f(XORRandom(31)-15,XORRandom(31)-15)/20);
									e.set_string("owner_name",this.get_string("owner_name"));
								}
							}
						} else {
							this.add_s16("death_amount",1);
						}
					}
				}
			}
		}
	}
	
	if(this.getPlayer() is null){
		Vec2f Guard = this.get_Vec2f("guard")-this.getPosition();
		
		if(Guard.Length() > 64.0f){
			Guard.Normalize();
			this.setVelocity(Guard);
		}

		if(XORRandom(50) == 0)this.setVelocity(this.getVelocity()+(Vec2f(XORRandom(9)-4,XORRandom(9)-4)/10));
		
		if(XORRandom(1000) == 0){
			switch(XORRandom(10)){
				case 0: speakToNearby(this,"[Ecto]Spirit: ","srrt?",SColor(0xff61775c)); break;
				case 1: speakToNearby(this,"[Ecto]Spirit: ","srrt",SColor(0xff61775c)); break;
				case 2: speakToNearby(this,"[Ecto]Spirit: ","srt",SColor(0xff61775c)); break;
				case 3: speakToNearby(this,"[Ecto]Spirit: ","srr",SColor(0xff61775c)); break;
				case 4: speakToNearby(this,"[Ecto]Spirit: ","rrt",SColor(0xff61775c)); break;
				case 5: speakToNearby(this,"[Ecto]Spirit: ","srtrr",SColor(0xff61775c)); break;
				case 6: speakToNearby(this,"[Ecto]Spirit: ","srrt!",SColor(0xff61775c)); break;
				case 7: speakToNearby(this,"[Ecto]Spirit: ","srr!",SColor(0xff61775c)); break;
				case 8: speakToNearby(this,"[Ecto]Spirit: ","rrt?",SColor(0xff61775c)); break;
				case 9: speakToNearby(this,"[Ecto]Spirit: ","srrtr",SColor(0xff61775c)); break;
			}
		}
	}
	
	if(this.getPlayer() !is null){
	
		if(this.isKeyPressed(key_left)){
			this.AddForce(Vec2f(-1.0f,0.0f));
		}
		
		if(this.isKeyPressed(key_right)){
			this.AddForce(Vec2f(+1.0f,0.0f));
		}
		
		if(this.isKeyPressed(key_up)){
			this.AddForce(Vec2f(0.0f,-1.0f));
		}
		
		if(this.isKeyPressed(key_down)){
			this.AddForce(Vec2f(0.0f,+1.0f));
		}
		if(this.getAimPos().x > this.getPosition().x)this.getSprite().SetFrameIndex(0);
		else this.getSprite().SetFrameIndex(1);
	
	} else 
	if(Maths::Abs(VelX) > 0.0f){
		if(VelX > 0)this.getSprite().SetFrameIndex(0);
		else this.getSprite().SetFrameIndex(1);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}
