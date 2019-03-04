#define SERVER_ONLY
#include "SimpleStates.as"
#include "SimpleBrainCommon.as"
#include "PathFinding.as"
#include "SoldierCommon.as"
#include "PokerCommon.as"

void onInit( CBrain@ this )
{
	CBlob@ blob = this.getBlob();

	SimpleBrain::InitBrain( this );	

	// initialize available states
	SimpleBrain::States@ states = SimpleBrain::InitStates( blob );
}

void onTick( CBrain@ this )
{
	CRules@ rules = getRules();
	if(rules is null || !rules.isMatchRunning())
		return;

    CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();
	SimpleBrain::States@ states = SimpleBrain::getStates( blob );
	if (states is null)
		return;

	SimpleBrain::State@ previous = states.getCurrent();
	MakePossible( states );
	MakePriorities( blob, states );	
	SimpleBrain::SortStates( states );

	if (target !is this.getTarget()){
		onChangeTarget( blob, target );
	}	

	SimpleBrain::State@ current = states.getCurrent();
	if (current !is previous){
		onChangeState( blob, previous, current );
	}

	DoState( blob, states.getCurrent() );

	Soldier::Data@ data = Soldier::getData( blob );
	if (data.reactionTime < 11){
		data.reactionTime+=1;
	}
}

void MakePossible( SimpleBrain::States@ states )
{
	states.possible.clear();

	for (uint i = 0; i < states.available.length; i++)
	{
		SimpleBrain::State@ state = states.available[i];
		if (isStatePossible(state)) {
			state.priority = 0.0f;
			states.possible.push_back( state );
		}
	}
}

bool isStatePossible( SimpleBrain::State@ state  )
{
	return true;
}
 
void MakePriorities( CBlob @blob, SimpleBrain::States@ states )
{
	for (uint i = 0; i < states.possible.length; i++)
	{
		SimpleBrain::State@ state = states.possible[i];
		if (state.prioritizeFunc !is null){
			state.prioritizeFunc( blob, state );
		}
	}
}

void DoState( CBlob @blob, SimpleBrain::State@ state )
{
	if (state !is null && state.doFunc !is null){
		state.doFunc( blob, state );
	}
}

void onChangeTarget( CBlob@ blob, CBlob@ target )
{
	if (target !is null){
		blob.set_Vec2f("last pathing pos", target.getPosition() );
	}
}

void onChangeState(  CBlob@ blob, SimpleBrain::State@ previous, SimpleBrain::State@ current  )
{	
	//printf("Change state from: " + SimpleBrain::getStateString( previous ) + " to " + SimpleBrain::getStateString( current ));
	blob.getBrain().SetTarget( null );
}

 // ---- SPRITE ----

 const int LINE_HEIGHT = 10;

void onRender( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	CBrain@ brain = blob.getBrain();

	if (!brain.isActive())
		return;

	if (g_debug > 0)
	{
		GUI::SetFont("irrlicht");

		Vec2f pos = blob.getScreenPos();
		SimpleBrain::States@ states = SimpleBrain::getStates( blob );
		//SimpleBrain::SortStates( states );

		SimpleBrain::State@ current = states.getCurrent();
		for (uint i = 0; i < states.possible.length; i++)
		{
			SimpleBrain::State@ state = states.possible[i];
			GUI::DrawText( ":" + state.type + " (" + state.priority + ")", Vec2f(pos.x - 50.0f, pos.y - 90.0f + i * LINE_HEIGHT), Vec2f(pos.x + 150.0f, pos.y - 60.0f + i * LINE_HEIGHT), 
				i == 0 ? SColor(255, 90,255,90) : SColor(255, 199,199,199), false, false, false );
		}

		// nade lob
		Soldier::Data@ data = Soldier::getData( blob );
		{
			Vec2f offset = data.ai_grenadeOffset;
			const f32 grenadeRadius = 2.0f;
			Vec2f current = blob.getPosition() + Vec2f( data.direction * blob.getRadius() *0.5f, -blob.getRadius() + grenadeRadius);
			Vec2f vel = offset * 0.1f;
			const f32 len = vel.Normalize();
			vel *= Maths::Min( len, Soldier::maxThrow );	
			Vec2f col;
			CMap@ map = getMap();
			int timeout = 30;
			const f32 BOX2D_SCALE = 0.025f * 2.0f;
			while (!map.rayCastSolid( current, current + vel, col ) && timeout > 0)
			{
				GUI::DrawLine(current, current + vel, data.crosshair ? SColor(255,255,155,195) : SColor(255,225,255,195));
				current += vel;
				vel.y += BOX2D_SCALE*sv_gravity;
				timeout--;
			}
		}

		// draw high level path

		Vec2f lastPos = blob.getPosition();
		for (uint i = 0; i < brain.getHighPathSize()-1; i++)
		{
			Vec2f nextPos = brain.getHighPathPositionAtIndex(i);
			GUI::DrawArrow( lastPos, nextPos, SColor(255,245,175,95) );
			lastPos = nextPos;
		}
		//Vec2f aim = blob.getPosition() + offset;
		//GUI::DrawLine(aim, aim + Vec2f(0.0f, - 10.0f), SColor(255,225,155,85));
		//GUI::DrawLine(aim, aim + Vec2f(-10.0f, 0.0f), SColor(255,225,155,85));		
	}

}