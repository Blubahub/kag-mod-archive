void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		this.getShape().SetRotationsAllowed(false);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		const bool facingleft = this.isFacingLeft();
		CBlob@ holder = point.getOccupied();
		if (holder is null) return;
		Vec2f aim = holder.getAimPos() - holder.getPosition();
		aim.Normalize;
		float aimangle = aim.getAngleDegrees()*-1;
		this.setAngleDegrees(aimangle + (facingleft ? 180.0f : 0.0f));
	}
	else
	{
		this.getShape().SetRotationsAllowed(true);
	}
}