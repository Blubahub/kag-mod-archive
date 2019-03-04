// Bomb logic

#include "Hitters.as";
#include "BombCommon.as";
#include "ShieldCommon.as";


void onInit(CBlob@ this)
{
this.set_u32("timer",10);
this.Sync("timer",true);
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{
  if(this.get_u32("timer") >= 1)
  {
   this.set_u32("timer", this.get_u32("timer") - 1);
  }
    CBlob@ turret1 = getBlobByNetworkID(this.get_u16("ownerid"));
    if(turret1 !is null && turret1.isKeyJustPressed(key_action2) && this.get_u32("timer") == 0) 
    {
      turret1.setPosition(this.getPosition());
      turret1.set_bool("made",false);
      this.server_Die();
    }
  
  
}

