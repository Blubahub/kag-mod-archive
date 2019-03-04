#include "BrainCommon.as"
#include "Hitters.as";
#include "RunnerCommon.as";

void onTick(CBrain@ this)
{
	if (!getNet().isServer()) 
    return;
	
	CBlob@ blob = this.getBlob();
	CBlob@ target = this.getTarget();

	if (target is null)
	{
		Vec2f pos = blob.getPosition();
	
		CBlob@[] players;
		getBlobsByTag("player", @players);
		
		for (int i = 0; i < players.length; i++)
		{
			CBlob@ theperson = players[i];
			if (theperson.getTeamNum() != blob.getTeamNum() && !theperson.hasTag("dead") )
			{
				this.SetTarget(theperson);
				
				break;
			}
		}
	}
	
	if (target !is null)
	{	

    if (getGameTime() % 45 == 0) this.SetPathTo(target.getPosition(), 2);

    if((target.getPosition() - blob.getPosition()).getLength() < 40.0f)
    {
      Press(this,blob,target.getPosition());
    }
    else 
      Press(this, blob, this.getNextPathPosition());
    
    
    
		
		

		if (target.hasTag("dead")) 
		{
			this.SetTarget(null);
			return;
		}
	}
} 

void Press(CBrain@ this, CBlob@ blob, Vec2f pos)
{
	Vec2f relative =  blob.getPosition() - pos;

	blob.setKeyPressed(key_left, relative.x > 0);
	blob.setKeyPressed(key_right, relative.x < 0);
	blob.setKeyPressed(key_up, relative.y > 0);
	blob.setKeyPressed(key_down, relative.y < 0);
}