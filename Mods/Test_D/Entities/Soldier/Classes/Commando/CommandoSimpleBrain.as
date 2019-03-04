#define SERVER_ONLY

#include "SimpleStates.as"
#include "SoldierCommon.as"
#include "SimpleCommonStates.as"

void onInit( CBrain@ this )
{
	CBlob@ blob = this.getBlob();
	SimpleBrain::States@ states = SimpleBrain::getStates( blob );

	states.available.push_back( SimpleBrain::State( "move", Prioritize_Move, Do_Move ) );
	states.available.push_back(SimpleBrain::State("selfcare", Prioritize_SelfCare, Do_SelfCare));
	states.available.push_back( SimpleBrain::State( "enemy visible", Prioritize_EnemyVisible, Do_EnemyVisible ) );
	states.available.push_back( SimpleBrain::State( "escape grenade", Prioritize_EscapeGrenade, Do_EscapeGrenade ) );
	SimpleBrain::SetupMoveVars( states );
}

// MOVE

void Prioritize_Move( CBlob@ blob, SimpleBrain::State@ state )
{
	f32 p = 0.5f;
	state.priority = p;
}

void Do_Move( CBlob@ blob, SimpleBrain::State@ state )
{
	Slash( blob );

	SimpleBrain::Vars@ move;
	state.vars.get( "movestate", @move );

	// drop from wall
	if (blob.isOnWall() && !blob.isOnGround()){
		move.onWallTime++;
		if (move.onWallTime > 30){
			move.state = SimpleBrain::RANDOM;
			return;
		}
	}
	else{
		move.onWallTime = 0;
	}

	SimpleBrain::GoombaMovement( blob, state );
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

// ENEMY_VISIBLE

void Prioritize_EnemyVisible( CBlob@ blob, SimpleBrain::State@ state )
{
	CBlob@ enemy = SimpleBrain::getVisibleEnemy( blob, SimpleBrain::VISIBLE_DISTANCE );

	f32 p = 0.0f;
	if (enemy !is null){
		p += 0.6f;
	}

	state.priority = p;
}

void Do_EnemyVisible( CBlob@ blob, SimpleBrain::State@ state )
{
	CBrain@ brain = blob.getBrain();
	CBlob @target = brain.getTarget();

	// find enemy target if no target
	if (target is null){
		@target = SimpleBrain::getVisibleEnemy( blob, SimpleBrain::VISIBLE_DISTANCE );
		brain.SetTarget( target );
	}
	else
	{
		SimpleBrain::ComplexGoTowards( blob, target.getPosition() );
	}

	Slash( blob );
}

// ESCAPE_GRENADE

void Prioritize_EscapeGrenade( CBlob@ blob, SimpleBrain::State@ state )
{
	f32 p = 0.0f;
	Vec2f pos = blob.getPosition();
	CBlob@ grenade = SimpleBrain::getVisibleBlobWithTag( pos, "explosive", SimpleBrain::EXPLOSIVE_DISTANCE );
	if (grenade !is null){
		p += 1.0f;
	}

	state.priority = p;
}

void Do_EscapeGrenade( CBlob@ blob, SimpleBrain::State@ state )
{
	SimpleBrain::EscapeExplosive( blob, state );
}

// SLASH

void Slash( CBlob@ blob )
{
	if (getGameTime() % 6 > 0) return;

	CBlob@[] players;
	getBlobsByTag( "player", @players );
	for (uint i=0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		if (potential !is blob && blob.getTeamNum() != potential.getTeamNum()
			&& (potential.getPosition() - blob.getPosition()).getLength() < 2.0f*blob.getRadius()
			)
		{
			blob.setKeyPressed( key_action1, true );
		}
	}
}
