
#include "AbilityCommon.as"
#include "eleven.as"
#include "FireParticle.as"
#include "Explosion.as";
#include "Hitters.as";

void searing_intake(CBlob @this){

	if(CheckCooldown(this,"transfuse_cd") == 0){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f*getPowerMod(this,"fire"), @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				
				if(b !is null && b !is this){
					int Add = 0;
					
					if(b.getName() == "lantern"){
						if(b.isLight()){
							Add = 2;
							b.SetLight(false);
							b.getSprite().SetAnimation("nofire");
						}
					}
					else
					if(b.getName() == "stickfire"){
						Add = f32(b.get_u16("wood_amount"))/120.0f;
					}
					else
					if(b.exists("made_of_fire")){
						Add = b.get_u8("made_of_fire");
						if(getNet().isServer())b.server_Die();
					} else 
					if(b.hasTag("heat_infused")){
						Add = b.get_u16("heat_amount");
						b.set_u16("heat_amount",0);
						b.Untag("heat_infused");
						if(getNet().isServer())b.Sync("heat_amount",true);
					}
				
					
					Vec2f Dir = b.getPosition()-this.getPosition();
					Dir.Normalize();
					
					for(int j = 0;j < this.getDistanceTo(b);j += 1){
						if(XORRandom(20) < Add){
							CParticle @f = makeFireParticleOnly(this.getPosition()+Dir*j + Vec2f(XORRandom(11)-5,XORRandom(11)-5));
							if(f !is null)f.velocity = -Dir*1.0f;
						}
					}
					
					if(checkEInterface(this,b.getPosition(),8,Add)){
						this.add_s16("fire_amount", Add);
					}
				}
			}
		}

		if(this.get_s16("fire_amount") > 100)this.set_s16("fire_amount", 100);
		if(getNet().isServer())this.Sync("fire_amount", true);
		
		StartCooldown(this,"transfuse_cd",30*5);
	}

}
string searing_intake_icon(CBlob @this){
	if(this.get_u32("last_expell") < getGameTime()-(30*10) && this.get_s16("fire_amount") > 0)return "SearingExpell.png";
	return "SearingIntake.png";
}


void searing_vent(CBlob @this){
	if(this.get_s16("fire_amount") > 0){
		if(!this.hasTag("venting_heat"))this.Tag("venting_heat");
		else this.Untag("venting_heat");
	}
}
string searing_vent_icon(CBlob @this){
	if(this.hasTag("venting_heat")){
		return "SearingVent"+(5-((getGameTime()/4) % 6))+".png";
	}
	return "SearingVent.png";
}

void searing_nova(CBlob @this){
	if(CheckCooldown(this,"nova_cd") == 0){
	
		int fire = Maths::Min(this.get_s16("fire_amount"),100);
	
		if(fire >= 10){
	
			if(getNet().isServer()){
				CBlob @n = server_CreateBlob("no",-1,this.getPosition());
				n.set_f32("final_scale",(f32(fire*2)*getPowerMod(this,"fire"))/100.0f);
				n.set_f32("damage",f32(fire)*getPowerMod(this,"fire"));
			}
		
			
		
			this.sub_s16("fire_amount",fire);
			if(getNet().isServer())this.Sync("fire_amount", true);
		
			StartCooldown(this,"nova_cd",30*10);
		}
	}
}
string searing_nova_icon(CBlob @this){
	return "SearingNova.png";
}


void searing_discharge(CBlob @this){

	if(CheckCooldown(this,"discharge_cd") == 0){
		this.set_u8("custom_hitter",Hitters::fire);
		
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f*getPowerMod(this,"fire"), @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];

				if(checkEInterface(this,b.getPosition(),32,20))
				if(b.hasTag("fire source") || b.exists("made_of_fire") || b.hasTag("heat_infused")){
					Explode(this,32.0f*getPowerMod(this,"fire"),5.0f*getPowerMod(this,"fire"), b.getPosition());
				}
			}
		}
		
		StartCooldown(this,"discharge_cd",30*10);
	}

}
string searing_discharge_icon(CBlob @this){
	return "SearingDischarge.png";
}


