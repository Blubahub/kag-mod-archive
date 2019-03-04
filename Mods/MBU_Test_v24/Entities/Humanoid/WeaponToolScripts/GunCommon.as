#include "Ally.as"
#include "Knocked.as";
#include "Hitters.as"
#include "ModHitters.as"

void ManageGun(CBlob @this, CBlob @item, bool holding, string type){

	int drawback = this.get_s16(type+"_drawback");
	int speed = 5;
	int distance = 160;
	string sound_reload = "FlintlockPistolReload.ogg";
	
	if(item !is null){
		speed = item.get_u8("speed");
		if(item.exists("range"))distance = item.get_f32("range");
		if(item.exists("sound_reload"))sound_reload = item.get_string("sound_reload");
		
		if(item.exists("barrel_offset"))this.set_Vec2f(type+"_barrel_offset",item.get_Vec2f("barrel_offset"));
	}
	
	if(item !is null){
		if(drawback >= 0){
			if(holding || item.hasTag("loading")){
				this.set_u8(type+"_implement", 7);
				
				
				if(item.get_s8("bullets") <= 0){
					if(Maths::Min(this.getBlobCount("mat_bullet"),this.getBlobCount("mat_fizz")) > 0){
						item.Tag("loading");
						if(drawback == 0)if(this.getSprite() !is null)this.getSprite().PlaySound(sound_reload);
					} else {
						if(drawback == 0)if(this.getSprite() !is null)this.getSprite().PlaySound("NoAmmo.ogg");
						drawback = 1;
					}
				}
				
				if(item.hasTag("loading")){
					if(drawback == 20){
						int MaxTake = Maths::Min(Maths::Min(this.getBlobCount("mat_bullet"),this.getBlobCount("mat_fizz")),item.get_s8("bullet_max"));
						
						if(MaxTake > 0){
							item.set_s8("bullets",MaxTake);
							this.TakeBlob("mat_bullet", MaxTake);
							this.TakeBlob("mat_fizz", MaxTake);
							
							drawback++;
						}
						
						item.Untag("loading");
					} else {
						drawback += 1;
					}
				} else {
					if(drawback == 0)item.Tag("aiming");
				}
				
			} else {
				drawback = 0;
				
				if(!item.hasTag("loading") && item.hasTag("aiming")){
					if(item.get_s8("bullets") > 0){
						if(!this.isInWater()){
							Shoot(this,item,distance, type);
							
							drawback = -3;
						}
					}
					this.set_u8(type+"_implement", 7);
				}
				
				item.Untag("loading");
				item.Untag("aiming");
			}
		} else {
			this.set_u8(type+"_implement", 7);
			drawback += 1;
		}
		
	}
	
	this.set_s16(type+"_drawback",drawback);
	
}

void Shoot(CBlob @this, CBlob @item, f32 distance, string type){

	if(!getNet().isClient())return;

	Vec2f Pos = this.getPosition();
	Vec2f Aim = this.getAimPos();
	Vec2f Dir = Aim-Pos;
	Dir.Normalize();
	
	float angle = -((Aim-Pos).getAngle());

	HitInfo@[] hitScanBlobs;	   
	
	getMap().getHitInfosFromRay(Pos, angle, distance, this, @hitScanBlobs);
	
	for (uint i = 0; i < hitScanBlobs.length; i++)
	{
		CBlob@ b = hitScanBlobs[i].blob;
		if(b !is null)
		if(canShootBlob(this,item,b)){
			CBitStream params;
			params.write_u16(b.getNetworkID());
			params.write_u16(item.getNetworkID());
			params.write_Vec2f(hitScanBlobs[i].hitpos);
			params.write_bool(type == "main");
			this.SendCommand(this.getCommandID("shoot_gun"), params);
			return;
		}
	}
	
	CBitStream params;
	params.write_u16(0);
	params.write_u16(item.getNetworkID());
	params.write_Vec2f(Pos+Dir*distance);
	params.write_bool(type == "main");
	this.SendCommand(this.getCommandID("shoot_gun"), params);
}

bool canShootBlob(CBlob @this, CBlob @item, CBlob @target){
	
	if(this is target)return false;
	
	if(!target.hasTag("flesh"))return false;
	
	return true;
}

