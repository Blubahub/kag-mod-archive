void onInit(CBlob@ this)
{

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action3);
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onTick(CBlob@ this)
{
	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action3);
	if(this !is null &&holder !is null && point !is null && point.isKeyPressed(key_action3))
	{		

		Vec2f aimpos = Vec2f(holder.getAimPos().x, holder.getAimPos().y);
		Vec2f pos = Vec2f(holder.getPosition().x + XORRandom(32), holder.getPosition().y);
		Vec2f pos2 = Vec2f(holder.getPosition());
		Vec2f pos3 = Vec2f(holder.getPosition().x - XORRandom(32), holder.getPosition().y);
		this.getSprite().PlaySound("Respawn.ogg");
		CBlob@ guard = server_CreateBlob("knight", this.getTeamNum(), Vec2f(pos));
		if (guard !is null)
		{
			guard.getBrain().server_SetActive(true);
			guard.server_SetTimeToDie(16+XORRandom(3));
			guard.SetDamageOwnerPlayer(holder.getPlayer());
		}
		CBlob@ guard2 = server_CreateBlob("knight", this.getTeamNum(), Vec2f(pos2));
		if (guard2 !is null)
		{
			guard2.getBrain().server_SetActive(true);
			guard2.server_SetTimeToDie(16+XORRandom(3));
			guard2.SetDamageOwnerPlayer(holder.getPlayer());
		}
		CBlob@ guard3 = server_CreateBlob("knight", this.getTeamNum(), Vec2f(pos3));
		if (guard3 !is null)
		{
			guard3.getBrain().server_SetActive(true);
			guard3.server_SetTimeToDie(16+XORRandom(3));
			guard3.SetDamageOwnerPlayer(holder.getPlayer());
		}
		this.server_Die();
		
	}


}
