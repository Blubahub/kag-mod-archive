// Princess brain

#define SERVER_ONLY
#include "Hitters.as"

#include "BrainCommon.as"

namespace AttackType
{
	enum type
	{
	attack_fire = 0,
	attack_manical,
	attack_rest
	};
};

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 8.9f;
		break;
			
	case Hitters::bomb:
		dmg = 15.0f;
		break;

	case Hitters::keg:
		dmg = 10.0f;
		break;
	case Hitters::arrow:
		dmg = 0.0f;
		break;

	case Hitters::cata_stones:
		dmg = 2.0f;
		break;

	case Hitters::sword:
		dmg *= 0.0f;
		break;
		
	default:
		dmg *= 1.0f;
		break;
	}		
	return dmg;
}

void onInit( CBrain@ this )
{
	InitBrain( this );

	this.server_SetActive( true ); // always running
	CBlob @blob = this.getBlob();
	blob.set_f32("gib health", 0.0f);

	blob.set_u8("attack stage", AttackType::attack_manical);
	blob.set_u8("attack counter", 0);
	blob.set_Vec2f("last teleport pos", Vec2f(0.0f, 10000.0f));
}

void onTick( CBrain@ this )
{
	CBlob @blob = this.getBlob();
	
	bool sawYou = blob.hasTag("saw you");
	SearchTarget( this, sawYou, true );

	CBlob @target = this.getTarget();

	// logic for target

	this.getCurrentScript().tickFrequency = 29;
	if (target !is null)
	{	
		
		this.getCurrentScript().tickFrequency = 1;

		const f32 distance = (target.getPosition() - blob.getPosition()).getLength();
		f32 visibleDistance;
		const bool visibleTarget = isVisible( blob, target, visibleDistance);
		if (visibleTarget && visibleDistance < 80.0f) 
		{
			DefaultRetreatBlob( blob, target );
		}	

		if (distance < 325.0f && visibleTarget)
		{
			if (!sawYou)
			{
				blob.getSprite().PlaySound("/EvilNotice.ogg");
				blob.setAimPos( target.getPosition() );
				blob.Tag("saw you");
			}

			u8 stage = blob.get_u8("attack stage");

			const u32 gametime = getGameTime();
			if (stage == AttackType::attack_manical) 
			{
				blob.setKeyPressed( key_action1, true );
				f32 vellen = target.getShape().vellen;
				Vec2f randomness = Vec2f( -5+XORRandom(100)*0.1f, -5+XORRandom(100)*0.1f );
				blob.setAimPos( target.getPosition() + target.getVelocity()*vellen*vellen + randomness  );
			}

			int x = gametime % 300;
			if (x < 140) {
				stage = AttackType::attack_manical;
			}
			else if (x < 190) {
				stage = visibleTarget ? AttackType::attack_manical :  AttackType::attack_manical;
			}
			else  {
				stage = AttackType::attack_manical;
			}

			blob.set_u8("attack stage", stage);

			// teleport?

			if (distance < 40.0f)
			{
				//Teleport( blob );
			}
		}

		LoseTarget( this, target );
	}
	else
	{
		RandomTurn( blob );
	}

	FloatInWater( blob ); 
} 

void Teleport( CBlob@ blob )
{
	Vec2f lastTeleport = blob.get_Vec2f("last teleport pos");
	Vec2f pos = blob.getPosition();
	Vec2f[] teleports;
	CMap@ map = getMap();
	if (map.getMarkers("necromancer teleport", teleports )) 
	{
		Vec2f nextTeleport = lastTeleport;
		f32 closestDist = 999999.9f;
		for (uint i=0; i < teleports.length; i++)
		{
			Vec2f spos = teleports[i];
			if (spos.y < lastTeleport.y)
			{
				f32 dist = ( spos - pos ).Length();
				if (dist < closestDist)
				{
					nextTeleport = spos;
					closestDist = dist;
				}
			}
		}

		if (closestDist < 9999.9f)
		{
			ParticleZombieLightning( blob.getPosition() );
			blob.set_Vec2f("last teleport pos", nextTeleport);
			blob.setPosition( nextTeleport );
			blob.setVelocity( Vec2f_zero );
			ParticleZombieLightning( nextTeleport );			
			blob.getSprite().PlaySound("/Respawn.ogg");
		}		
	}


}
