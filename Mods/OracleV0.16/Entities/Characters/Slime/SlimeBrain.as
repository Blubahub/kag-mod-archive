// Knight brain

#define SERVER_ONLY

#include "BrainCommon.as"


void onInit(CBrain@ this)
{
	InitBrain(this);
	CBlob @blob = this.getBlob();
	if(!blob.exists("stuckTime")){
		blob.set_u16("stuckTime", 0);
	}
	if(!blob.exists("lastXPos")){
		blob.set_f32("lastXPos", this.getBlob().getPosition().y);
	}
	
}


void onTick(CBrain@ this)
{
	SearchTarget(this, false, true);
	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();
	//if (sv_test)
	//	return;
	//	 blob.setKeyPressed( key_action2, true );
	//	return;
	// logic for target

	this.getCurrentScript().tickFrequency = 1;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;

		u8 strategy = blob.get_u8("strategy");

		f32 distance;
		const bool visibleTarget = isVisible(blob, target, distance);
		if (visibleTarget && distance < 90.0f)
		{
			strategy = Strategy::attacking;
		}
		if (strategy == Strategy::idle)
		{
			strategy = Strategy::chasing;
		}
		else if (strategy == Strategy::chasing)
		{
      Vec2f pos = getCheckPos(blob.getPosition());
      blob.setAimPos(pos);
      blob.setKeyPressed(key_action1, true);
		}
		else if (strategy == Strategy::attacking)
		{
			if (!visibleTarget)
			{
				this.SetTarget(null);
			}
		}
		else if (strategy == Strategy::attacking)
		{
			if (distance > 120.0f)
			{
				strategy = Strategy::chasing;
			}
		}
		
		UpdateBlob(blob, target, strategy);

		// lose target if its killed (with random cooldown)
	
		if (LoseTarget(this, target) )
		{
			Vec2f pos = getCheckPos(blob.getPosition());
      blob.setAimPos(pos);
      blob.setKeyPressed(key_action1, true);
      
		}

		blob.set_u8("strategy", strategy);
	}
  else {
    Vec2f pos = getCheckPos(blob.getPosition());
     blob.setAimPos(pos);
     blob.setKeyPressed(key_action1, true);
  }
  
	FloatInWater(blob);
}

void UpdateBlob(CBlob@ blob, CBlob@ target, const u8 strategy)
{
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();
	if (strategy == Strategy::attacking)
	{
		AttackBlob(blob, target);
	}
}


void AttackBlob(CBlob@ blob, CBlob @target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	const s32 difficulty = blob.get_s32("difficulty");

	
	blob.setAimPos(targetPos);

	
    blob.setKeyPressed(key_action1, true);
  
}

