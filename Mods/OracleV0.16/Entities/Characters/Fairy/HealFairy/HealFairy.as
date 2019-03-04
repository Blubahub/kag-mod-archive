// Lantern script
#include "Hitters.as"
#include "BrainNess.as"
void onInit(CBlob@ this)
{
   this.set_u32("hi",2);
   CShape@ shape = this.getShape();
   shape.SetGravityScale(0.0f);
}


void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
    
  CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
    CBlob@ bop = getLocalPlayerBlob();
    if(bop !is null )
    {
      if(blob.getTeamNum() == 255 )
      {
        this.SetVisible(false);
        if(bop.getName() == "fairy")
          this.SetVisible(true);
      }
      else
      {
        this.SetVisible(true);
      }
    }
    else
      this.SetVisible(false);
    
	}
	
}

void onInit(CSprite@ this)
{
  this.SetVisible(false);
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{
  if(this.getTeamNum() < 2)
  {
    Vec2f BestPost = GetClosestHeal(this, this.getTeamNum(), "fairy");
    if(BestPost != Vec2f_zero)
    {
      Vec2f Force = Vec2f(3.0f, 0);
      Vec2f Aim = this.getPosition() - BestPost;
      Force = Force.RotateBy( Aim.Angle() );
      this.setVelocity( Vec2f(-Force.x, Force.y) );
    }
    
  }
}



void onCollision( CBlob@ this, CBlob@ blob, bool solid ) 
{
  if(blob !is null && blob.hasTag("player") && ((blob.getTeamNum() == this.getTeamNum()  && blob.getName() != "fairy")|| (blob.getName() == "fairy" && blob.getTeamNum() != this.getTeamNum() ) )) {
    if(blob.getName() == "fairy" && this.getTeamNum() > 2)
    {
      blob.set_u32("FairyCount", 1 + blob.get_u32("FairyCount"));
      this.server_Die();
    }
    else if (blob.getHealth() < blob.getInitialHealth())
    {
      blob.server_Heal(1.0f);
      this.server_Die();
    }
    
  }
}