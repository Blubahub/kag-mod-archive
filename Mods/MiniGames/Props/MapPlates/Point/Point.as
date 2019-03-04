const string aligned = "aligned to tiles";

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	if (shape !is null)
	{
		shape.SetRotationsAllowed(false);
		shape.getConsts().mapCollisions = false;
		shape.SetGravityScale(0.0f);
		shape.SetStatic(true);
	}
	this.setVelocity(Vec2f_zero);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

/*void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();
	if (!this.hasTag(aligned))
	{
		Vec2f p = this.getPosition();
		this.setPosition(p);
		this.setVelocity(Vec2f());
		shape.SetGravityScale(0.0f);

		//print("align to ground "+this.getName());

		this.Tag(aligned);
	}
	else
	{
		shape.SetStatic(true);
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}*/

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}