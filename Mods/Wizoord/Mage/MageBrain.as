//And in the beginning, there wasn't.
/*// Bandit brain

#define SERVER_ONLY

#include "BrainCommon.as"

void onInit(CBrain@ this)
{
	InitBrain(this);
}

void onTick(CBrain@ this)
{
	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();
	CBlob@ helditem = blob.getCarriedBlob();
	if(helditem is null || !helditem.hasTag("isWeapon"))
	{
		this.getCurrentScript().tickFrequency = 29;
		return;
	}
	else if(helditem.get_u32("gun_clip") == 0)
	{
		blob.setKeyPressed(key_action1, true);
	}
	SearchTarget(this, false, true);

	

	// logic for target
	
	this.getCurrentScript().tickFrequency = 29;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;

		u8 strategy = blob.get_u8("strategy");
		
		
		{
			f32 distance;
			const bool visibleTarget = isVisible(blob, target, distance);
			const s32 difficulty = blob.get_s32("difficulty");
			const bool sentry = blob.hasTag("sentry");
			if (helditem.get_bool("gun_doReload"))
			{
				//if(sentry)
				{
					strategy = Strategy::idle;
				}
				else
				{
					strategy = Strategy::retreating;
				}
			}
			else if(distance > helditem.get_f32("gun_fireRange") || !visibleTarget)
			{
				if(sentry)
				{
					strategy = Strategy::idle;
				}
				else
				{
					strategy = Strategy::chasing;
				}
			}
			else
			{
				strategy = Strategy::attacking;
			}
		}
		if(strategy == Strategy::attacking)
		{
			blob.set_u8("timer", Maths::Min(blob.get_u8("timer") + 1, 253));
		}
		else
		{
			blob.set_u8("timer", Maths::Max(blob.get_u8("timer") - 1, 2)); //Decrease instead of instantly setting it so they'll hit you if you pop up repeatedly.
		}

		UpdateBlob(blob, target, strategy);

		// lose target if its killed (with random cooldown)

		//if (LoseTarget(this, target))
		{
			//strategy = Strategy::idle;
		}

		blob.set_u8("strategy", strategy);
	}
	else
	{
		blob.set_u8("timer", 0); //Reset timer.
		RandomTurn(blob);
	}

	FloatInWater(blob);
}

void UpdateBlob(CBlob@ blob, CBlob@ target, const u8 strategy)
{
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();
	if (strategy == Strategy::chasing)
	{
		DefaultChaseBlob(blob, target);
	}
	else if (strategy == Strategy::retreating)
	{
		DefaultRetreatBlob(blob, target);
	}
	else if (strategy == Strategy::attacking)
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

	JumpOverObstacles(blob);

	const u32 gametime = getGameTime();

	// fire
	//if (targetDistance > 10.0f)
	{
		if(!blob.exists("prevAimPos"))
		{
			blob.set_Vec2f("prevAimPos", targetPos);
		}
		Vec2f aimpos = blob.get_Vec2f("prevAimPos");
		f32 avg = (15 - difficulty);
		avg /= 2;
		targetPos = (targetPos + aimpos * avg) / (avg + 1);
		blob.set_Vec2f("prevAimPos", targetPos);
		blob.setAimPos(targetPos);
		if(blob.get_u8("timer") > (15 - difficulty) * 2)
		{
			
			blob.setKeyPressed(key_action1, true);
		}
	}
}
for(int i = 0; i < 20; i++){CBlob@ b = server_CreateBlob('bandit', -1, Vec2f(40, 150)); CBlob@ weapon = server_CreateBlob('plasmarifle', -1, Vec2f()); CBlob@ item = server_CreateBlob('weakbattery', -1, Vec2f()); b.server_Pickup(weapon);
b.server_PutInInventory(item); b.getBrain().server_SetActive(true); b.Tag("sentry");}
*/