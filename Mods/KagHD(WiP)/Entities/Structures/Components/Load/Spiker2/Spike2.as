// Spike.as

void onInit(CSprite@ this)
{
	CSpriteLayer@ layer = this.addSpriteLayer("blood", "Spike2.png", 16, 16);
	layer.addAnimation("default", 0, false);
	layer.animation.AddFrame(1);
	layer.SetVisible(false);
}