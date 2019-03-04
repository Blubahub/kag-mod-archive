// BF_Root script

void onInit(CBlob@ this)
{
	this.Tag( "flora" );
    CSprite@ sprite = this.getSprite();
    sprite.SetFrameIndex(XORRandom(5));
    sprite.SetZ(10.0f);
    sprite.PlaySound("/BF_CarrotPop.ogg", 2.0f);
    this.getShape().SetRotationsAllowed(false);
    this.setVelocity(Vec2f((XORRandom(2) == 0 ? -1 : 1), -1));
}