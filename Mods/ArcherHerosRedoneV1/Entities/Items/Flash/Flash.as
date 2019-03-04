// Lantern script

void onInit(CBlob@ this)
{
	this.set_u32("dettime", 300);
  CShape@ shape = this.getShape();
  shape.SetGravityScale(0.0f);
}

void onTick(CBlob@ this)
{
	if (this.get_u32("dettime") == 0)
	{
    this.set_u32("dettime", 4000);
    this.server_SetTimeToDie(6);
    
	}
  else if (this.get_u32("dettime") > 300)
  {
    CBlob@ bop = getLocalPlayerBlob();
    CMap@ map = getMap();
		if(bop !is null &&  !map.rayCastSolid(this.getPosition() , bop.getPosition()))
    {
      SetScreenFlash(SColor(255,255,255,255),0.9f);
    }
  }
  else
  {
    this.set_u32("dettime", this.get_u32("dettime") - 1);
  }
}
