#include "BrainCommon.as"
#include "Hitters.as";
#include "RunnerCommon.as";

void onInit( CBrain@ this )
{
	if (getNet().isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

void onTick(CBrain@ this)
{
	if (!getNet().isServer()) return;
	
	CBlob@ blob = this.getBlob();
	
	if (blob.getPlayer() !is null) return;
	
	// SearchTarget(this, false, true);
	
	const f32 chaseDistance = blob.get_f32("chaseDistance");
	CBlob@ target = this.getTarget();

	// print("" + this.getCurrentScript().tickFrequency);
	
	if (target is null)
	{
		const bool raider = blob.get_bool("raider");
		const Vec2f pos = blob.getPosition();
	
		CBlob@[] blobs;
		// getMap().getBlobsInRadius(blob.getPosition(), chaseDistance, @blobs);
		getBlobsByTag("human", @blobs);
		const u8 myTeam = blob.getTeamNum();
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			Vec2f bp = b.getPosition() - pos;
			f32 d = bp.Length();
			
			if (b.getTeamNum() != myTeam && !b.hasTag("dead") && !b.hasTag("invincible") && d <= chaseDistance && isVisible(blob, b))
			{
				this.SetTarget(b);
				blob.set_u32("nextAttack", getGameTime() + blob.get_u8("reactionTime"));
				
				this.getCurrentScript().tickFrequency = 1;
				return;
			}
		}
		
		if (raider)
		{
			CBlob@ raid_target = getBlobByNetworkID(blob.get_u16("raid target"));
			
			if (blob.get_u16("raid target") != 0 && raid_target !is null)
			{
				if (blob.getTickSinceCreated() % 90 == 0) 
				{
					this.SetPathTo(raid_target.getPosition(), false);
				}
				
				Vec2f dir = this.getNextPathPosition() - blob.getPosition();
				dir.Normalize();
				
				Move(this, blob, blob.getPosition() + dir * 16);
			
				// if (blob.getTickSinceCreated() % 20 == 0) 
				// {
					// this.SetPathTo(raid_target.getPosition(), false);
					// blob.set_Vec2f("raid_position", this.getNextPathPosition());
					// // print("" + blob.get_Vec2f("raid_position").x);
					// // print("" + raid_target.getPosition().x);
				// }
				
				// Move(this, blob, blob.get_Vec2f("raid_position"));
				
				this.getCurrentScript().tickFrequency = 1;
			}
			else
			{
				CBlob@[] bases;
				getBlobsByTag("faction_base", @bases);
			
				if (bases.length > 0) 
				{
					blob.set_u16("raid target", bases[XORRandom(bases.length)].getNetworkID());
				}
				
				this.getCurrentScript().tickFrequency = 1;
			}
		}
		else this.getCurrentScript().tickFrequency = 15;
	}
	
	if (target !is null && target !is blob)
	{			
		// print("" + target.getConfig());
	
		this.getCurrentScript().tickFrequency = 1;
		
		// print("" + this.lowLevelMaxSteps);
		
		const f32 distance = (target.getPosition() - blob.getPosition()).Length();
		const f32 minDistance = blob.get_f32("minDistance");
		const f32 maxDistance = blob.get_f32("maxDistance");
		
		const bool visibleTarget = isVisible(blob, target);
		
		const bool target_attackable = target !is null && !(target.getTeamNum() == blob.getTeamNum() || target.hasTag("material"));
		const bool lose = distance > maxDistance;
		const bool chase = target_attackable && (distance > chaseDistance || !visibleTarget);
		const bool retreat = !target_attackable || ((distance < minDistance) && visibleTarget);
		
		if (lose)
		{
			this.SetTarget(null);
			this.getCurrentScript().tickFrequency = 15;
			return;
		}
		
		if (target_attackable)
		{
			if (visibleTarget) 
			{
				f32 jitter = blob.get_f32("inaccuracy");
				Vec2f randomness = Vec2f((100 - XORRandom(200)) * jitter, (100 - XORRandom(200)) * jitter);
				blob.setAimPos(target.getPosition() + randomness);
				// const f32 reactionTime = blob.get_f32("reactionTime");
			
				if (blob.get_u32("nextAttack") < getGameTime())
				{
					AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
					
					if(point !is null) 
					{
						CBlob@ gun = point.getOccupied();
						if(gun !is null) 
						{
							if (blob.get_u32("nextAttack") < getGameTime())
							{							
								blob.setKeyPressed(key_action1,true);
								blob.set_u32("nextAttack", getGameTime() + blob.get_u8("attackDelay"));
							}
						}
					}
				}
				else if (blob.get_bool("bomber") && blob.get_u32("nextBomb") < getGameTime())
				{
					if (XORRandom(100) < 2)
					{
						CBlob@ bomb = server_CreateBlob("bomb", blob.getTeamNum(), blob.getPosition());
						if (bomb !is null)
						{
							Vec2f dir = blob.getAimPos() - blob.getPosition();
							f32 dist = dir.Length();
							
							dir.Normalize();
							
							bomb.setVelocity((dir * (dist * 0.4f)) + Vec2f(0, -5));
							blob.set_u32("nextBomb", getGameTime() + 600);
						}
					}
				}
			}
		}
		
		if (target_attackable && chase)
		{
			if (getGameTime() % 90 == 0) this.SetPathTo(target.getPosition(), true);
			// if (getGameTime() % 45 == 0) this.SetHighLevelPath(blob.getPosition(), target.getPosition());
			// Move(this, blob, this.getNextPathPosition());
			// print("chase")
			
			Vec2f dir = this.getNextPathPosition() - blob.getPosition();
			dir.Normalize();
			
			Move(this, blob, blob.getPosition() + dir * 16);
		}
		else if (retreat)
		{
			DefaultRetreatBlob( blob, target );
			// print("retreat");
		}

		if (target.hasTag("dead")) 
		{
			CPlayer@ targetPlayer = target.getPlayer();
			
			if (targetPlayer !is null && target.hasTag("dead"))
			{
				blob.set_u16("stolen coins", blob.get_u16("stolen coins") + (targetPlayer.getCoins() * 0.9f));
			}
		
			this.SetTarget(null);
			this.getCurrentScript().tickFrequency = 30;
			return;
		}
	}
	else
	{
		if (XORRandom(2) == 0) RandomTurn(blob);		
	}

	FloatInWater(blob); 
} 

void Move(CBrain@ this, CBlob@ blob, Vec2f pos)
{
	Vec2f dir =  blob.getPosition() - pos;
	dir.Normalize();

	// print("DIR: x: " + dir.x + "; y: " + dir.y);

	blob.setKeyPressed(key_left, dir.x > 0);
	blob.setKeyPressed(key_right, dir.x < 0);
	blob.setKeyPressed(key_up, dir.y > 0);
	blob.setKeyPressed(key_down, dir.y < 0);
}