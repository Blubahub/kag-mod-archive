void onTick(CBlob@ this)
{
	int Height =32;
	CMap@ map = this.getMap();
	CSprite @spr = this.getSprite();
	Vec2f surfacepos;
	if(this.get_s16("life_amount") > 0){
		if(map.rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,Height), surfacepos) || (this.getPosition()+Vec2f(0,Height)).y > getMap().tilemapheight*8){
			this.AddForce(Vec2f(0, -Maths::Min((this.get_s16("life_amount")*4.0f),0.45f*this.getMass())));
		}
		
		if(spr !is null){
		
			CSpriteLayer @layer = spr.getSpriteLayer("life_shine");
			
			if(layer !is null){
			
				layer.RotateBy(5, Vec2f(0,0));
			
			} else {
			
				@layer = spr.addSpriteLayer("life_shine", "ff.png", 24, 24);
			
				if(layer !is null){
					
					Animation@ anim = layer.addAnimation("default", 0, false);
					anim.AddFrame(0);
					layer.setRenderStyle(RenderStyle::light);
					layer.SetRelativeZ(-40.0f);
				
				}
			
			}
		
		}
		
		if(this.getLightRadius() == 64.0f){
			this.SetLightColor(SColor(11, 213, 255, 171));
			this.SetLightRadius(12.0f);
		}
		
		if(this.getLightColor() == SColor(11, 213, 255, 171))this.SetLight(true);
	} else {
		if(spr.getSpriteLayer("life_shine") !is null)spr.RemoveSpriteLayer("life_shine");
		
		if(this.getLightColor() == SColor(11, 213, 255, 171))this.SetLight(false);
	}
	
	
	
	if(this.getPlayer() !is null){
	
		CControls @control = this.getPlayer().getControls();
	
		if(control.ActionKeyPressed(AK_MOVE_LEFT)){
			
			this.setVelocity(this.getVelocity()+Vec2f(-0.25f,0));
		}
		
		if(control.ActionKeyPressed(AK_MOVE_RIGHT)){
			
			this.setVelocity(this.getVelocity()+Vec2f(0.25f,0));
		}
		
		if(control.ActionKeyPressed(AK_MOVE_UP)){
			
			this.setVelocity(this.getVelocity()+Vec2f(0,-0.25f));
		}
		
		if(control.ActionKeyPressed(AK_MOVE_DOWN)){
			
			this.setVelocity(this.getVelocity()+Vec2f(0,0.5f));
		}
	
	}
	
}