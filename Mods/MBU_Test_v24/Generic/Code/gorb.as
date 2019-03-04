
///When our idol becomes alive, what will we do then?

float gold_orb_max_size = 96.0f;

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	CShape@ shape = this.getShape();
	
	this.set_u16("gold_amount",10);
	this.set_u16("light_energy",1);
	
	float gold_scale = 0.01f;
	
	Vec2f[] circle;
	Vec2f line = Vec2f(gold_scale*gold_orb_max_size,0);
	for(int i = 0;i < 8;i++){
		line.RotateBy(360.0f/8.0f);
		circle.push_back(line);
	}
	
	shape.AddShape(circle);
	
	this.Tag("player_collide");
	
	shape.SetGravityScale(0.1f);
	shape.getConsts().mapCollisions = true;
}

void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();
	
	float gold_scale = f32(this.get_u16("gold_amount"))/1000.0f;
	
	if(getGameTime() % 60 == 0){
	
		shape.RemoveShape(0);
		shape.RemoveShape(1);
		shape.RemoveShape(2);
		
		Vec2f[] circle;
		Vec2f line = Vec2f(gold_scale*(gold_orb_max_size/2.0f),0);
		for(int i = 0;i < 8;i++){
			line.RotateBy(360.0f/8.0f);
			circle.push_back(line);
		}
		
		shape.AddShape(circle);
	
		if(isServer()){
			this.Sync("gold_amount",true);
			this.Sync("light_energy",true);
		}
	}
	
	f32 SpriteScale = 1.0f;
	if(this.exists("sprite_scale")){
		SpriteScale = this.get_f32("sprite_scale");
	}
	
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.ScaleBy(Vec2f(gold_scale/SpriteScale, gold_scale/SpriteScale));
	}
	SpriteScale = gold_scale;
	
	this.set_f32("sprite_scale",SpriteScale);
	
	
	f32 GlowScale = 1.0f;
	if(this.exists("glow_scale")){
		GlowScale = this.get_f32("glow_scale");
	}
	f32 GlowDesireScale = this.get_u16("light_energy")/900.0f;
	
	CSpriteLayer@ glow = this.getSprite().getSpriteLayer("glow");
	if (glow !is null)
	{
		glow.ScaleBy(Vec2f(GlowDesireScale/GlowScale, GlowDesireScale/GlowScale));
	}
	GlowScale = GlowDesireScale;
	
	this.set_f32("glow_scale",GlowScale);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onInit(CSprite @this){
	this.RemoveSpriteLayer("glow");
	CSpriteLayer@ glow = this.addSpriteLayer("glow", "gbbl.png", 96, 96);
	if(glow !is null)
	{
		Animation@ anim = glow.addAnimation("default", 0, false);
		anim.AddFrame(0);
		glow.SetRelativeZ(-1.0f);
		glow.setRenderStyle(RenderStyle::additive);
	}
}

#include "copy.as"

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null)
	if(blob.getName() == "humanoid")
	if(blob.hasTag("light_ability"))
	if(this.get_u16("light_energy") >= 1000)
	if(this.get_u16("gold_amount") >= 1000){
		if(getNet().isServer()){
			CBlob @gb = server_CreateBlob("goldenbeing",blob.getTeamNum(),this.getPosition());
			
			copy(blob,gb,true, false, true ,true, false, false, false, false );
			
			blob.server_Die();
			this.server_Die();
		}
	}
	print("huh"+this.get_u16("light_energy"));
}