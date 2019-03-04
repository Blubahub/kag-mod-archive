#include "MakeMat.as";
#include "BombCommon.as";
#include "ChangeClass.as";

void onInit(CBlob @ this)
{
	this.Tag("medium weight");

	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
	
	this.set_s16("size", 10);
	this.set_u8("moldable", 0);
	this.Tag("element");
	
	if(this.getName() == "fire_blob" || this.getName() == "life_blob"){
		this.getShape().SetGravityScale(-0.01f);
	}
	if(this.getName() == "evil_blob" || this.getName() == "death_blob"){
		this.getShape().SetGravityScale(0.2f);
	}
	if(this.getName() == "gold_blob"){
		this.getShape().SetGravityScale(0.0f);
	}
	
	if(this.getName() == "water_blob")
	this.getSprite().setRenderStyle(RenderStyle::additive);
}

void onTick(CBlob@ this)
{
	if(this.getName() == "fire_blob")if(this.get_u8("moldable") <= 0){
		this.set_s16("size",this.get_s16("size")-1);
	}
	
	if(this.get_u8("moldable") > 0){
		this.set_u8("moldable", this.get_u8("moldable")-1);
	}
	if(this.get_s16("size") <= 0){
		this.server_Die();
	}
	
	if(this.getShape() !is null){
		this.getShape().SetMass(this.get_s16("size"));
	}
	
	if(this.get_u8("moldable") > 0)
	if(this.get_s16("size") > 125){
		int Radius = 8;
		if(this.get_s16("size") > 250)Radius = 16;
		if(this.get_s16("size") > 500)Radius = 24;
		if(this.get_s16("size") > 1000)Radius = 32;
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ blob = blobsInRadius[i];
				if(blob.hasTag("element")){
					if(this.getName() == blob.getName()){
						if(this.get_s16("size") >= blob.get_s16("size")){
							if(blob !is this){
								this.set_s16("size", this.get_s16("size")+blob.get_s16("size"));
								blob.set_s16("size", 0);
								
								Vec2f force = this.getVelocity()/2;
								force += blob.getVelocity()/2;
								
								this.setVelocity(force);
								
								return;
							}
						}
					} else {
						Combine(this,blob);
					}
				}
				if(blob.getName() == "fireball"){
					this.set_s16("size", this.get_s16("size")+10);
					blob.server_Die();
				}
				if(blob.hasTag("player") && (this.getName() == "life_blob")){
					this.server_Hit(blob, blob.getPosition(), Vec2f(0,0.001), 0.25f, Hitters::suddengib, false);
				}
				if(blob.hasTag("player") && (this.getName() == "gold_blob") && blob.hasTag("flesh")){
					if(this.get_s16("size") >= 1000){
						ChangeClass(blob, "goldenbeing", this.getPosition(), blob.getTeamNum());
						this.server_Die();
					} else this.server_Hit(blob, blob.getPosition(), Vec2f(0,0.001), 0.25f, Hitters::suddengib, false);
				}
			}
		}
	}
	
	if(this.getName() == "water_blob"){
		int Size = 1;
		if(this.get_s16("size") > 125)Size = 2;
		if(this.get_s16("size") > 250)Size = 4;
		if(this.get_s16("size") > 500)Size = 6;
		if(this.get_s16("size") > 1000)Size = 8;
		for (int doFirey = -Size*4; doFirey <= Size*4; doFirey += 8)
		{
			for (int doFirex = -Size*4; doFirex <= Size*4; doFirex += 8)
			{
				Vec2f pos = Vec2f(this.getPosition().x + doFirex, this.getPosition().y + doFirey);
				if(Maths::Sqrt((Maths::Pow(pos.x-this.getPosition().x,2))+(Maths::Pow(pos.y-this.getPosition().y,2))) <= Size*4){
					if(getMap().isInWater(pos)){
						getMap().server_setFloodWaterWorldspace(pos, false);
						this.set_s16("size",this.get_s16("size")+1);
					}
				}
			}
		}
	}
	
	if(this.getName() == "fire_blob"){
		int Size = 1;
		if(this.get_s16("size") > 125)Size = 2;
		if(this.get_s16("size") > 250)Size = 4;
		if(this.get_s16("size") > 500)Size = 6;
		if(this.get_s16("size") > 1000)Size = 8;
		
		for (int doFirey = -Size*4; doFirey <= Size*4; doFirey += 8)
		{
			for (int doFirex = -Size*4; doFirex <= Size*4; doFirex += 8)
			{
				Vec2f pos = Vec2f(this.getPosition().x + doFirex, this.getPosition().y + doFirey);
				if(Maths::Sqrt((Maths::Pow(pos.x-this.getPosition().x,2))+(Maths::Pow(pos.y-this.getPosition().y,2))) <= Size*4){
					getMap().server_setFireWorldspace(pos, true);
				}
			}
		}
	}
	
	if(this.getName() == "plant_blob"){
		if(this.get_s16("size") > 1000){
			CBlob@[] Blobs;	   
			getBlobsByName("naturebeing", @Blobs);
			for (uint i = 0; i < Blobs.length; i++)
			{
				CBlob@ b = Blobs[i];
				if(!b.hasTag("summoned")){
					b.Tag("summoned");
					b.setPosition(this.getPosition());
					this.server_Die();
				}
			}
		}
	}
	
	if(getNet().isServer()){
		this.Sync("size",true);
	}
}

