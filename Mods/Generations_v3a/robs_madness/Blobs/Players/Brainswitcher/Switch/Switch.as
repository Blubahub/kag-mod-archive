#include "Hitters.as";

void onInit(CBlob@ this)
{
	//dont collide with edge of the map
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getConsts().bullet = true;
	
	this.getShape().SetGravityScale(0.0f);
	this.server_SetTimeToDie(3);
	
	this.getSprite().SetZ(5);
	
	this.Tag("can_dispell");
	
	// Sounds by TFlippy
	this.getSprite().PlaySound("WC3_MindGuy_Cast", 1.00f, 1.00f);
}

void onTick(CBlob@ this)
{
	
	Vec2f vel = this.getVelocity();
	if (Maths::Abs(vel.x) > 0.1)
	{
		f32 angle = this.get_f32("angle");
		angle += vel.x * 10;
		if (angle > 360.0f)
			angle -= 360.0f;
		else if (angle < -360.0f)
			angle += 360.0f;
		this.set_f32("angle", angle);
		this.setAngleDegrees(angle);
	}
	
	ParticleAnimated("SwitchParticle.png", this.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), this.getVelocity()/2+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.2, XORRandom(360), 1.0f, 1, -0.01, true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("player"));
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null && blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && blob.hasTag("player"))
	{
		if (getNet().isServer())
		{
			CPlayer@ caster_ply = getPlayerByNetworkId(this.get_u16("owner_id")); // Seems that CPlayer doesn't have a numeric ID >:(
			CPlayer@ target_ply = blob.getPlayer();
			
			if (caster_ply !is null && target_ply !is null)
			{
				CBlob@ caster_blob = caster_ply.getBlob();
				const u8 caster_team = caster_blob !is null ? caster_blob.getTeamNum() : caster_ply.getTeamNum();
				const u8 target_team = blob.getTeamNum();
			
				blob.server_SetPlayer(caster_ply);
				blob.server_setTeamNum(caster_team);
			
				if (caster_blob !is null) 
				{
					caster_blob.server_SetPlayer(target_ply);
					caster_blob.server_setTeamNum(target_team);
				}
				
				// print(caster_ply.getUsername());
				// print(target_ply.getUsername());
			}
		}

		if (getNet().isClient())
		{
			this.getSprite().PlaySound("AOE1_Wololo.ogg", 1.00f, 1.00f);
		}
	}

	if (getNet().isServer())
	{
		if (solid && blob !is null) this.server_Die(); // Should happen on collision with anything solid, including doors
	}

	

	// if(blob !is null && blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && blob.hasTag("player"))
	// {
		// CPlayer@ p = blob.getPlayer();
		// if(p !is null){
			// if(this.getDamageOwnerPlayer() !is null){
				// CBlob@ b = this.getDamageOwnerPlayer().getBlob();
				// if(b !is null){
					// blob.server_SetPlayer(this.getDamageOwnerPlayer());
					// blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
					// b.server_SetPlayer(p);
					// b.server_setTeamNum(p.getTeamNum());
				// } else {
					// blob.server_SetPlayer(this.getDamageOwnerPlayer());
					// blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
				// }
			// }
		// } else {
			// if(this.getDamageOwnerPlayer() !is null){
				// CBlob@ b = this.getDamageOwnerPlayer().getBlob();
				// if(b !is null){
					// blob.server_SetPlayer(this.getDamageOwnerPlayer());
					// blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
					// b.server_SetPlayer(null);
				// } else {
					// blob.server_SetPlayer(this.getDamageOwnerPlayer());
					// blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
				// }
			// }
		// }
	// }
	
	// if(solid)this.server_Die();
	// if(blob !is null)if(blob.getName() == "stone_door" || blob.getName() == "wooden_door")if(blob.getShape().getConsts().collidable)this.server_Die();
}

// Sounds by TFlippy
void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("WC3_MindGuy_Hit", 1.00f, 1.00f);
}