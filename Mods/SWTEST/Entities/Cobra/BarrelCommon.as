
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("fire barrel"))
	{	
		if (this.hasTag("fired")) return;
		print("jeejee ampuuu");

		string projectile = params.read_string();
		f32 range = this.get_f32("range");
		print("range: " + range);

		//if (getNet().isServer())
	//{
		CBlob@ bullet = server_CreateBlob(projectile, this.getTeamNum(), this.getPosition());
		if (bullet !is null)
		{
			CBlob@ holder = this.getAttachments().getAttachedBlob("BARREL", 0);
			if (holder is null) return;

			//bullet.server_SetTimeToDie(range);
			//bullet.SetDamageOwnerPlayer(holder.getPlayer());
			Vec2f aim = (holder.get_Vec2f("targetpos"));
			Vec2f pos = this.getPosition();
			print("target position: "+ aim.x + "  " + aim.y);
			Vec2f norm = aim - pos;
			norm.Normalize();
			bullet.setVelocity(norm * (-50));
			//holder.AddForce(norm *(-180.0f));

			this.Tag("fired");
		
		}
		//}
	}
}/*
void Barrel_Setup( CBlob@ this, f32 range, f32 accuracy)
{
	this.set_f32("range", range);
	this.set_f32("accuracy", accuracy);
}*//*
void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		CBlob@ holder = this.getAttachments().getAttachedBlob("BARREL", 0);
		if (holder is null)
		{
			return;
		}
		holder.server_Die();
		print("pitäs ampuuu");
		//if (!holder.isAttached())
		//this.setAngleDegrees(holder.getAngleDegrees());
		if (holder.getName() == "builder") return;
		//print("" + holder.getAngleDegrees() + this.getAngleDegrees());
	}

}

*/
void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	this.getSprite().PlaySound("/Respawn.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	if (!this.isAttached())
	{
		return true;
	}

	else
	{
		return false;
	}
}
/*
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	//this.server_Die();
	if (blob !is null && blob.hasTag("barrel") && !blob.isAttached())
	{			
		print("collided");
		this.server_AttachTo(blob, "BARREL");
		this.getSprite().PlaySound("/Respawn.ogg");
	}
}