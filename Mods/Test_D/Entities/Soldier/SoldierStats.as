#include "PlayerStatsCommon.as"
#include "SoldierCommon.as"

//cannot be server only - we need the hitter

void onTick( CBlob@ this )
{
	if(getNet().isClient()) return;

	Stats@ stats = getStats(this.getPlayer());
	Soldier::Data@ data = Soldier::getData(this);
	if (stats is null || data is null)
		return;

	if (Soldier::inAir(data))
	{
		stats.airTime++;
		if (data.dead){
			stats.airTimeDead;
		}
	}

	if (this.getTickSinceCreated() > 5){
		stats.mileage += (stats.lastMeasurePos - data.pos).getLength();
	}
	stats.lastMeasurePos = data.pos;

	if (data.dead){
		stats.deadTime++;
	}
	else{
		stats.aliveTime++;
	}

	if (data.fire || data.fire2){
		stats.fireKeyTime++;
	}

	if (data.jump){
		stats.jumpKeyTime++;
	}

	if (data.crouch){
		stats.crouchKeyTime++;
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(getNet().isClient()) return damage;

	Stats@ stats = getStats(this.getPlayer());
	if (stats is null)
		return damage;

	stats.hitWhenDeadCount++;

	//if (this.hasTag("dead"))
	//	return damage;

	stats.damageRecieved += damage;

	CPlayer@ owner = hitterBlob.getDamageOwnerPlayer();
	Stats@ ownerStats = getStats(owner);
	if (owner !is null && ownerStats !is null)
	{
		Soldier::Data@ data = Soldier::getData(this);

		ownerStats.damageSent += damage;

		if (Soldier::inAir(data) && stats.airTime > 30){
			ownerStats.airShotCount++;
		}

		//if (hitterBlob.hasTag("map looped")){
			//ownerStats.screenWrapHits++;
		//}

		if (hitterBlob.getName() == "grenade"){
			f32 distance = (worldPoint - data.pos).getLength();
			if (ownerStats.nadeKillDistance == 0.0f || distance < ownerStats.nadeKillDistance){
				ownerStats.nadeKillDistance = distance;
			}
		}
	}

	return damage;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(getNet().isClient()) return;

	if (cmd == Soldier::Commands::DIE)
	{
		Stats@ victimStats = getStats(this.getPlayer());
		if (victimStats is null)
			return;

		if (victimStats.aliveTime > victimStats.longestAliveTime){
			victimStats.longestAliveTime = victimStats.aliveTime;
		}

		if (victimStats.aliveTime < victimStats.shortestAliveTime){
			victimStats.shortestAliveTime = victimStats.aliveTime;
		}

		victimStats.aliveTime = 0;

		// from player

		Stats@ attackerStats = getStats(this.getPlayerOfRecentDamage());
		if (attackerStats is null)
			return;

		const u32 time = getGameTime();

		if (this.getPlayer() is this.getPlayerOfRecentDamage())	{
			victimStats.suicideCount++;
		}

		int killTime = time - attackerStats.lastKillTime;
		attackerStats.timeSinceLastKill = killTime;
		attackerStats.sumTimeSinceLastKill += killTime;
		attackerStats.lastKillTime = time;

		if (time > CONSECUTIVE_KILL_TIMER){
			attackerStats.consecutiveKills = 0;
		}
		attackerStats.consecutiveKills++;
		if (attackerStats.consecutiveKills > attackerStats.mostConsecutiveKills){
			attackerStats.mostConsecutiveKills = attackerStats.consecutiveKills;
		}

		attackerStats.killsInRound++;
	}
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	if(getNet().isClient()) return;

	Stats@ stats = getStats(this.getPlayer());
	if (stats is null)
		return;

	if (this.getHealth() > oldHealth){
		stats.reviveCount++;
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(getNet().isClient()) return;

	if (blob !is null && blob.getName() == "falling_tile" && blob.getDamageOwnerPlayer() !is this.getPlayer()){
		Stats@ stats = getStats(this.getPlayer());
		if (stats is null)
			return;

		stats.squashed++;
	}
}
