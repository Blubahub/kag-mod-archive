
void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);

	// minimap
	//this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	//this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	//this.SetMinimapRenderAlways(true);
	
	//this.getSprite().getConsts().accurateLighting = true;

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
}

void onTick(CBlob@ this)
{
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getName() == "humanoid"){
				b.Tag("ghost_stone");
			}
			if(b.getName() == "e"){
				b.Tag("ghost_stone");
				b.server_SetTimeToDie(30);
				if(b.getDistanceTo(this) > 60){
					Vec2f vec = this.getPosition()-b.getPosition();
					vec.Normalize();
					b.AddForce(vec);
				}
			}
			if(b.getName() == "ds" || b.getName() == "srt"){
				b.Tag("ghost_stone");
			}
		}
	}
	
	if(!getNet().isClient())return;
	
	if(this.getSprite() is null)return;
	
	if(getLocalPlayer() is null || !getLocalPlayer().hasTag("death_sight")){
		this.getSprite().SetAnimation("off");
		this.SetLight(false);
	} else {
		this.getSprite().SetAnimation("default");
		this.SetLight(true);
	}
	
	int index = this.getSprite().getFrame();
	
	if(index > 0){
		this.SetLightColor(SColor(51*index, 51*index, 51*index, 51*index));
		this.SetLightRadius(7.0f*index);
		getMap().UpdateLightingAtPosition(this.getPosition(), 7.0f*index);
	}
}