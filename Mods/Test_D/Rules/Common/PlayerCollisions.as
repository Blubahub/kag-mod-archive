const f32 PLAYER_RADIUS = 8.0f;
const f32 SOME_MAGIC_NUMBER_TO_TWEAK = 18.0f;

void onTick( CRules@ this )
{
	CBlob@[] players;
	getBlobsByTag( "player", @players );
	Vec2f offset;
	CBlob@ a;
	CBlob@ b;
	f32 dist, coef;
	for (uint i=0; i < players.length; i++)
	{
		@a = players[i];	
		for (uint j=0; j < players.length; j++)
		{
			if (i != j)
			{
				@b = players[j];	
				if (a.getTeamNum() != b.getTeamNum() && a.getHealth() > 0.0f && b.getHealth() > 0.0f)
				{
					offset = b.getPosition() - a.getPosition();
					dist = offset.Normalize();
					if (dist <= PLAYER_RADIUS)
					{
						//coef = SOME_MAGIC_NUMBER_TO_TWEAK / Maths::Max(1.0f, dist);
						coef = SOME_MAGIC_NUMBER_TO_TWEAK;
						//if (Maths::Abs(a.getVelocity().x) > 0.1f)
							a.AddForce( offset*-coef );
						//if (Maths::Abs(b.getVelocity().x) > 0.1f)
							b.AddForce( offset*coef);
					}
				}
			}
		}
	}
}