// brain

#include "/Entities/Common/Emotes/EmotesCommon.as"

Vec2f GetClosestPlayerPos(CBlob@ this, u8 team = 255, string exception = "")
{
	Vec2f pos = this.getPosition();
	
	CBlob@[] players;
	getBlobsByTag("player", @players);
	f32 bestdist = 9999999.0f;
  f32 dist = 0.0f;
  Vec2f best = Vec2f_zero;
	for (int i = 0; i < players.length; i++)
	{
		CBlob@ theperson = players[i];
		if (team == 255 || team == theperson.getTeamNum() )
		{
      if( exception != theperson.getName())
      {
        dist = (theperson.getPosition() - this.getPosition()).getLength();
        if(dist < bestdist)
        {
          best = theperson.getPosition();
          bestdist = dist;
        }
      }
		}
  }
  return best;
}

Vec2f GetClosestHeal(CBlob@ this, u8 team = 255, string exception = "")
{
	Vec2f pos = this.getPosition();
	
	CBlob@[] players;
	getBlobsByTag("player", @players);
	f32 bestdist = 9999999.0f;
  f32 dist = 0.0f;
  Vec2f best = Vec2f_zero;
	for (int i = 0; i < players.length; i++)
	{
		CBlob@ theperson = players[i];
		if (team == 255 || team == theperson.getTeamNum() )
		{
      if( exception != theperson.getName() && theperson.getHealth() < theperson.getInitialHealth())
      {
        dist = (theperson.getPosition() - this.getPosition()).getLength();
        if(dist < bestdist)
        {
          best = theperson.getPosition();
          bestdist = dist;
        }
      }
		}
  }
  return best;
}
