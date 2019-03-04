// Lantern script
#include "Hitters.as"
void onInit(CBlob@ this)
{
  this.set_u32("Tick",0);
  CShape@ shape = this.getShape();
  shape.SetGravityScale(0.0f);
  //shape.SetStatic(true);
  this.Tag("player");
  if(this.get_bool("Heal"))
  {
    CSprite@ sprite = this.getSprite();
    sprite.SetAnimation("heal");
  }
   
   //this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
  CSprite@ sprite = this.getSprite();
  if(this.get_u32("Tick") == 15)
    sprite.SetFrameIndex(2);
  else if(this.get_u32("Tick") == 30)
    sprite.SetFrameIndex(1);
  else if(this.get_u32("Tick") == 45)
    sprite.SetFrameIndex(0);
  else if(this.get_u32("Tick") == 60)
    sprite.SetFrameIndex(1);
  else if(this.get_u32("Tick") == 75)
    sprite.SetFrameIndex(2);
  else if(this.get_u32("Tick") == 90)
    sprite.SetFrameIndex(3);
  
  
  if(this.get_u32("Tick") == 90)
  {
    this.set_u32("Tick",0);
    CBlob@[] everyone;
    getBlobsByTag("player",@everyone);
    f32 dist = 9999999.0f;
    Vec2f wop = Vec2f_zero;
    for (uint i = 0; i < everyone.length; i++)
    {
      if(!this.get_bool("Heal") && everyone[i].getTeamNum() != this.getTeamNum() && everyone[i].hasTag("player"))
      {
        if((everyone[i].getPosition() - this.getPosition()).getLength() < dist)
        {
          wop = everyone[i].getPosition();
          dist =(everyone[i].getPosition() - this.getPosition()).getLength();
        }
      }
      else if(this.get_bool("Heal") && everyone[i].getTeamNum() == this.getTeamNum() && everyone[i].hasTag("player") && everyone[i] !is this)
      {
        if((everyone[i].getPosition() - this.getPosition()).getLength() < dist)
        {
          wop = everyone[i].getPosition();
          dist =(everyone[i].getPosition() - this.getPosition()).getLength();
        }
      }
    }
    if(wop != Vec2f_zero)
    {
      if(this.getPosition().x > wop.x)
         sprite.SetFacingLeft(true);
      else
        sprite.SetFacingLeft(false);
      //sprite.PlaySound("Shoot.ogg");
      ShootArrow(this, this.getPosition() , wop , 8.0f, 0.5f); 
    }
    
  }
  else
  {
    this.set_u32("Tick", this.get_u32("Tick") + 1);
  }
}


void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const f32 arrow_type, const f32 legolas = 0)
{
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		CreateArrow(this, arrowPos, arrowVel.RotateBy(legolas), arrow_type);
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, f32 arrowType)
{
  
  CBlob@ arrow = server_CreateBlobNoInit("bitproj");
	if (arrow !is null)
	{
		// fire arrow?
    if(this.get_bool("Heal"))
      arrow.set_string("arrow type", "snakepotheal");
    else
      arrow.set_string("arrow type", "snakepot");
    arrow.set_f32("Damage", arrowType);
    arrow.set_Vec2f("start",this.getPosition());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
    arrow.server_SetTimeToDie(5);	
	}
	return arrow;
}