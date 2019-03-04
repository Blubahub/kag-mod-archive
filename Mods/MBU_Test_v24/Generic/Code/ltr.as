
#include "la.as";

void onInit(CBlob@ this){
	this.set_s16("life_amount",1000);
	
	this.Tag("alive");
}

void onTick(CBlob @this){

	CControls @control = this.getControls();
	
	if(control !is null){
		this.setAimPos(control.getMouseWorldPos());
	}

	
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::burn || customData == Hitters::fire)return 0;
	
	for(int i = 0;i < damage;i++)life_kiss(this,this.getPosition()+Vec2f(0,-48-XORRandom(80)));
	
	CBlob @real_attacker = hitterBlob;
	
	if(hitterBlob.getDamageOwnerPlayer() !is null)if(hitterBlob.getDamageOwnerPlayer().getBlob() !is null)@real_attacker = hitterBlob.getDamageOwnerPlayer().getBlob();
	
	if(real_attacker !is null){
	
		if(real_attacker.hasTag("soul")){
			this.set_u8("life_flow_state", 1);
			this.Tag("life_linked");
			real_attacker.Tag("life_linked");
			this.set_u16("life_link_partner",real_attacker.getNetworkID());
			real_attacker.set_u16("life_link_partner",this.getNetworkID());
			
			if(getNet().isServer()){
				this.Sync("life_linked",true);
				this.Sync("life_link_partner",true);
				real_attacker.Sync("life_linked",true);
				real_attacker.Sync("life_link_partner",true);
			}
		}
	
	}
	
	if(damage > 3.0f)life_cage(this,this.getPosition()+Vec2f(0,-96));
	
	if(real_attacker !is null){
		CBlob@[] orbs;
		getBlobsByName("wo", @orbs);
		
		for(int j = 0; j < orbs.length; j++)
		{
			CBlob @orb = orbs[j];
			if(orb !is null && orb.getTeamNum() == this.getTeamNum() && !orb.hasTag("spawn")){
				Vec2f vec = real_attacker.getPosition()-orb.getPosition();
				vec.Normalize();
				if(orb.getVelocity().Length() < 0.5f)orb.setVelocity(vec*1.0f);
			}
		}
	}
	
	return damage;
}