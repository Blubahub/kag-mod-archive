// Archer brain

#define SERVER_ONLY

#include "BrainCommon.as"
#include "archerTurretCommon.as"

void onInit( CBrain@ this )
{
	InitBrain( this );
}

void onTick( CBrain@ this )
{
	SearchTarget( this, true, true );

    CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// logic for target
								   	
	this.getCurrentScript().tickFrequency = 29;
    if (target !is null)
    {			
		this.getCurrentScript().tickFrequency = 1;

		u8 strategy = blob.get_u8("strategy");
		const bool gotarrows = hasArrows( blob );
		if (!gotarrows) {
			strategy = Strategy::idle;
		}

		f32 distance;
		const bool visibleTarget = isVisible( blob, target, distance);
		
			const s32 difficulty = blob.get_s32("difficulty");
			if ((!blob.isKeyPressed( key_action1 ) && distance < 60.0f + 3.0f*difficulty) || !gotarrows)						  // BASE ON DIFFICULTY			 
				strategy = Strategy::retreating; 
			else
				if (gotarrows) {
					strategy = Strategy::attacking; 
				}
		
					   		
		UpdateBlob( blob, target, strategy ); 

        // lose target if its killed (with random cooldown)

		if (LoseTarget( this, target )) {
			strategy = Strategy::idle;
		}

		blob.set_u8("strategy", strategy);	  
    }
	else
	{
		RandomTurn( blob );
	}

	FloatInWater( blob );
}

void UpdateBlob( CBlob@ blob, CBlob@ target, const u8 strategy )
{
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();
	if ( strategy == Strategy::chasing ) {
		AttackBlob( blob, target );		
	}
	else if ( strategy == Strategy::retreating ) {		
		AttackBlob( blob, target );	
	}
	else if ( strategy == Strategy::attacking )	{		
		AttackBlob( blob, target );
	}
}

	 
void AttackBlob( CBlob@ blob, CBlob @target )
{
    Vec2f mypos = blob.getPosition();
    Vec2f targetPos = target.getPosition();
    Vec2f targetVector = targetPos - mypos;
    f32 targetDistance = targetVector.Length();
	const s32 difficulty = blob.get_s32("difficulty");

	JumpOverObstacles(blob);

	const u32 gametime = getGameTime();		 
		   
	// fire
	if (targetDistance > 5.0f)
	{
		bool fireTime = gametime < blob.get_u32( "fire time");

		if (!fireTime && XORRandom(150 - 5.0f*difficulty) == 0)		// difficulty
		{
			const f32 vert_dist = Maths::Abs(targetPos.y - mypos.y);
			const u32 shootTime = Maths::Max( ArcherParams::ready_time, Maths::Min(uint(targetDistance*(0.3f*Maths::Max(130.0f,vert_dist)/100.0f)+XORRandom(20)), ArcherParams::shoot_period ) );
			blob.set_u32( "fire time", gametime + shootTime );
		}

		if (fireTime)
		{				
			bool worthShooting;
			bool hardShot = targetDistance > 1.0f || target.getShape().vellen > 5.0f;
			f32 aimFactor = 0.45f-XORRandom(100)*0.003f;
			aimFactor += (-0.2f + XORRandom(100)*0.003f) / float(difficulty > 0 ? difficulty : 15.0f);
			blob.setAimPos( blob.getBrain().getShootAimPosition( targetPos, hardShot, worthShooting, aimFactor ) );
			if (worthShooting)
			{
				blob.setKeyPressed( key_action1, true );
			}
		}
	}
	else
	{
		blob.setAimPos( targetPos );
	}
}

