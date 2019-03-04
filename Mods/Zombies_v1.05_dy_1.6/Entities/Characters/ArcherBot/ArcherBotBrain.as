// Archer brain

#define SERVER_ONLY

#include "BrainBotCommon.as"
#include "ArcherCommon.as"

void onInit( CBrain@ this )
{
	InitBrain( this );
	this.getBlob().set_s32("difficulty", 15);
	GiveAmmo(this.getBlob());
	this.server_SetActive( true );
}

void GiveAmmo( CBlob@ blob )
{
	if (blob.getName() == "archer_bot") // I know its shitty I was lazy
	{
		CBlob@ mat1 = server_CreateBlob( "mat_arrows" );
		CBlob@ mat2 = server_CreateBlob( "mat_arrows" );
		CBlob@ mat3 = server_CreateBlob( "mat_arrows" );
		CBlob@ mat4 = server_CreateBlob( "mat_arrows" );
		CBlob@ mat5 = server_CreateBlob( "mat_arrows" );
		CBlob@ mat6 = server_CreateBlob( "mat_arrows" );
		CBlob@ mat7 = server_CreateBlob( "mat_arrows" );
		CBlob@ mat8 = server_CreateBlob( "mat_arrows" );
		if (mat1 !is null) blob.server_PutInInventory(mat1);
		if (mat2 !is null)	blob.server_PutInInventory(mat2);
		if (mat3 !is null)	blob.server_PutInInventory(mat3);
		if (mat4 !is null)	blob.server_PutInInventory(mat4);
		if (mat5 !is null)	blob.server_PutInInventory(mat5);
		if (mat6 !is null)	blob.server_PutInInventory(mat6);
		if (mat7 !is null)	blob.server_PutInInventory(mat7);
		if (mat8 !is null)	blob.server_PutInInventory(mat8);
	}
}
void onTick( CBrain@ this )
{
	SearchTarget( this, false, true );

    CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// logic for target
								   	
	this.getCurrentScript().tickFrequency = 29;
    if (target !is null)
    {			
		this.getCurrentScript().tickFrequency = 1;

		u8 strategy = blob.get_u8("strategy");
		bool standground = blob.get_bool("standground");
		const bool gotarrows = hasArrows( blob );
		if (!gotarrows) {
			if (XORRandom(300)==0)
			blob.Chat("I have no arrows! Give me more!");
			strategy = Strategy::idle;
		}

		f32 distance;
		const bool visibleTarget = isVisible( blob, target, distance);
		if (visibleTarget) 
		{
			const s32 difficulty = blob.get_s32("difficulty");
			if (!standground && (!blob.isKeyPressed( key_action1 ) && getGameTime() % 300 < 240 && distance < 30.0f + 3.0f*difficulty) || !gotarrows)						 
				{
					strategy = Strategy::retreating; 
				}
			else
				if (gotarrows) {
					strategy = Strategy::attacking; 
				}

			
		}
		else
		{
			//if (distance > 40.0f)
			//strategy = Strategy::chasing;
			//else
			strategy = Strategy::idle;
		}
		

		if (standground &&  distance > (blob.getRadius()+10.0f) && getGameTime() % 200 == 0) 
		{

			@target = null;
			this.SetTarget( target );
			SearchTarget( this, true, true );
			@target = this.getTarget();
			f32 distance2;
			if (target !is null)
			{
				const bool visibleTarget2 = isVisible( blob, target, distance2);
				if (gotarrows && visibleTarget2 || gotarrows && XORRandom(10)==0) {
					strategy = Strategy::attacking; 
				}
				else
				strategy = Strategy::idle;
				UpdateBlob( blob, target, strategy ); 
			}
		}
		else
		{
			UpdateBlob( blob, target, strategy ); 

	        // lose target if its killed (with random cooldown)

			if (LoseTarget( this, target )) {
				strategy = Strategy::idle;
			}
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
		DefaultChaseBlob( blob, target );		
	}
	else if ( strategy == Strategy::retreating ) {		
		DefaultRetreatBlob( blob, target );		
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

	if (targetDistance > 0.0f)
	{
		u32 fTime = blob.get_u32( "fire time"); // first shot
		bool fireTime = gametime < fTime;

		if (!fireTime && (fTime == 0 || XORRandom(130 - 5.0f*difficulty) == 0))		// difficulty
		{
			const f32 vert_dist = Maths::Abs(targetPos.y - mypos.y);
			const u32 shootTime = Maths::Max( ArcherParams::ready_time, Maths::Min(uint(targetDistance*(0.3f*Maths::Max(130.0f,vert_dist)/100.0f)+XORRandom(20)), ArcherParams::shoot_period ) );
			blob.set_u32( "fire time", gametime + shootTime );
		}

		if (fireTime)
		{				
			bool worthShooting;
			bool hardShot = targetDistance > 30.0f*8.0f || target.getShape().vellen > 5.0f;
			f32 aimFactor = 0.45f-XORRandom(100)*0.003f;
			aimFactor += (-0.2f + XORRandom(100)*0.004f) / float(difficulty > 0 ? difficulty : 1.0f);
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

