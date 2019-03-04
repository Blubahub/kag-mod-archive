
#include "Hitters.as";
#include "ModHitters.as";
#include "ep.as";
#include "li.as"

void onInit(CBlob @ this){
	if(this.getName() != "lo")return;
	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type", 11);
	this.set_string("equip_script", "loes.as");
	this.set_f32("speed_modifier",1.01f);
	
	this.Tag("two_handed");
	
	this.set_u8("fabric",1);
}

void onTick(CBlob @ this){
	if(this.getName() == "lo")return;
	
	bool smiting = false;
	
	const string[] type = {"main","sub"};
	const string[] spr_type = {"front","back"};
	for(int i = 0;i < type.length;i++){
	
		bool has_light =  this.get_s16("light_amount") > 0;
	
		if(this.get_string(type[i]+"_tool_use") == "lo" && has_light){
			smiting = true;
			
			if(getGameTime() % 10 == 0){
				this.sub_s16("light_amount",1);
			}
			
			f32 maxDistance = 400;
			
			Vec2f Offset = Vec2f(-8.0f, -5.0f);
			
			if(this.getSprite().getSpriteLayer(spr_type[i]+"arm") !is null){
				Offset = this.getSprite().getSpriteLayer(spr_type[i]+"arm").getOffset()+Vec2f(-8.0f, -5.0f);
			}
			if(!this.isFacingLeft())Offset.x = -Offset.x;
			
			Vec2f hitPos;
			f32 length;
			bool flip = this.isFacingLeft();
			f32 angle =	UpdateAngle(this,this.getAimPos()-Offset);
			Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
			Vec2f startPos = this.getPosition()+Offset;
			Vec2f endPos = startPos + dir * maxDistance;

			if(this.getSprite().getSpriteLayer(spr_type[i]+"arm") !is null){
				Offset = this.getSprite().getSpriteLayer(spr_type[i]+"arm").getOffset()+Vec2f(-8.0f, -5.0f);
			}
			
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
						if(this.isFacingLeft())pos = -pos;
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
					smite.SetOffset(Offset);
					
					smite.ResetTransform();
					smite.ScaleBy(Vec2f(length / 32.0f, 1.0f));
					smite.TranslateBy(Vec2f((length / 2), 1.0f * (flip ? 1 : -1)));
					smite.RotateBy((flip ? 180 : 0)+angle, Vec2f(0,0));
					smite.SetVisible(true);
				}
				
				this.set_f32(type[i]+"_arm_angle",0);
				this.set_f32(type[i]+"_equip_angle",0);
				
				if(hit)ltp(hitPos+Vec2f(XORRandom(7)-3,XORRandom(7)-3),Vec2f(XORRandom(3)-1,XORRandom(3)-1));
			}
			
			if(getGameTime() % 10 == 0)
			{		
				HitInfo@[] blobs;
				getMap().getHitInfosFromRay(startPos, angle + (flip ? 180 : 0), (hitPos - startPos).Length(), this, blobs);

				for (int i = 0; i < blobs.length; i++)
				{
					CBlob@ b = blobs[i].blob;
					if (b !is null && b !is this){
						ltp(b.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3),Vec2f(f32(XORRandom(3)-1)/10.0f,f32(XORRandom(3)-1)/10.0f));
						restore(this,b, 1.0f);
					}
				}
			}
		}
	}
	
	if(!smiting)
	if (isClient())
	{
		CSpriteLayer@ smite = this.getSprite().getSpriteLayer("smite");
		if (smite !is null)
		{
			smite.SetVisible(false);
		}
	}
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

void onTick(CSprite@ this)
{
	if(this.getSpriteLayer("smite") !is null){
		this.getSpriteLayer("smite").setRenderStyle(RenderStyle::additive);
	} else {
		this.RemoveSpriteLayer("smite");
		CSpriteLayer@ smite = this.addSpriteLayer("smite", "sm.png", 32, 8);
		if(smite !is null)
		{
			Animation@ anim = smite.addAnimation("default", 0, false);
			anim.AddFrame(0);
			smite.SetRelativeZ(-5.0f);
			smite.SetVisible(false);
		}
	}
}