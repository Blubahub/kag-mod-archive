#define SERVER_ONLY

#include "SimpleStates.as"
#include "SoldierCommon.as"
#include "SimpleCommonStates.as"
#include "SoldierPlace.as"

void onInit(CBrain@ this)
{
	CBlob@ blob = this.getBlob();
	SimpleBrain::States@ states = SimpleBrain::getStates(blob);

	states.available.push_back(SimpleBrain::State("move", Prioritize_Move, Do_Move));
	states.available.push_back(SimpleBrain::State("selfcare", Prioritize_SelfCare, Do_SelfCare));
	states.available.push_back(SimpleBrain::State("escape grenade", Prioritize_EscapeGrenade, Do_EscapeGrenade));
	states.available.push_back(SimpleBrain::State("heal", Prioritize_Heal, Do_Heal));
	states.available.push_back(SimpleBrain::State("give supply", Prioritize_GiveSupply, Do_GiveSupply));
	SimpleBrain::SetupMoveVars(states);
}

// MOVE

void Prioritize_Move(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;

	p += 0.5f;
	if (state.type == "heal")
	{
		p -= 0.5f;
	}

	state.priority = p;
}

void Do_Move(CBlob@ blob, SimpleBrain::State@ state)
{
	Vec2f pos = blob.getPosition();

	CBlob@ enemy = SimpleBrain::getVisibleEnemy(blob, 120);
	if (enemy !is null && enemy.getTeamNum() != blob.getTeamNum() && !enemy.hasTag("dead"))// && getGameTime() % 300 < 150)
	{
		// nothing
		if (enemy.isFacingLeft() && enemy.getPosition().x > pos.x){
			blob.setKeyPressed( key_right, true );
		}
		else if (!enemy.isFacingLeft() && enemy.getPosition().x < pos.x){
			blob.setKeyPressed( key_left, true );
		}

	}
	else {
		SimpleBrain::GoombaMovement(blob, state);
	}

	// shield

	Vec2f oldvel = blob.getOldVelocity();
	Vec2f vel = blob.getVelocity();
	if ((vel.x > 0.0f && oldvel.x <= 0.0f) || (vel.x < 0.0f && oldvel.x >= 0.0f))
	{
		// change direction
	}
	else {
		blob.setKeyPressed(key_action1, true);
	}
}

// SELF_CARE
// either go to medic or wander and look for medkits

void Prioritize_SelfCare(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;

	Soldier::Data@ data;
	blob.get("data", @data);

	if(data.dead)
		p += 2;

	state.priority = p;
}

void Do_SelfCare(CBlob@ blob, SimpleBrain::State@ state)
{
	if (!SimpleBrain::GoToMedkit(blob)){
		SimpleBrain::GoombaMovement(blob, state);
	}
}

// ESCAPE_GRENADE

void Prioritize_EscapeGrenade(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;
	Vec2f pos = blob.getPosition();
	CBlob@ grenade = SimpleBrain::getVisibleBlobWithTag(pos, "explosive", SimpleBrain::EXPLOSIVE_DISTANCE);
	if (grenade !is null && !grenade.getShape().isStatic())
	{
		p += 1.0f;
	}

	state.priority = p;
}

void Do_EscapeGrenade(CBlob@ blob, SimpleBrain::State@ state)
{
	SimpleBrain::EscapeExplosive(blob, state);

	// keep shield
	blob.setKeyPressed(key_action1, true);
}

// HEAL

void Prioritize_Heal(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;

	CBlob@[] players;
	getBlobsByTag("player", @players);
	Vec2f pos = blob.getPosition();
	CBlob@[] sorted;
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		if (potential !is blob
		        && ((pos - potential.getPosition()).getLength() < SimpleBrain::VISIBLE_DISTANCE
		            //&& SimpleBrain::isVisible(blob, potential)
		            )
		   )
		{
			if (blob.getTeamNum() == potential.getTeamNum()) // friend in need
			{
				if (potential.hasTag("dead"))
				{
					p += 1.0f;
				}
				if (potential.getHealth() < potential.getInitialHealth())
				{
					p += 0.55f;
				}
			}
			else   // enemy
			{
				p -= 0.5f;
			}
		}
	}

	state.priority = p;
}

void Do_Heal(CBlob@ blob, SimpleBrain::State@ state)
{
	// go to wounded

	CBlob@[] players;
	getBlobsByTag("player", @players);
	Vec2f pos = blob.getPosition();
	CBlob@[] sorted;
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		if (potential !is blob
		        && ((pos - potential.getPosition()).getLength() < SimpleBrain::VISIBLE_DISTANCE)
		      //  && SimpleBrain::isVisible(blob, potential)
		        && blob.getTeamNum() == potential.getTeamNum() && potential.getHealth() < potential.getInitialHealth()
		   )
		{
			sorted.push_back(potential);
		}
	}

	if (sorted.length > 0)
	{
		SimpleBrain::JustGo(blob, SimpleBrain::getClosestBlobFromArray(pos, @sorted));
	}

	// shield

	blob.setKeyPressed(key_action1, true);
}

// SUPPLY

void Prioritize_GiveSupply(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;

	if (blob.getTickSinceCreated() < 300 || getItemCount(blob, "supply") == 0)
	{
		state.priority = p;
		return;
	}

	Vec2f pos = blob.getPosition();
	CBlob@[] blobs;
	getMap().getBlobsInRadius(pos, SimpleBrain::VISIBLE_DISTANCE, @blobs);
	bool teamMember = false;

	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ potential = blobs[i];
		if (potential !is blob)
		{
			if (potential.getName() == "supply")
			{
				p -= 0.5f;
			}
			else if (blob.getTeamNum() == potential.getTeamNum() && potential.getName() == "soldier")
			{
				teamMember = true;
			}
		}
	}
	if (teamMember)
	{
		p += 0.75f;
	}

	state.priority = p;
}

void Do_GiveSupply(CBlob@ blob, SimpleBrain::State@ state)
{
// 	Vec2f pos = blob.getPosition();
// 	CBlob@[] blobs;
// 	getMap().getBlobsInRadius( pos, SimpleBrain::VISIBLE_DISTANCE, @blobs );
// 	for (uint i = 0; i < blobs.length; i++)
// 	{
// 		CBlob@ potential = blobs[i];
// 		if (potential.getName() == "supply"){
// 			printf("not supply");
// 			return;
// 		}
// 	}

// printf("suppply");
	blob.setKeyPressed(key_action1, false);
	blob.setKeyPressed(key_action2, true);
}
