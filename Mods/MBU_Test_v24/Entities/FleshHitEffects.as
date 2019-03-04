
#include "Hitters.as"
#include "EquipCommon.as"

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.1f && (hitterBlob !is this || customData == Hitters::crush))  //sound for anything actually painful
	{
		f32 capped_damage = Maths::Min(damage, 6.0f);

		//set this false if we whouldn't show blood effects for this hit
		bool showblood = true;

		//read customdata for hitter
		switch (customData)
		{
			case Hitters::drown:
			case Hitters::burn:
			case Hitters::fire:
				showblood = false;
				break;

			case Hitters::sword:
			case Hitters::stab:
				Sound::Play("SwordKill", this.getPosition());
				break;

			default:
				if (customData != Hitters::bite)
					Sound::Play("FleshHit.ogg", this.getPosition());
				break;
		}

		worldPoint.y -= this.getRadius() * 0.5f;

		if (showblood)
		{
			if (capped_damage >= 2.0f)
			{
				ParticleBloodSplat(worldPoint, true);
			}

			if (capped_damage > 0.25f)
			{
				for (f32 count = 0.0f ; count < capped_damage; count += 1.5f)
				{
					ParticleBloodSplat(worldPoint + getRandomVelocity(0, 0.75f + capped_damage * 2.0f * XORRandom(2), 360.0f), false);
				}
			}

			if (capped_damage > 0.01f)
			{
				f32 angle = (velocity).Angle();

				for (f32 count = 0.0f ; count < capped_damage + 1.8f; count += 0.3f)
				{
					Vec2f vel = getRandomVelocity(angle, 1.0f + 0.3f * (capped_damage/3.0f) * 0.1f * XORRandom(40), 60.0f);
					vel.y -= 1.5f * (capped_damage/3.0f);
					ParticleBlood(worldPoint, vel * -1.0f, SColor(255, 126, 0, 0));
					ParticleBlood(worldPoint, vel * 1.7f, SColor(255, 126, 0, 0));
				}
			}
		}
		
		if(getNet().isServer() && isSharp(customData))
		for (f32 count = 0.0f ; count < damage; count += 1.0f){
			if(this.get_s16("blood_amount") > 0){
				CBlob @b = server_CreateBlob("b",-1,worldPoint+Vec2f(XORRandom(11)-5,XORRandom(11)-5));
				b.setVelocity((Vec2f(XORRandom(33)-16,XORRandom(33)-16)/16.0f));
				this.sub_s16("blood_amount",1);
			}
		}
	}

	return damage;
}

