//throwing common functionality.

void client_SendThrowOrActivateCommand(CBlob@ this)
{
	CBlob @carried = this.getCarriedBlob();
	if ((carried !is null || this.getInventory().getItemsCount() > 0) && this.isMyPlayer())
	{
		if (carried !is null)
			carried.SetDamageOwnerPlayer(this.getPlayer());
		CBitStream params;
		params.write_Vec2f(this.getPosition());
		params.write_Vec2f(this.getAimPos() - this.getPosition());
		params.write_Vec2f(this.getVelocity());
		this.SendCommand(this.getCommandID("activate/throw"), params);
	}
}

void client_SendThrowCommand(CBlob@ this)
{
	CBlob @carried = this.getCarriedBlob();
	if (carried !is null && this.isMyPlayer())
	{
		carried.SetDamageOwnerPlayer(this.getPlayer());
		CBitStream params;
		params.write_Vec2f(this.getPosition());
		params.write_Vec2f(this.getAimPos() - this.getPosition());
		params.write_Vec2f(this.getVelocity());
		this.SendCommand(this.getCommandID("throw"), params);
	}
}

void server_ActivateCommand(CBlob@ this, CBlob@ blob)
{
	if (blob !is null && getNet().isServer())
	{
		blob.SendCommand(blob.getCommandID("activate"));
		blob.Tag("activated");
	}
}