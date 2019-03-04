
void ManageBow(CBlob @this, bool charging){

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f vec = aimpos - pos;
	vec.Normalize();

	if(!charging && this.get_u16("bowcharge") > 20){
		CreateArrow(this,this.getPosition(),vec*(this.get_u16("bowcharge")/2.2f),0);
		this.set_u16("bowcharge",0);
	}
	
	if(charging){
		if(this.getSprite() !is null)
		if(this.get_u16("bowcharge") == 0){
			this.getSprite().RewindEmitSound();
			this.getSprite().SetEmitSoundPaused(false);
		}
		if(this.get_u16("bowcharge") < 40)this.set_u16("bowcharge",this.get_u16("bowcharge")+1);
		else this.getSprite().SetEmitSoundPaused(true);
		
		this.Tag("shootingbow");
	} else {
		if(this.getSprite() !is null){
			this.getSprite().SetEmitSoundPaused(true);
			//this.getSprite().PlaySound("PopIn.ogg");
		}
		this.set_u16("bowcharge",0);
		if(this.hasTag("shootingbow"))this.Untag("shootingbow");
	}

}


CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	CBlob@ arrow = server_CreateBlobNoInit("arrow");
	if (arrow !is null)
	{
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
	}
	return arrow;
}