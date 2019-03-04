
#include "Hitters.as"
#include "eleven.as"

void onInit(CSprite@ this)
{
	this.SetZ(-200.0f);
	
	this.SetEmitSound("sll.ogg");
	this.SetEmitSoundPaused(false);
	this.SetEmitSoundSpeed(2.0f);
}

void onTick(CSprite@ this)
{
	CBlob @blob = this.getBlob();
	/*
	this.ResetTransform();
	this.ResetWorldTransform();
	if(blob !is null){
		
		f32 scale_by = 1.0f;
		
		if(blob.get_f32("scale") < blob.get_f32("final_scale"))scale_by = 1.05f;
		
		this.ScaleBy(Vec2f(scale_by,scale_by));
		blob.set_f32("scale",blob.get_f32("scale")*scale_by);
		
		this.SetEmitSoundVolume(blob.get_f32("scale"));
	}*/
	this.RotateBy(45, Vec2f(0,0));
	
	
}


void onInit(CBlob@ this)
{
	this.set_f32("scale",0.1f);
	this.set_f32("sprite_scale",1.0f);
	this.set_f32("final_scale",1.0f);
	this.set_f32("damage",5.0f);
	this.getShape().SetStatic(true);
}


void onTick(CBlob@ this)
{
	f32 scale = this.get_f32("scale");
	
	if(scale < this.get_f32("final_scale"))scale *= 1.05f;
	
	this.set_f32("scale",scale);
	
	f32 SpriteScale = 1.0f;
	if(this.exists("sprite_scale")){
		SpriteScale = this.get_f32("sprite_scale");
	}
	
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.ScaleBy(Vec2f(scale/SpriteScale, scale/SpriteScale));
	}
	SpriteScale = scale;
	
	this.set_f32("sprite_scale",SpriteScale);
	
	
	if(this.get_f32("final_scale") > 2.0f)this.set_f32("final_scale",2.0f);
	
	if(!checkEInterface(this,this.getPosition(),scale*100.0f,10))this.Tag("force_explosion");
	
	if(scale >= this.get_f32("final_scale") || this.hasTag("force_explosion")){
	
		if(getNet().isClient())this.getSprite().ScaleBy(Vec2f(0.9f,0.9f));
	
		if(!this.hasTag("exploded")){
			
			if(getNet().isServer()){
				CBlob@[] blobsInRadius;
				if (this.getMap().getBlobsInRadius(this.getPosition(), scale*100.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						
						if(b !is null && b !is this && !b.isInWater() && !b.hasTag("fire source")){
						
							float distance_ratio = this.getDistanceTo(b)/(scale*100.0f);
							
							if(getNet().isServer())this.server_Hit(b, b.getPosition(), Vec2f(0,0), distance_ratio*this.get_f32("damage"), Hitters::fire, true);
						}
					}
				}
				
				this.server_SetTimeToDie(10);
			}
			
			ShakeScreen(scale*30, scale*30, this.getPosition());
			
			this.getSprite().SetEmitSoundPaused(true);
			
			this.getSprite().PlaySound("bffg.ogg", scale);
			
			this.Tag("exploded");
		}
	
	}
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
}