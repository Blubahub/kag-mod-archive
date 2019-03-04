const f32 MAX_SPEED = 8.0f;

void onInit(CBlob@ this)
{
	ShapeConsts@ consts = this.getShape().getConsts();
	consts.bullet = true;
	consts.net_threshold_multiplier = 0.5f;
	//this.getShape().SetGravityScale(0.4f);
	this.getSprite().SetZ(-60.0f);
	this.SetMapEdgeFlags(u8(CBlob::map_collide_sides | CBlob::map_collide_nodeath | CBlob::map_collide_bounce));
	this.server_SetTimeToDie(60);
	this.Tag("throwable");
	this.set_f32("throw_modifier", 1.0f);
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	const f32 vellen = this.getShape().vellen;

	if (solid)
	{
		const f32 vellen = this.getShape().vellen;
		const f32 fullTime = getTicksASecond() * 3.0f;
		this.getSprite().PlayRandomSound("BallDrop", 1.0f, 1.0f);
	}

	if (blob !is null)
	{
		if (blob.hasTag("player") && !blob.hasTag("bouncer"))
		{
			blob.server_AttachTo(this, 0);
		}

		if (blob.getName() == "croc"){
			this.Tag("croc bounce");
		}
	}
	else {
		this.Untag("croc bounce");
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	this.server_SetTimeToDie(600);
	this.Untag("croc bounce");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.server_SetTimeToDie(60);
}

