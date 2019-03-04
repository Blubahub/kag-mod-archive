#define SERVER_ONLY

#include "SimpleStates.as"
#include "SoldierCommon.as"
#include "SimpleCommonStates.as"

int _aimSeed = 0;

void onInit(CBrain@ this)
{
	CBlob@ blob = this.getBlob();
	SimpleBrain::States@ states = SimpleBrain::getStates(blob);

	states.available.push_back(SimpleBrain::State("move", Prioritize_Move, Do_Move));
	states.available.push_back(SimpleBrain::State("selfcare", Prioritize_SelfCare, Do_SelfCare));
	states.available.push_back(SimpleBrain::State("swap camo", Prioritize_SwapCamo, Do_SwapCamo));
	states.available.push_back(SimpleBrain::State("escape grenade", Prioritize_EscapeGrenade, Do_EscapeGrenade));
	states.available.push_back(SimpleBrain::State("aim", Prioritize_Aim, Do_Aim));
	SimpleBrain::SetupMoveVars(states);
}

// MOVE

void Prioritize_Move(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.5f;
	state.priority = p;
}

void Do_Move(CBlob@ blob, SimpleBrain::State@ state)
{
	SimpleBrain::GoombaMovement(blob, state);
}

// SELF_CARE
// either go to medic or wander and look for medkits

void Prioritize_SelfCare(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;

	Soldier::Data@ data;
	blob.get("data", @data);

	if(data.ammo <= 0 || data.dead)
		p += 2;

	state.priority = p;
}

void Do_SelfCare(CBlob@ blob, SimpleBrain::State@ state)
{
	if (!SimpleBrain::GoToMedkit(blob)){
		SimpleBrain::GoombaMovement(blob, state);
	}
}

// SWAP_CAMO

void Prioritize_SwapCamo(CBlob@ blob, SimpleBrain::State@ state)
{
	Random _r((getGameTime() % 3000) * (blob.getNetworkID() + 1) * 3);

	f32 p = 0.0f;
	if (_r.NextRanged(150) == 0)
	{
		p = 0.6f + _r.NextFloat(); //cant overtake "really important" stuff
	}

	state.priority = p;
}

void Do_SwapCamo(CBlob@ blob, SimpleBrain::State@ state)
{
	blob.setKeyPressed(key_action2, true);
}

// ESCAPE_GRENADE

void Prioritize_EscapeGrenade(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;
	Vec2f pos = blob.getPosition();
	CBlob@ grenade = SimpleBrain::getVisibleBlobWithTag(pos, "explosive", SimpleBrain::EXPLOSIVE_DISTANCE);
	if (grenade !is null && !grenade.getShape().isStatic())  //escape a nade if possible!
	{
		p += 10.0f;
		Soldier::Data@ data;
		blob.get("data", @data);
	}

	state.priority = p;
}

void Do_EscapeGrenade(CBlob@ blob, SimpleBrain::State@ state)
{
	SimpleBrain::EscapeExplosive(blob, state);
}

// AIM

void Prioritize_Aim(CBlob@ blob, SimpleBrain::State@ state)
{
	Vec2f pos = blob.getPosition();
	Soldier::Data@ data = Soldier::getData(blob);
	CBlob@ nearby = SimpleBrain::getVisibleEnemy(blob, SimpleBrain::SNIPER_DISTANCE);

	f32 p = 0.0f;

	if (data.crosshair)  // aiming is important
	{
		p += 5.0f;
	}

	if (nearby !is null)
	{
		p += 1.0f;
	}

	if(!data.onLadder && !data.onGround || data.fireTime - data.gametime < 45)
	{
		p -= 2.0f;
	}

	state.priority = p;
}

void Do_Aim(CBlob@ blob, SimpleBrain::State@ state)
{
	CBrain@ brain = blob.getBrain();
	CBlob @target = brain.getTarget();
	Vec2f pos = blob.getPosition();

	Soldier::Data@ data;
	blob.get("data", @data);
	bool hold = true;
	bool quit = false;

	// find enemy target if no target
	if (target is null || target.hasTag("dead"))
	{
		@target = SimpleBrain::getVisibleEnemy(blob, SimpleBrain::SNIPER_DISTANCE);
		brain.SetTarget(target);
		data.aiTimer1 = 0;
		data.aiTimer2 = 0;
		_aimSeed = Time();
	}
	else
	{
		if (data.crosshair)
		{
			u32 mintime = 13;

			Vec2f pos = blob.getPosition();
			Vec2f desiredAim = target.getPosition();
			Vec2f aim = pos + data.crosshairOffset;
			f32 difference = (desiredAim - aim).getLength();

			//time out aim if relevant
			if (!SimpleBrain::isVisible(blob, target))
			{
				if (data.aiTimer1 > 0)
					data.aiTimer1 /= 2;

				data.aiTimer2++;
				if (data.aiTimer2 > mintime * 2)
				{
					brain.SetTarget(null);
					quit = true;
				}
			}
			else
			{
				data.aiTimer2 = 0;
			}

			//check aim within tolerance (will continue aiming towards it during time)
			if ((difference <= 64.0f || data.crosshairOffset.getLength() > data.crosshairMaxDist * 0.95f))
			{
				data.aiTimer1++;
				if (data.aiTimer1 > mintime)
				{
					hold = false;
					data.aiTimer1 = 30;
				}
			}
			else
			{
				data.aiTimer1 = 0;
			}

			//do aiming with buttons
			Random _r(_aimSeed);
			Noise _nx(_r.Next());
			Noise _ny(_r.Next());
			Vec2f npos = (aim * 0.04f);
			Vec2f noise = Vec2f(_nx.Sample(npos.x, npos.y), _ny.Sample(npos.x, npos.y)) - Vec2f(0.5f, 0.5f);

			Vec2f vector = desiredAim - aim + (noise * 72.0f);
			float dist = vector.Normalize();
			if(dist > 3.0f)
			{
				if (Maths::Abs(vector.x) > 0.5f)
					blob.setKeyPressed(vector.x > 0 ? key_right : key_left, true);
				if (Maths::Abs(vector.y) > 0.5f)
					blob.setKeyPressed(vector.y > 0 ? key_down : key_up, true);
			}

		}

		blob.setKeyPressed(key_action1, hold);
		blob.setKeyPressed(key_action2, quit);

		if (!hold || quit)
		{
			data.aiTimer1 = 0;
			data.aiTimer2 = 0;
		}
	}
}
