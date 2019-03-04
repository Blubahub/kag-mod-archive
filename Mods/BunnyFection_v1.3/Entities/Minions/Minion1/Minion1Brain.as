//Minion1 brain

#define SERVER_ONLY
#include "BrainCommon.as"
#include "BF_BrainFuncs.as"
#include "RunnerCommon.as";
#include "BF_Costs.as"

f32 ENGAGE_DISTANCE = 65.0f;
const bool debug = false;

void onInit( CBrain@ this )
{
	InitBrain( this );

	this.server_SetActive( true );
	CBlob@ blob = this.getBlob();
	
	blob.Tag( "mutant" );
	blob.Tag( "flesh" );
	
	blob.set_f32("gib health", -1.0f);
	blob.set_bool( "astray", false );
	blob.set_u8( "attackTimer", 0 );

	RunnerMoveVars@ moveVars;
	if ( blob.get( "moveVars", @moveVars ) )
		moveVars.walkSpeed *= 1.4f;
}

void onTick( CBrain@ this )
{	
	CBlob @blob = this.getBlob();	
	Vec2f pos = blob.getPosition();
	bool astray = blob.get_bool( "astray" );
	CBlob @ownerBlob = !astray ? getBlobByNetworkID( blob.get_netid( "owner" ) ) : null;

	CBlob @target = this.getTarget();

	//if Target && can engage
	if ( target !is null && bf_isVisible( blob, target ) && ( pos - target.getPosition() ).Length() < ENGAGE_DISTANCE )
	{
		this.getCurrentScript().tickFrequency = 1;
		Vec2f targetPos = target.getPosition();
		
		//in hit range
		if ( ( pos - targetPos ).Length() < blob.getRadius() + target.getRadius() + 2.0f )
		{
			if ( debug ) print( "Attacking!" );
			blob.setKeyPressed( key_action1, true);//for anim

			Attack( blob, target );
		}
		else
			blob.setKeyPressed( key_action1, false);
		
		if ( debug ) print( "chasing TARGET" );
		bf_Chase( blob, target );
		if ( !bf_isVisible( blob, target ) )
			JumpOverObstacles( blob );

		
		LoseTarget( this, target );//if target dies
		
		if ( getGameTime() % 90 == 0 )//periodically consider other targets
		{
			this.SetTarget( null );
			bf_SearchTarget( this, false, true );
		}
	}
	else
	{
		if ( debug ) print( "CLEARING TARGET" );
		this.SetTarget( null );//if can't engage target clear it so it looks for another
		
		blob.setKeyPressed( key_action1, false );
		blob.set_u8( "attackTimer", 0 );
		
		//Retreat to owner if possible
		if ( ownerBlob !is null && !astray && ( ownerBlob.getPosition() - pos ).Length() < ENGAGE_DISTANCE * 2.0f )
		{
			this.getCurrentScript().tickFrequency = 1;
			if ( getGameTime() % 15 == 0 )
				bf_SearchTarget( this, false, true );//search while following owner
		
			if ( isVisible( blob, ownerBlob ) && Maths::Abs( ownerBlob.getPosition().y - pos.y ) < 12.0f )//swarm only if owner visible and on about the same height
				Swarm( blob, ownerBlob );
			else
			{
				bf_Chase( blob, ownerBlob );
				if ( !isVisible( blob, ownerBlob ) )
					JumpOverObstacles( blob );
			}
		}
		else//No target, No owner. idle looking for new ones
		{	
			this.getCurrentScript().tickFrequency = 30;
			bf_SearchTarget( this, false, true );//search while idling	

			if ( debug ) print( "NO OWNER! (astray)" );
			blob.set_bool( "astray", true );

			//look for new owner
			CBlob@[] near;
			getMap().getBlobsInRadius( pos, ENGAGE_DISTANCE, @near );
			for ( u8 i = 0; i < near.length(); i ++ )
			{
				if ( near[i].hasTag( "player" ) && blob.getTeamNum() == near[i].getTeamNum() )
				{
					blob.set_netid( "owner", near[i].getNetworkID() );
					if ( debug ) print( "NEW OWNER: " + getBlobByNetworkID( blob.get_netid( "owner" ) ).getPlayer().getUsername() );
					blob.set_bool( "astray", false );
					break;
				}
			}	
		}
	}
	
	FloatInWater( blob ); 
} 

void Attack( CBlob@ this, CBlob@ target )
{
	u8 attackTimer = this.get_u8( "attackTimer" );
	CSprite@ sprite = this.getSprite();
	this.setAimPos( target.getPosition() );

	if ( attackTimer == 17 )
	{	
		this.server_Hit( target, this.getPosition(), Vec2f_zero, DAMAGE_MINION1, 40, true );
		this.set_u8( "attackTimer", 0 );
		this.setKeyPressed( key_action1, false);//reset anim
	}
	else
		this.set_u8( "attackTimer", attackTimer + 1 );
}