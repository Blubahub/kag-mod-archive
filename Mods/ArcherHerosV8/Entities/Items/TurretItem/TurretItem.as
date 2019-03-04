// Keg logic
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.set_u32("Reload",30);
	this.Tag("medium weight");
}

void onTick(CBlob@ this)
{
  CBlob@[] players;
	getBlobsByTag("player", @players);
	Vec2f pos = this.getPosition();
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		Vec2f pos2 = potential.getPosition();
		const bool isBot = this.getPlayer() !is null && this.getPlayer().isBot();
		if (potential !is this && this.getTeamNum() != potential.getTeamNum()
		        && (pos2 - pos).getLength() < 600.0f
		        && (isBot || isVisible(this, potential))
		        && !potential.hasTag("dead") && !potential.hasTag("migrant")
		   )
		{
			if(this.get_u32("Reload") < 1 )
      {
        ShootArrow(this, this.getPosition() + Vec2f(0.0f, -2.0f), pos2 + Vec2f(0.0f, float(XORRandom(8) -4)),  18.0f, 0, false); 
        this.set_u32("Reload",20);
      }
		}
	}
  
  if(this.get_u32("Reload") >= 1)
  {
   this.set_u32("Reload", this.get_u32("Reload") - 1);
  }
}

//sprite update
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
  if (this.exists("ownerid"))
	{
    if(byBlob.getNetworkID() == this.get_u16("ownerid") )
    {
      return true;
    }
    else 
    {
    return false;
    }
	}
  else 
  {
   this.server_Die();
  }
  return false;
}

bool isVisible(CBlob@blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolid(blob.getPosition(), target.getPosition(), col);
}

void onDie( CBlob@ this )
{

  CBlob@ turret1 = getBlobByNetworkID(this.get_u16("ownerid"));
  if(turret1 !is null) 
  {
    turret1.set_bool("made",false);
  }

}

void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const u8 arrow_type, const bool legolas = true)
{
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		CreateArrow(this, arrowPos, arrowVel, arrow_type);
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	CBlob@ arrow = server_CreateBlobNoInit("arrow");
  CBlob@ turret2 = getBlobByNetworkID(this.get_u16("ownerid"));
  
	if (arrow !is null && turret2 !is null)
	{
		// fire arrow?
		arrow.set_u8("arrow type", 0);
    arrow.set_f32("dmgmult", 1.0);
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(turret2.getPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
    arrow.set_Vec2f("start",this.getPosition());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
	}
  else if (turret2 is null) 
  {
    this.server_Die();
  }
	return arrow;
}
