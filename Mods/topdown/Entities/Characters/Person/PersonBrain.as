// Person brain

#define SERVER_ONLY

#include "Behaviour.as"
#include "PersonCommon.as"

void onInit(CBrain@ this)
{
	InitBrain(this);
	u8 strategy = Strategy::invading;
	CBlob @blob = this.getBlob();
	if(blob is null) return;
	blob.set_u8("strategy", strategy);
	Invade(blob);
}

void onTick(CBrain@ this)
{
	SearchTarget(this, false, true);

	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// logic for target

	this.getCurrentScript().tickFrequency = 1;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;

		u8 strategy = blob.get_u8("strategy");
		const bool gotarrows = hasArrows(blob);


		f32 distance;
		const bool visibleTarget = isVisible(blob, target, distance);
		if (visibleTarget)
		{
			const s32 difficulty = blob.get_s32("difficulty");
			if (( getGameTime() % 300 < 240 && distance < 360.0f))
				strategy = Strategy::attacking;
		}

		UpdateBlob(blob, target, strategy);

		// lose target if its killed (with random cooldown)

			strategy = Strategy::invading;
		if (!visibleTarget || distance > 360.0f || LoseTarget(this, target))
		{
			blob.set_bool("shooting", false);
			blob.setKeyPressed(key_down, false);
			strategy = Strategy::invading;
		}

		blob.set_u8("strategy", strategy);
	}
	if (target is null)
	{
		u8 strategy = Strategy::invading;
		blob.set_u8("strategy", strategy);
	}

	FloatInWater(blob);

	Check(this, blob);
}
void Check(CBrain@ this, CBlob@ blob)
{
	u8 strategy = blob.get_u8("strategy");
	//this.getCurrentScript().tickFrequency = 150;
	CBlob@ item = blob.getAttachments().getAttachedBlob("PICKUP");
	if(item !is null)
	{
		if(item.hasTag("gun"))
		{
			if(item.hasTag("hold"))
			{
				blob.set_string("item type", "hold");
			}

			if(item.hasTag("spam"))
			{
				blob.set_string("item type", "spam");
			}
		}
	}	

	if (strategy == Strategy::invading)
	{
		//DefaultChaseBlob(blob, target);
		Invade(blob);
		//print("yes invading in check");
	}
	/*u8 strategy = Strategy::invading;
	blob.set_u8("strategy", strategy);*/
/*
	CBlob @target = this.getTarget();
	@target = getNewTarget(this, blob, false, true);
	this.SetTarget(target);
*/
}
void UpdateBlob(CBlob@ blob, CBlob@ target, const u8 strategy)
{
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();/*
	if (strategy != Strategy::attacking)
	{
		if(blob.get_string("item type") == "hold")
		{
			blob.set_bool("shooting", true);
		}
		else if(blob.get_string("item type") == "spam")
		{
			bool shooting = true;
			blob.set_bool("shooting", false);
			if(XORRandom(100) > 98) blob.set_bool("shooting", shooting);
		}
	}	*/
	if (strategy != Strategy::attacking)
	{
		//blob.set_bool("shooting", true);
	}	
	if (strategy == Strategy::invading)
	{
		//DefaultChaseBlob(blob, target);
		Invade(blob);
	}
	else if (strategy == Strategy::retreating)
	{
		//DefaultRetreatBlob(blob, target);
	}
	else if (strategy == Strategy::attacking)
	{
		AttackBlob(blob, target);
	}
}


void AttackBlob(CBlob@ blob, CBlob @target)
{	/*
	bool shooting = (blob.get_bool("shooting"));
	if(!shooting) shooting = true;*/
	if(blob.get_string("item type") == "hold")
	{
		blob.set_bool("shooting", true);
	}
	else if(blob.get_string("item type") == "spam")
	{
		bool shooting = true;
		blob.set_bool("shooting", false);
		if(XORRandom(100) > 96) blob.set_bool("shooting", shooting);
	}
	blob.setKeyPressed(key_down, true);
	/*blob.setKeyPressed(key_left, false);
	blob.setKeyPressed(key_right, false);*/
	//blob.setKeyPressed(key_up, false);
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	const s32 difficulty = blob.get_s32("difficulty");

	//blob.setKeyPressed(key_action1, true);
	//blob.set_bool("shooting", (XORRandom(16) <= 10 ? true : false));


	JumpOverObstacles(blob);

	const u32 gametime = getGameTime();
	blob.setAimPos(targetPos);

	// fire
/*
	if (targetDistance > 25.0f)
	{
		u32 fTime = blob.get_u32("fire time");  // first shot
		bool fireTime = gametime < fTime;
		blob.setKeyPressed(key_action1, true);
/*
		if (!fireTime && (fTime == 0 || XORRandom(130 - 5.0f * difficulty) == 0))		// difficulty
		{
			const f32 vert_dist = Maths::Abs(targetPos.y - mypos.y);
			const u32 shootTime = Maths::Max(PersonParams::ready_time, Maths::Min(uint(targetDistance * (0.3f * Maths::Max(130.0f, vert_dist) / 100.0f) + XORRandom(20)), PersonParams::shoot_period));
			blob.set_u32("fire time", gametime + shootTime);
		}

		if (fireTime)
		{
			bool worthShooting;
			bool hardShot = targetDistance > 30.0f * 8.0f || target.getShape().vellen > 5.0f;
			f32 aimFactor = 0.45f - XORRandom(100) * 0.003f;
			aimFactor += (-0.2f + XORRandom(100) * 0.004f) / float(difficulty > 0 ? difficulty : 1.0f);
			blob.setAimPos(blob.getBrain().getShootAimPosition(targetPos, hardShot, worthShooting, aimFactor));
			if (worthShooting)
			{
				blob.setKeyPressed(key_action1, true);
			}
		}
	}
	else
	{
		blob.setAimPos(targetPos);
	}*/
}