void searing_infuse(CBlob @this){

	if(CheckCooldown(this,"transfuse_cd") == 0){
		
		CBlob @item = this.getCarriedBlob();
		
		int fire = Maths::Min(this.get_s16("fire_amount"),100);
		
		if(item !is null){
			item.Tag("heat_infused");
			
			int item_max = 10;
			
			if(item.hasTag("wooden"))item_max = 5;
			if(item.hasTag("stone"))item_max = 20;
			if(item.hasTag("metal"))item_max = 50;
			if(item.getName() == "humanoid")item_max = 100;
			
			int item_max_addable = item_max-item.get_u16("heat_amount");
			
			if(item.getName() == "humanoid")item.add_u16("fire_amount",Maths::Min(fire,item_max_addable));
			else item.add_u16("heat_amount",Maths::Min(fire,item_max_addable));
			
			if(item.get_u16("heat_amount") >= item_max){
				this.server_Hit(item, item.getPosition(), Vec2f(0,0), 0.25f, Hitters::fire, true);
				item.set_u8("heat",20);
				item.Tag("heated");
			}
			
			fire -= Maths::Min(fire,item_max_addable);
			
			
		}
		
		this.set_s16("fire_amount",fire);
		if(getNet().isServer())this.Sync("fire_amount", true);
		
		StartCooldown(this,"transfuse_cd",30*5);
	}

}
string searing_infuse_icon(CBlob @this){
	return "SearingInfusion.png";
}


void blazing_trail(CBlob @this){
	if(this.get_s16("fire_amount") > 0){
		if(!this.hasTag("trail_blazing"))this.Tag("trail_blazing");
		else this.Untag("trail_blazing");
	}
}
string blazing_trail_icon(CBlob @this){
	if(this.hasTag("trail_blazing")){
		return "BlazingTrail"+(5-((getGameTime()/2) % 6))+".png";
	}
	return "BlazingTrail.png";
}

void searing_bolt(CBlob @this){
	if(CheckCooldown(this,"fire_bolt_cd") == 0)
		if(this.get_s16("fire_amount") >= 10){
			
			if(getNet().isServer()){
				CBlob @fb = server_CreateBlob("fb",this.getTeamNum(),this.getPosition());
				if(fb !is null){
					Vec2f vec = this.getAimPos()-this.getPosition();
					vec.Normalize();
					fb.setVelocity(vec*2.0f);
					
					fb.set_u16("radius",16*getPowerMod(this,"fire"));
				}
			}
			
			this.sub_s16("fire_amount",10);
			if(getNet().isServer())this.Sync("fire_amount", true);
			
			StartCooldown(this,"fire_bolt_cd",30*1);
		}
}
string searing_bolt_icon(CBlob @this){
	return "SearingBolt.png";
}

void summon_sun(CBlob @this){
	if(CheckCooldown(this,"sun_cd") == 0)
		if(this.get_s16("fire_amount") >= 100){
			
			if(getNet().isServer()){
				CBlob @fb = server_CreateBlob("sn",this.getTeamNum(),Vec2f(this.getPosition().x,-100));
				if(fb !is null){
					fb.set_u16("radius",100*getPowerMod(this,"fire"));
				}
			}
			
			this.sub_s16("fire_amount",100);
			if(getNet().isServer())this.Sync("fire_amount", true);
			
			StartCooldown(this,"sun_cd",30*120);
		}
}
string summon_sun_icon(CBlob @this){
	return "SummonSun.png";
}

void form_pyro(CBlob @this){
	if(this.get_s16("fire_amount") >= 50){
		this.Tag("pyromaniac");
		if(getNet().isServer())this.Sync("pyromaniac", true);
	}
}
string form_pyro_icon(CBlob @this){
	return "FormPyro.png";
}