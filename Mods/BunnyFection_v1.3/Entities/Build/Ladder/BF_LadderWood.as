//BF_LadderWood script

void onInit( CSprite@ this )
{
	this.SetRelativeZ(-40.0f);
}

void onInit( CShape@ this )
{
	this.SetRotationsAllowed( false );
	this.getVars().waterDragScale = 10.0f;
	this.getConsts().collideWhenAttached = false;
	this.getConsts().waterPasses = true;
}

void onInit( CBlob@ this )
{
	// weird interaction with how blocks are placed
	//this.Tag("ignore blocking actors");
	this.SetFacingLeft(XORRandom(128) > 64);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetFrameIndex( 1 );
    CSpriteLayer@ background = sprite.addSpriteLayer( "background", "BF_LadderWood.png", 16, 16);
    if (background !is null)
    {
        background.addAnimation( "background", 0, false );
        int[] frames = {5};
        background.animation.AddFrames(frames);
        background.SetOffset(Vec2f(0, 3));
        background.SetRelativeZ(-50.0f);
        background.SetVisible(true);
    }
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}