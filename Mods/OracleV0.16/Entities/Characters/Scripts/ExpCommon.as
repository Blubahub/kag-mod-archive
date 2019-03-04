//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.
#include "ProfilesCommon.as"; //Movement scripts.


void setStuffByBlobName(PlayerProfile@ pro, CBlob@ this)
{
  this.set_u32("Exp", pro.GrabChar(this.getName())); 
  this.Sync("Exp",true);
  getLeaderboard(pro, this);
}

void setProfileByBlobName(CBlob@ this)
{
   CPlayer@ p = this.getPlayer();
   if( p !is null)
   {
      PlayerProfile@ pro =  server_getProfileByName(p.getUsername());
      if (pro !is null)
      {
        print( p.getUsername() + " got " + this.get_u32("Exp") + " in " + this.getName());
        pro.SaveChar(this.getName(),this.get_u32("Exp"));
        pro.CheckLeaderboard(this.getName(), this.get_u32("Exp"));
        setStuffByBlobName(pro, this);
      }
    
   }
}

void getLeaderboard(PlayerProfile@ pro, CBlob@ this)
{
   this.set_string("BestGuy",pro.GetLeaderboardName(this.getName(),1));
   this.set_u32("BestLevel",Maths::Floor(float(pro.GetLeaderboardLevel(this.getName(),1))/float(10)));
   
   this.Sync("BestGuy",true);
   this.Sync("BestLevel",true);
}

