// Lantern script
#include "Hitters.as"
void onInit(CBlob@ this)
{
   this.set_u32("hi",2);
   CShape@ shape = this.getShape();
   shape.SetGravityScale(0.0f);
}