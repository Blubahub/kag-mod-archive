
void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData){

	CPlayer@ p = this.getDamageOwnerPlayer();
	
	if(p !is null){
		CBlob@ player = p.getBlob();
		if(player !is null){
		
			if(hitBlob.getHealth() <= 0)
			if(hitBlob.get_s16("corruption") <= player.get_s16("corruption"))
			if(!hitBlob.hasTag("evil"))
			if(hitBlob.hasTag("flesh") && !hitBlob.hasTag("lifeless"))
			if(hitBlob.getTeamNum() == player.getTeamNum() || hitBlob.getTeamNum() > 20 || hitBlob.hasTag("holy") || player.hasTag("evil"))
			if(hitBlob.getHealth()+damage > 0){
				player.set_s16("corruption",player.get_s16("corruption")+10);
				player.set_s16("kills",player.get_s16("kills")+1);
				if(getNet().isServer())player.Sync("corruption",true);
			}
		}
	}
}