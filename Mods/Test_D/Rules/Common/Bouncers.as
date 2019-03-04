#include "SoldierCommon.as"

const f32 PUSH_FORCE = 3.0f;

int _waitChat = 0;

Random _r(Time());

void onTick(CRules@ this)
{
	CBlob@[] bouncers;
	getBlobsByTag("bouncer", @bouncers);
	CBlob@[] players;
	getBlobsByTag("player", @players);

	const int cost = this.get_u32("vip_entry_cost");

	for (uint bIt = 0; bIt < bouncers.length; bIt++)
	{
		CBlob@ bouncer = bouncers[bIt];

		if (bouncer.isOnGround() && !bouncer.exists("land pos"))
		{
			bouncer.set_Vec2f("land pos", bouncer.getPosition());
		}
		else if (bouncer.exists("land pos"))
		{
			bouncer.setPosition(bouncer.get_Vec2f("land pos"));
			CSprite@ sprite = bouncer.getSprite();
			if (sprite !is null)
			{
				sprite.SetOffset(Vec2f(0, -8));
			}
		}

		//force it here
		bouncer.SetFacingLeft(bouncer.hasTag("face left"));

		for (uint pIt = 0; pIt < players.length; pIt++)
		{
			CBlob@ blob = players[pIt];

			if(blob.hasTag("bouncer"))
				continue;

			Soldier::Data@ data = Soldier::getData(blob);
			CPlayer@ player = blob.getPlayer();
			bool broke = true;
			if (player !is null)
			{
				u32 coins = player.getCoins();
				broke = coins < cost && !sv_test;
			}

			Vec2f offset = (blob.getPosition() - bouncer.getPosition());
			if (offset.Length() < 24.0f && Maths::Abs(offset.x) < 4.0f)
			{
				string entrywarning = "Entry with " + (cost == 0 ? "free" : (cost + " coin" + (cost == 1 ? "" : "s")));
				string chat = "";
				bool warmup = this.isWarmup();

				if (broke || warmup)
				{
					f32 sign = bouncer.isFacingLeft() ? -1.0f : 1.0f;
					if (warmup)
					{
						if ((bouncer.getPosition().x < data.pos.x && sign < 0.0f) ||
						        (bouncer.getPosition().x > data.pos.x && sign > 0.0f))
						{
							sign *= -1.0;
						}
					}
					blob.setVelocity(Vec2f(sign * PUSH_FORCE, -2.0f));
					blob.setPosition(blob.getPosition() + Vec2f(sign * bouncer.getRadius(), -2));
					blob.getSprite().PlaySound("Slap");

					if (data !is null)
					{
						data.stunTime = 45.0f;
					}

					if (warmup)
					{

					}
					else if (broke)
					{
						chat = (_r.NextRanged(2) == 0 ?
						        "Sorry buddy" :
						        entrywarning);
					}
					//(shouldn't happen, but just to ensure if more cases are added something is always said)
					else
					{
						chat = "Sorry buddy";
					}
				}
				else if (!blob.hasTag("costwarned"))
				{
					chat = entrywarning;
					blob.Tag("costwarned");
				}
				else
					//if (!blob.isChatBubbleVisible()){
					if (getGameTime() - _waitChat > 60)
					{
						chat = (_r.NextRanged(2) == 0 ?
						        "Enjoy your time" :
						        "Welcome");
					}

				//only warn the actual player (avoid spam)
				if (chat != "" && blob.isMyPlayer())
				{
					bouncer.Chat(chat);
					_waitChat = getGameTime();
				}
			}

		}
	}

}
