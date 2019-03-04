
void onInit(CSprite @this){
	this.SetZ(1000.0f);
	
	
	
	{
		CSpriteLayer@ ring = this.addSpriteLayer("ring1", "ring_diag.png" , 96, 96, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ring !is null)
		{
			Animation@ anim = ring.addAnimation("default", 0, false);
			anim.AddFrame(0);
			ring.SetRelativeZ(2.0f);
		}
	}
	{
		CSpriteLayer@ ring = this.addSpriteLayer("ring2", "ring_hori.png" , 96, 96, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ring !is null)
		{
			Animation@ anim = ring.addAnimation("default", 0, false);
			anim.AddFrame(0);
			ring.SetRelativeZ(3.0f);
		}
	}
	{
		CSpriteLayer@ ring = this.addSpriteLayer("ring3", "ring_vert.png" , 96, 96, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ring !is null)
		{
			Animation@ anim = ring.addAnimation("default", 0, false);
			anim.AddFrame(0);
			ring.SetRelativeZ(4.0f);
		}
	}
	
	{
		CSpriteLayer@ ring = this.addSpriteLayer("ring_pulse1", "ring_diag_pulse.png" , 96, 96, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ring !is null)
		{
			Animation@ anim = ring.addAnimation("default", 3, true);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
			anim.AddFrame(4);
			anim.AddFrame(5);
			anim.AddFrame(6);
			anim.AddFrame(6);
			anim.AddFrame(6);
			anim.AddFrame(6);
			ring.SetRelativeZ(2.5f);
		}
	}
	
	{
		CSpriteLayer@ ring = this.addSpriteLayer("ring_pulse2", "ring_hori_pulse.png" , 96, 96, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ring !is null)
		{
			Animation@ anim = ring.addAnimation("default", 3, true);
			anim.AddFrame(3);
			anim.AddFrame(4);
			anim.AddFrame(5);
			anim.AddFrame(6);
			anim.AddFrame(6);
			anim.AddFrame(6);
			anim.AddFrame(6);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			ring.SetRelativeZ(3.5f);
		}
	}
	
	{
		CSpriteLayer@ ring = this.addSpriteLayer("ring_pulse3", "ring_vert_pulse.png" , 96, 96, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ring !is null)
		{
			Animation@ anim = ring.addAnimation("default", 3, true);
			anim.AddFrame(6);
			anim.AddFrame(6);
			anim.AddFrame(6);
			anim.AddFrame(6);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
			anim.AddFrame(4);
			anim.AddFrame(5);
			ring.SetRelativeZ(4.5f);
		}
	}
	
	this.RemoveSpriteLayer("smite");
	CSpriteLayer@ smite = this.addSpriteLayer("smite", "lsm.png", 16, 96);
	if(smite !is null)
	{
		Animation@ anim = smite.addAnimation("default", 0, false);
		anim.AddFrame(0);
		smite.SetRelativeZ(-2000.0f);
		smite.SetVisible(false);
		smite.setRenderStyle(RenderStyle::additive);
		smite.SetInterpolated(false);
	}
	
	this.RemoveSpriteLayer("smite_end");
	CSpriteLayer@ smite_end = this.addSpriteLayer("smite_end", "lsme.png", 43, 96);
	if(smite_end !is null)
	{
		Animation@ anim = smite_end.addAnimation("default", 0, false);
		anim.AddFrame(0);
		smite_end.SetRelativeZ(-2000.0f);
		smite_end.SetVisible(false);
		smite_end.setRenderStyle(RenderStyle::additive);
		smite_end.SetInterpolated(false);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.SetZ(1000.0f);
	
	for(int i = 0;i < this.getSpriteLayerCount();i++){
		string name = this.getSpriteLayer(i).name;
		if(name != "bubble"){
			this.getSpriteLayer(i).setRenderStyle(RenderStyle::light);
			if(name == "ring1")this.getSpriteLayer(i).SetRelativeZ(3.0f);
			if(name == "ring2")this.getSpriteLayer(i).SetRelativeZ(4.0f);
			if(name == "ring3")this.getSpriteLayer(i).SetRelativeZ(5.0f);
			if(name == "ring_pulse1")this.getSpriteLayer(i).SetRelativeZ(3.5f);
			if(name == "ring_pulse2")this.getSpriteLayer(i).SetRelativeZ(4.5f);
			if(name == "ring_pulse3")this.getSpriteLayer(i).SetRelativeZ(5.5f);
		}
	}
	
	
}