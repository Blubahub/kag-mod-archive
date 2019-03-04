// Archer animations

#include "FireParticle.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "PixelOffsets.as"
#include "RunnerTextures.as"

const f32 config_offset = -4.0f;
const string shiny_layer = "shiny bit";

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
    
  CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
    CBlob@ bop = getLocalPlayerBlob();
    CMap@ map = getMap();
		if(bop !is null &&  map.rayCastSolid(blob.getPosition() , bop.getPosition()))
    {
      this.SetVisible(false);
      return;
    }
    else
    {
      this.SetVisible(true);
    }
	}
  else
  {
    this.SetVisible(true);
  }
	
}

