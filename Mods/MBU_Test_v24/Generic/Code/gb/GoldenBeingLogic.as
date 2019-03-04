#include "Hitters.as";
#include "ModHitters.as";
#include "ep.as";
#include "li.as"
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	
	this.Tag("no hands");
	
	this.set_s16("light_amount", 1000);
	this.Tag("light_sight");
	this.Tag("light_ability");
	
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("LightOrb.png", 0, Vec2f(24, 24));
	}
}

f32 DesiredScale = 0.6f;

void onTick(CBlob@ this)
{
	bool has_light =  this.get_s16("light_amount") > 0;
	bool smiting = false;
	
	f32 CurrentScale = 0.005f;
	f32 SpriteScale = 1.0f;
	if(this.exists("current_scale")){
		CurrentScale = this.get_f32("current_scale");
	}
	if(this.exists("sprite_scale")){
		SpriteScale = this.get_f32("sprite_scale");
	}
	
	
	if(this.isKeyPressed(key_action1) && has_light){
		smiting = true;
		
		if(getGameTime() % 10 == 0){
			this.sub_s16("light_amount",1);
		}
		
		f32 maxDistance = 800;
		
		if(CurrentScale < DesiredScale)CurrentScale += 0.0025f;
		
		Vec2f hitPos;
		f32 length;
		bool flip = this.isFacingLeft();
		f32 angle =	UpdateAngle(this,this.getAimPos());
		Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
		Vec2f startPos = this.getPosition();
		Vec2f endPos = startPos + dir * maxDistance;
		
		bool hit = getMap().rayCastSolid(startPos, endPos, hitPos);
		CBlob@[] gorbs;	   
		getBlobsByName("gorb", @gorbs);
		for (uint i = 0; i < gorbs.length; i++)
		{
			CBlob@ b = gorbs[i];
			if(b !is null){
				Vec2f my_pos = b.getPosition();
				
				for(int j = 0;j < (hitPos - startPos).Length();j += 8){
					
					Vec2f pos = Vec2f(j,0);
					pos.RotateBy(angle);
					pos = startPos+pos;
					
					float dis = Maths::Sqrt(Maths::Pow(my_pos.x-pos.x,2)+Maths::Pow(my_pos.y-pos.y,2));
					
					if(dis < (f32(b.get_u16("gold_amount"))/1000.0f)*48.0f){
						hitPos = pos;
						hit = true;
						if(getGameTime() % 10 == 0)if(b.get_u16("light_energy") < 1000)b.add_u16("light_energy",1);
						break;
					}
				}
			}
		}

		if (getNet().isClient())
		{					
			length = (hitPos - startPos).Length()+4;
			
			CSpriteLayer@ smite = this.getSprite().getSpriteLayer("smite");
			if (smite !is null)
			{
				smite.ResetTransform();
				smite.ScaleBy(Vec2f((length / 16.0f)/SpriteScale, CurrentScale/SpriteScale));
				smite.TranslateBy(Vec2f((length / 2), 1.0f * (flip ? 1 : -1)));
				smite.RotateBy((flip ? 180 : 0)+angle, Vec2f(0,0));
				if(CurrentScale > 0.11f)smite.SetVisible(true);
			}
			CSpriteLayer@ smite_end = this.getSprite().getSpriteLayer("smite_end");
			if (smite_end !is null)
			{
				smite_end.ResetTransform();
				smite_end.ScaleBy(Vec2f(1.0f, CurrentScale/SpriteScale));
				smite_end.TranslateBy(Vec2f(length+(43.0f/2.0f*CurrentScale), 1.0f * (flip ? 1 : -1)));
				smite_end.RotateBy((flip ? 180 : 0)+angle, Vec2f(0,0));
				if(CurrentScale > 0.11f)smite_end.SetVisible(true);
			}
			
			SpriteScale = CurrentScale;
			
			if(hit){
				
				for(int i = 0;i < 10.0f*CurrentScale;i++){
					Vec2f circle = Vec2f(f32(XORRandom(48))*CurrentScale,0);
					circle.RotateBy(XORRandom(360));
					ltp(hitPos+circle,Vec2f(XORRandom(3)-1,XORRandom(3)-1));
				}
				
				ShakeScreen( 500.0f*CurrentScale, 5, hitPos);
			}
		}
		
		if(getGameTime() % 3 == 0)
		{		
			HitInfo@[] blobs;
			Vec2f sideways = Vec2f(1,0);
			sideways.RotateBy(angle+90);
			
			for(int i = -5.0f*CurrentScale;i <=5.0f*CurrentScale;i++){
				getMap().getHitInfosFromRay(startPos+(sideways*i*9.0f), angle + (flip ? 180 : 0), (hitPos - startPos).Length(), this, blobs);
			}
		
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i].blob;
				if (b !is null && b !is this){
					if(XORRandom(2) == 0)ltp(b.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3),Vec2f(f32(XORRandom(3)-1)/10.0f,f32(XORRandom(3)-1)/10.0f));
					restore(this,b, 100.0f*(CurrentScale/DesiredScale));
				}
			}
		}
	} else {
		CurrentScale = 0.100f;
		
		
	}
	
	if(!smiting)
	if (isClient())
	{
		CSpriteLayer@ smite = this.getSprite().getSpriteLayer("smite");
		if (smite !is null)smite.SetVisible(false);
		CSpriteLayer@ smite_end = this.getSprite().getSpriteLayer("smite_end");
		if (smite_end !is null)smite_end.SetVisible(false);
	}
	
	this.set_f32("current_scale",CurrentScale);
	this.set_f32("sprite_scale",SpriteScale);
}

int UpdateAngle(CBlob@ this, Vec2f aimpos)
{
	Vec2f pos=this.getPosition();
	
	Vec2f aim_vec =(pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
	if(!this.isFacingLeft()) mouseAngle += 180;

	return -mouseAngle;
}