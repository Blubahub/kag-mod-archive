#include "SoldierCommon.as"
#include "ExplosionParticles.as"
#include "Skins.as"

void onInit(CSprite@ this)
{
	LoadSkin(this);

	//create the consumables layer
	{
		CSpriteLayer@ consume = this.addSpriteLayer("consume", "Sprites/actor_consumables.png", 24, 24, 0, 0);
		if (consume !is null)
		{
			consume.SetOffset(this.getOffset());

			{
				Animation@ anim = consume.addAnimation("disabled", 0, false);
				int[] frames = {0};
				anim.AddFrames(frames);
			}

			{
				Animation@ anim = consume.addAnimation("smoke_drag", 4, true);
				int[] frames = {4, 2, 2, 2, 2, 2, 4};
				anim.AddFrames(frames);
			}

			{
				Animation@ anim = consume.addAnimation("smoke_talk", 3, true);
				int[] frames = {3, 3, 4, 4, 3, 3, 3, 3, 4, 4, 4, 3, 3, 4};
				anim.AddFrames(frames);
			}

			{
				Animation@ anim = consume.addAnimation("drink_wine", 10, false);
				int[] frames =
				{
					5, 5, 6, 6, 5, 6, 6, 6, 6, 5,
					6, 6, 5, 6, 6, 6, 6, 5, 5, 5,
					7, 7
				};
				anim.AddFrames(frames);
			}

			{
				Animation@ anim = consume.addAnimation("drink_beer", 10, false);
				int[] frames =
				{
					10, 10, 11, 11, 10, 11, 11, 11, 11, 10,
					11, 11, 10, 11, 11, 11, 11, 10, 10, 10,
					12, 12
				};
				anim.AddFrames(frames);
			}

			{
				Animation@ anim = consume.addAnimation("drink_coffee", 10, false);
				int[] frames =
				{
					15, 15, 16, 16, 15, 16, 16, 16, 16, 15,
					16, 16, 15, 16, 16, 16, 16, 15, 15, 15,
					17, 17
				};
				anim.AddFrames(frames);
			}
		}
	}

	{
		Animation@ anim = this.addAnimation("stand", 0, false);
		anim.AddFrame(0);
	}
	{
		Animation@ anim = this.addAnimation("run", 3, true);
		int[] frames = {2, 3, 4, 7, 8, 9};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("jump up", 3, false);
		int[] frames = {15, 16, 17};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("jump down", 3, false);
		int[] frames = {17, 18, 19};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("crouch", 2, false);
		int[] frames = {10, 11, 12};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("stand up", 1, false);
		int[] frames = {12, 13, 10};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("slide start", 3, false);
		int[] frames = {13, 5, 6};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("slide", 3, true);
		int[] frames = {5, 6};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("die", 2, false);
		int[] frames = {20, 21, 22, 23};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("ground", 0, false);
		anim.AddFrame(14);
	}
	{
		Animation@ anim = this.addAnimation("fall up", 0, false);
		anim.AddFrame(22);
	}
	{
		Animation@ anim = this.addAnimation("fall down", 0, false);
		anim.AddFrame(24);
	}
	{
		Animation@ anim = this.addAnimation("crawl", 6, true);
		int[] frames = {14};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("bite", 3, false);
		int[] frames = {14};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("agony", 5, false);
		int[] frames = {14};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("flip", 4, false);
		int[] frames = {1};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("ladder", 0, false);
		int[] frames = {20, 21};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("smoke_drag", 4, true);
		int[] frames = {23, 22, 22, 22, 22, 22, 23};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("smoke_talk", 3, true);
		int[] frames = {22, 22, 23, 23, 22, 22, 22, 22, 23, 23, 23, 22, 22, 23};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("drink_wine", 10, false);
		int[] frames =
		{
			22, 22, 23, 23, 22, 23, 23, 23, 23, 22,
			23, 23, 22, 23, 23, 23, 23, 22, 22, 22,
			23, 23
		};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("drink_beer", 10, false);
		int[] frames =
		{
			22, 22, 23, 23, 22, 23, 23, 23, 23, 22,
			23, 23, 22, 23, 23, 23, 23, 22, 22, 22,
			23, 23
		};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("drink_coffee", 10, false);
		int[] frames =
		{
			22, 22, 23, 23, 22, 23, 23, 23, 23, 22,
			23, 23, 22, 23, 23, 23, 23, 22, 22, 22,
			23, 23
		};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("dancepose_stand", 0, false);
		int[] frames =
		{
			28
		};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("dancepose_crouch", 0, false);
		int[] frames =
		{
			29
		};
		anim.AddFrames(frames);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Soldier::Data@ data = Soldier::getData(blob);

	if (data.dead)
	{
		return;
	}

	SpecialSkinEffect(blob);

	if (data.attached)
	{
		//mask other anims and just crouch for now
		data.specialAnim = true;
		this.SetAnimation("crouch");
		return;
	}

	//find out if has cigs/booze here
	const bool still = data.vel.getLengthSquared() < 0.5f && data.onGround;
	bool smoking = false;
	bool drinking = false;
	if (still && blob.hasTag("smoking"))
	{
		smoking = true;
	}
	if (still && blob.hasTag("drinking"))
	{
		drinking = true;
	}

	data.specialAnim = smoking || drinking || (still && (data.fire || data.fire2));

	CSpriteLayer@ consume = this.getSpriteLayer("consume");

	string consume_anim = "disabled";

	if (data.specialAnim)
	{
		if (this.isAnimationEnded())
		{
			if (data.fire || data.fire2)
			{
				if (data.down)
				{
					this.SetAnimation("dancepose_crouch");
				}
				else
				{
					this.SetAnimation("dancepose_stand");
				}
			}
			else if (drinking)
			{
				if (this.isAnimation("drink_beer") ||
				        this.isAnimation("drink_wine") ||
				        this.isAnimation("drink_coffee"))
				{
					//this.PlayRandomSound("Aaaah"); //TODO: MM find some nice finished drinking sigh sounds
					blob.Untag("drinking");
				}
				else
				{
					this.PlayRandomSound("Gulp");
					u8 contents = blob.get_u8("drink_contents");
					switch (contents)
					{
						case 1: consume_anim = "drink_wine"; break;
						case 2: consume_anim = "drink_coffee"; break;
						default: consume_anim = "drink_beer"; break;
					}
					this.SetAnimation(consume_anim);
				}
			}
			else if (smoking)
			{
				if (this.isAnimation("smoke_drag"))
				{
					f32 x = data.facingLeft ? -2 : 2;
					Particles::MicroDusts(data.pos + Vec2f(x, -4), 3, data.vel + Vec2f(x, 0) * 0.2f, 1.0f);
					//this.PlaySound("SmokeCigarette");
				}

				Random _r(Time());
				string[] possible = {"drag", "talk"};
				consume_anim = "smoke_" + possible[_r.NextRanged(possible.length)];
				this.SetAnimation(consume_anim);
			}

			consume.SetAnimation(consume_anim);
		}
	}
	else
	{
		consume.SetAnimation(consume_anim);
	}


}

Random _skineffect_r(Time());

void SpecialSkinEffect(CBlob@ this)
{
	u8 skin = this.get_u8("skin");

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	int gtime = getGameTime();

	//money particles
	if (skin == SKIN_RICH_BASTARD)
	{

		if ((vel.getLengthSquared() < 1.0f && !this.isKeyPressed(key_action1)) ||
		        (gtime % 4) != 0)
		{
			return;
		}

		string file = CFileMatcher("particle_money_").getRandom();
		CParticle@ p = ParticleAnimated(file,
		                                pos + Vec2f(5.0f * (_skineffect_r.NextFloat() - 0.5f), -8.0f + -5.0f * _skineffect_r.NextFloat()),
		                                vel,
		                                0.0f,
		                                1.0f,
		                                3 + _skineffect_r.NextRanged(4), //animtime
		                                0.1f,
		                                true);

		if (p is null) return; //bail if we stop getting particles

		p.damping = 0.95f;

		p.deadeffect = 255;

		p.collides = true;
		p.diesoncollide = false;
		p.Z = (_skineffect_r.NextRanged(3) == 0) ? -1.0f : 100.0f;
		p.slide = 1.0f;
		p.bounce = 0.2f;

		p.width = 8.0f;
		p.height = 24.0f;
	}

}

