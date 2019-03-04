
void onInit(CBlob@ this)
{
    this.Tag("enemy");
}
void onTick(CBlob@ this)
{

    CSprite@ sprite = this.getSprite();
    if(sprite !is null)
    {    
        if(this.get_string("state") == "moving")
        {
            sprite.SetAnimation("move");
        }

        else 
        {
            sprite.SetAnimation("default");
            sprite.SetFrame(0);
        }
    }
}
