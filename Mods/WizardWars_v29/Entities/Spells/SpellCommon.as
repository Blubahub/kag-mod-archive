//Spells Common
#include "MagicCommon.as";
#include "Hitters.as";

void Heal( CBlob@ blob, f32 healAmount )
{
	f32 health = blob.getHealth();
	f32 initHealth = blob.getInitialHealth();
	
	if ( (health + healAmount) > initHealth )
		blob.server_SetHealth(initHealth);
	else
		blob.server_SetHealth(health + healAmount);
		
    if (blob.isMyPlayer())
    {
        SetScreenFlash( 100, 0, 225, 0 );
    }
		
	blob.getSprite().PlaySound("Heal.ogg", 0.8f, 1.0f + XORRandom(1)/10.0f);
	makeHealParticles(blob);
}

void makeHealParticles(CBlob@ this, const f32 velocity = 1.0f, const int smallparticles = 12, const bool sound = true)
{

	//makeSmokeParticle(this, Vec2f(), "Smoke");
	for (int i = 0; i < smallparticles; i++)
	{
		f32 randomness = (XORRandom(32) + 32)*0.015625f * 0.5f + 0.75f;
		Vec2f vel = getRandomVelocity( -90, velocity * randomness, 360.0f );
		
		if(getNet().isClient())
		{
			const f32 rad = 12.0f;
			Vec2f random = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
			CParticle@ p = ParticleAnimated( "MissileFire3.png", this.getPosition() + random, Vec2f(0,0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), 0.0f, false );
			if ( p !is null)
			{
				if ( XORRandom(2) == 0 )
					p.Z = 10.0f;
				else
					p.Z = -10.0f;
			}
		}
	}
}

void Revive( CBlob@ blob )
{			
	int playerId = blob.get_u16( "owner_player" );
	CPlayer@ deadPlayer = getPlayerByNetworkId( playerId );
	
	if( deadPlayer !is null )
	{
		CBlob @newBlob = server_CreateBlob( "wizard", deadPlayer.getTeamNum(), blob.getPosition() );		
		if( newBlob !is null )
		{
			f32 health = newBlob.getHealth();
			f32 initHealth = newBlob.getInitialHealth();
	
			newBlob.server_SetPlayer( deadPlayer );
			newBlob.server_SetHealth( initHealth*0.2f );
			
			ManaInfo@ manaInfo;
			if ( newBlob.get( "manaInfo", @manaInfo ) ) 
			{
				manaInfo.mana = 0;
			}			
			
			makeReviveParticles(newBlob);
			
			blob.server_Die();
		}
	}
		
	blob.getSprite().PlaySound("Revive.ogg", 0.8f, 1.0f);
	makeReviveParticles(blob);
}

void makeReviveParticles(CBlob@ this, const f32 velocity = 1.0f, const int smallparticles = 12, const bool sound = true)
{

	//makeSmokeParticle(this, Vec2f(), "Smoke");
	for (int i = 0; i < smallparticles; i++)
	{
		f32 randomness = (XORRandom(32) + 32)*0.015625f * 0.5f + 0.75f;
		Vec2f vel = getRandomVelocity( -90, velocity * randomness, 360.0f );
		
		if(getNet().isClient())
		{
			const f32 rad = 12.0f;
			Vec2f random = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
			CParticle@ p = ParticleAnimated( "MissileFire4.png", this.getPosition() + random, Vec2f(0,0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), 0.0f, false );
			if ( p !is null)
			{
				if ( XORRandom(2) == 0 )
					p.Z = 10.0f;
				else
					p.Z = -10.0f;
			}
		}
	}
}

void counterSpell( CBlob@ blob )
{		
	CMap@ map = blob.getMap();
	
	if (map is null)
		return;

	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius(blob.getPosition(), 64.0f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is null)
			{
				bool sameTeam = b.getTeamNum() == blob.getTeamNum();
			
				bool countered = false;
				if ( b.hasTag("counterable") && !sameTeam )
				{					
					b.server_Die();
					
					countered = true;
				}
				else if ( b.get_u16("slowed") > 0 && sameTeam )
				{				
					b.set_u16("slowed", 2);
					b.Sync("slowed", true);
					
					countered = true;
				}
				else if ( b.get_u16("hastened") > 0 && !sameTeam )
				{			
					b.set_u16("hastened", 2);
					b.Sync("hastened", true);
					
					countered = true;
				}
				else if ( b.hasTag("zombie") && !sameTeam )
				{					
					blob.server_Hit(b, blob.getPosition(), Vec2f(0, 0), 4.0f, Hitters::fire, true);
					
					countered = true;
				}
				
				if ( countered == true )
				{
					Vec2f bPos = b.getPosition();
					CParticle@ p = ParticleAnimated( "Flash2.png",
									bPos,
									Vec2f(0,0),
									0,
									1.0f, 
									8, 
									0.0f, true ); 	
									
					if ( p !is null)
					{
						p.Z = 600.0f;
					}
				}
			}
		}
	}
	
	CParticle@ p = ParticleAnimated( "Shockwave2.png",
					blob.getPosition(),
					Vec2f(0,0),
					float(XORRandom(360)),
					1.0f, 
					2, 
					0.0f, true );    
	if ( p !is null)
	{
		p.Z = -10.0f;
	}
		
	blob.getSprite().PlaySound("CounterSpell.ogg", 0.8f, 1.0f);
}

void Slow( CBlob@ blob, u16 slowTime )
{	
	if ( blob.get_u16("hastened") > 0 )
	{
		blob.set_u16("hastened", 2);
		blob.Sync("hastened", true);
	}
	else
	{
		blob.set_u16("slowed", slowTime);
		blob.Sync("slowed", true);
		blob.getSprite().PlaySound("SlowOn.ogg", 0.8f, 1.0f + XORRandom(1)/10.0f);
	}
}

void Haste( CBlob@ blob, u16 hasteTime )
{	
	if ( blob.get_u16("slowed") > 0 )
	{
		blob.set_u16("slowed", 2);
		blob.Sync("slowed", true);
	}
	else
	{
		blob.set_u16("hastened", hasteTime);
		blob.Sync("hastened", true);
		blob.getSprite().PlaySound("HasteOn.ogg", 0.8f, 1.0f + XORRandom(1)/10.0f);
	}
}
