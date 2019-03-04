// Princess brain

#define SERVER_ONLY

#include "BrainCommon.as"
#include "Hitters.as";

void onInit(CBrain@ this)
{
	InitBrain(this);

	this.server_SetActive(true);   // always running
	CBlob @blob = this.getBlob();
	blob.set_f32("gib health", -1.5f);
}

void onInit(CBlob@ this)
{
	this.setSexNum(1);
	this.Tag("negrunetatoo");
}

void onTick(CBrain@ this)
{
	SearchTarget(this);

	CBlob @blob = this.getBlob();

	this.getCurrentScript().tickFrequency = 29;
	
	if(this.getTarget() is null){
		RandomTurn(blob);
		if(XORRandom(10) == 0)SearchTargetFreindly(this);
	} else 
	if(this.getTarget().getTeamNum() != blob.getTeamNum()){
		RunawayProper(this,blob,this.getTarget());
	}

	FloatInWater(blob);
}

// BLOB

//physics logic
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && blob is this.getBrain().getTarget() && blob.getTeamNum() == this.getTeamNum())
	{
		this.getSprite().PlaySound("/Kiss.ogg");
		this.getBrain().SetTarget(null);
	}
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(hitterBlob.getTeamNum() == this.getTeamNum())return 0;
	if(Hitters::fire == customData)return 0;
	if(Hitters::crush == customData)return 0;
	if(Hitters::boulder == customData)return 0;
	if(Hitters::keg == customData)return 0;
	if(Hitters::saw == customData)return 0;
	if(Hitters::spikes == customData)return 0;
	if(Hitters::suddengib == customData)return 0;
	
	if(damage > 0.5f)damage -= 0.5f;
	else return 0;
	
	return damage; //no block, damage goes through
}


void SearchTargetFreindly(CBrain@ this, const bool seeThroughWalls = false, const bool seeBehindBack = true)
{
	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// search target if none

	if (target is null)
	{
		CBlob@ oldTarget = target;
		@target = getNewTargetFreindly(this, blob, seeThroughWalls, seeBehindBack);
		this.SetTarget(target);

		if (target !is oldTarget)
		{
			onChangeTarget(blob, target, oldTarget);
		}
	}
}

CBlob@ getNewTargetFreindly(CBrain@ this, CBlob @blob, const bool seeThroughWalls = false, const bool seeBehindBack = false)
{
	CBlob@[] players;
	getBlobsByTag("player", @players);
	Vec2f pos = blob.getPosition();
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		Vec2f pos2 = potential.getPosition();
		const bool isBot = blob.getPlayer() !is null && blob.getPlayer().isBot();
		if (potential !is blob && blob.getTeamNum() == potential.getTeamNum()
		        && (pos2 - pos).getLength() < 600.0f
		        && (isBot || seeBehindBack || Maths::Abs(pos.x - pos2.x) < 40.0f || (blob.isFacingLeft() && pos.x > pos2.x) || (!blob.isFacingLeft() && pos.x < pos2.x))
		        && (isBot || seeThroughWalls || isVisible(blob, potential))
		        && !potential.hasTag("dead") && !potential.hasTag("migrant")
		   )
		{
			blob.set_Vec2f("last pathing pos", potential.getPosition());
			return potential;
		}
	}
	return null;
}

bool RunawayProper(CBrain@ this, CBlob@ blob, CBlob@ attacker)
{
	if (attacker is null)
		return false;

	Vec2f mypos = blob.getPosition();
	Vec2f hispos = attacker.getPosition();
	const f32 horiz_distance = Maths::Abs(hispos.x - mypos.x);

	if (hispos.x > mypos.x)
	{
		blob.setKeyPressed(key_left, true);
		blob.setAimPos(mypos + Vec2f(-10.0f, 0.0f));
	}
	else
	{
		blob.setKeyPressed(key_right, true);
		blob.setAimPos(mypos + Vec2f(10.0f, 0.0f));
	}

	if (hispos.y - getMap().tilesize > mypos.y)
	{
		blob.setKeyPressed(key_up, true);
	}

	JumpOverObstacles(blob);

	// end

	//out of sight?
	if ((mypos - hispos).getLength() > 200.0f)
	{
		return false;
	}

	return true;
}
