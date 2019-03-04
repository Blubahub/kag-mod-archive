#include "Hitters.as";
#include "FireParticle.as"
#include "eleven.as"

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getVars().waterDragScale = 1.0f;
	
	this.SetLight(true);
	this.SetLightRadius(200.0f);
	this.SetLightColor(SColor(255, 255, 220, 151));
	
	this.getShape().SetGravityScale(0.01f);
	
	this.getShape().getConsts().mapCollisions = false;
	
	this.set_u16("radius",200);
	
	this.setVelocity(Vec2f(0,5.0f));
	
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("sui.png", 0, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);
	
	if(getNet().isClient()){
		SetScreenFlash(255, 255, 128, 0);
		client_AddToChat("A massive firey star fills the sky and begins to drop.", SColor(255, 128, 64, 0));
	}
}

void onTick(CBlob@ this)
{
	int radius = this.get_u16("radius");
	
	this.SetLightRadius(radius*3);
	
	checkEInterface(this,this.getPosition(),radius,100);
	
	if(getGameTime() % 10 == 0)
	if(getNet().isServer()){
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius*1.3f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				
				if(b !is null && b !is this && !b.isInWater() && !b.hasTag("fire source")){

					this.server_Hit(b, b.getPosition(), Vec2f(0,0), f32(radius)/20.0f, Hitters::fire, true);
				}
			}
		}
	}
	
	ShakeScreen(120, 800, this.getPosition());
	
	if(getNet().isServer())
	for(int i = 0; i < radius/100; i++){
		Vec2f pos = this.getPosition()+Vec2f(XORRandom(radius*2)-radius,f32(XORRandom(radius*2)-radius)*0.75f);
		getMap().server_setFireWorldspace(pos, true);
		getMap().server_DestroyTile(pos, 100.0f);
	}
	
	if(getNet().isClient()){
		
		CBlob @player = getLocalPlayerBlob();
		if(player !is null){
			f32 ratio = 1-(f32(Maths::Min(this.getDistanceTo(player),radius*4))/f32(radius*4));
			SetScreenFlash(255.0f*ratio, 255, 128+(64.0f*ratio), 0);
		}
		
		Vec2f pos = this.getPosition()+Vec2f(XORRandom(radius*2)-radius,f32(XORRandom(radius*2)-radius)*0.75f);
		
		if(getMap().isInWater(pos)){
			ParticleAnimated(CFileMatcher("SmallSteam").getFirst(), pos, Vec2f(0,0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
		}
	
	}
	
	radius = f32(radius)*0.75f;
	
	for(int i = 0; i < radius/10+1; i++)
	makeFireParticleStill(this.getPosition()+Vec2f(XORRandom(radius*2)-radius,XORRandom(radius*2)-radius));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onTick(CSprite@ this)
{
	CBlob @blob = this.getBlob();
	if(blob !is null && !blob.hasTag("scaled")){

		this.ScaleBy(Vec2f(f32(blob.get_u16("radius"))/100.0f,f32(blob.get_u16("radius"))/100.0f));

		blob.Tag("scaled");
	}
}

void onDie(CBlob @this){
	SetScreenFlash(255, 255, 128, 0);
}