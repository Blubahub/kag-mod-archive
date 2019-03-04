
void onInit(CBlob@ this)
{
	int cb_id = Render::addBlobScript(Render::layer_objects, this, "IceFreeze.as", "StartRender");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return true;
}

void onTick(CBlob@ this)
{

}