void Combine(CBlob@ this, CBlob@ blob){
	if(getNet().isServer()){
		string name = this.getName();
		string nameOther = blob.getName();
		
		if(name == "plant_blob" && nameOther == "life_blob"){
			int Max = Maths::Min(this.get_s16("size"),blob.get_s16("size"));
			CBlob @slime = server_CreateBlob("slime_blob", -1, this.getPosition());
			slime.set_s16("size",Max*2);
			
			this.set_s16("size",this.get_s16("size")-Max);
			blob.set_s16("size",blob.get_s16("size")-Max);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getName() != "wooden_platform") && (blob.getShape().isStatic() || blob.hasTag("player"));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid && blob !is null)
	{
		if(this.get_u8("moldable") > 0)
		if(blob.hasTag("element")){
			if(this.get_s16("size") >= blob.get_s16("size")){
				if(this.getName() == blob.getName()){
					this.set_s16("size", this.get_s16("size")+blob.get_s16("size"));
					blob.set_s16("size", 0);
					return;
				}
			}
			Combine(this,blob);
		}
		
		
	}
	if(solid){
		if(blob !is null)if(blob.hasTag("element"))return;
		if(this.get_u8("moldable") <= 0 || this.getName() == "water_blob" || this.getName() == "fire_blob")if(getNet().isServer()){
			DestroySelf(this);
		}
	}
}
//sprite

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue
}

void onTick(CSprite@ this)
{
	
	if(this.getBlob() !is null){
		CBlob @blob = this.getBlob();
		
		if(blob.get_s16("size") >= 1000)this.animation.frame = 4;
		else if(blob.get_s16("size") >= 500)this.animation.frame = 3;
		else if(blob.get_s16("size") >= 250)this.animation.frame = 2;
		else if(blob.get_s16("size") >= 125)this.animation.frame = 1;
		else this.animation.frame = 0;
		
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return false;
}

void DestroySelf(CBlob@ this){
	if(getNet().isServer()){
		if(this.getName() == "gold_blob")MakeMat(this, this.getPosition(), "mat_gold", this.get_s16("size"));
		
		if(this.getName() == "death_blob")MakeMat(this, this.getPosition(), "ectoplasm", this.get_s16("size"));
		
		int Size = 4;
		if(this.get_s16("size") > 125)Size = 8;
		if(this.get_s16("size") > 250)Size = 16;
		if(this.get_s16("size") > 500)Size = 24;
		if(this.get_s16("size") > 1000)Size = 32;
		
		if(this.getName() == "evil_blob")while(this.get_s16("size") > 80){
			Vec2f pos = Vec2f(XORRandom(Size*2)-Size,-XORRandom(Size));
			server_CreateBlob("corruption_orb", this.getTeamNum(), this.getPosition()+pos);
			this.set_s16("size",this.get_s16("size")-100);
		}
		
		if(this.getName() == "life_blob"){
			while(this.get_s16("size") >= 10){
				Vec2f pos = Vec2f(XORRandom(Size*2)-Size,-XORRandom(Size));
				server_CreateBlob("wisp", this.getTeamNum(), this.getPosition()+pos);
				this.set_s16("size",this.get_s16("size")-10);
			}
			while(this.get_s16("size") >= 1){
				Vec2f pos = Vec2f(XORRandom(Size*2)-Size,-XORRandom(Size));
				server_CreateBlob("derangedwisp", -1, this.getPosition()+pos);
				this.set_s16("size",this.get_s16("size")-1);
			}
		}
		
		if(this.getName() == "slime_blob"){
			while(this.get_s16("size") >= 100){
				Vec2f pos = Vec2f(XORRandom(Size*2)-Size,-XORRandom(Size));
				server_CreateBlob("slime", -1, this.getPosition()+pos);
				this.set_s16("size",this.get_s16("size")-100);
			}
			if(this.get_s16("size") >= 50){
				Vec2f pos = Vec2f(XORRandom(Size*2)-Size,-XORRandom(Size));
				CBlob @slime = server_CreateBlob("slime", -1, this.getPosition()+pos);
				slime.Tag("baby");
			}
		}
		
		if(this.getName() == "blood_blob")while(this.get_s16("size") >= 10){
			Vec2f pos = Vec2f(XORRandom(Size*2)-Size,-XORRandom(Size));
			server_CreateBlob("heart", this.getTeamNum(), this.getPosition()+pos);
			this.set_s16("size",this.get_s16("size")-10);
		}
		
		if(this.getName() == "water_blob"){
			this.server_setTeamNum(-1);
			this.set_s16("size",this.get_s16("size")/2);
			if(this.get_s16("size") < 24)this.set_s16("size",24);
			if(this.get_s16("size") > 500)this.set_s16("size",500);
			SetupBomb(this, 1, this.get_s16("size"), 0.0f, this.get_s16("size"), 0.0f, false);
			this.set_f32("map_damage_ratio", 0.0f);
			this.set_f32("explosive_damage", 0.0f);
			this.set_f32("explosive_radius", this.get_s16("size"));
			this.set_bool("map_damage_raycast", false);
			this.set_string("custom_explosion_sound", "/wetfall1.ogg");
			this.set_u8("custom_hitter", Hitters::water);
			this.Tag("splash ray cast");
		}
		
		if(this.getName() == "fire_blob"){
			this.server_setTeamNum(-1);
			
			if(this.get_s16("size") > 1000)this.set_s16("size",1000);
			
			CBlob @fw = server_CreateBlob("firewave", this.getTeamNum(), this.getPosition());
			fw.set_s16("maxsize",this.get_s16("size")/10);
		}
		this.server_Die();
	}
}