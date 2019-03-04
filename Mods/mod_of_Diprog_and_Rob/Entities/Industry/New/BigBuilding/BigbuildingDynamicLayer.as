void onInit(CSprite@ this)
{
	this.SetZ(-50); //background
	
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ front = this.addSpriteLayer( "front layer", this.getFilename() , 40, 32, blob.getTeamNum(), blob.getSkinNum() );

    if (front !is null)
    {
        Animation@ anim = front.addAnimation( "default", 2, false );
        anim.AddFrame(1);
        front.SetRelativeZ( 1000 );
    }
}
