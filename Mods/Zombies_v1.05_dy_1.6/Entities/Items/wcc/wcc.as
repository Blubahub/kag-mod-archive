
#include "EmotesCommon.as";

void onInit( CBlob@ this )
{
	//CSpriteLayer@ icon = this.getSprite().addSpriteLayer( "icon", "Heart.png" , 16, 16, this.getTeamNum(), -1 );
	//if(icon !is null)
	//{
	//	icon.SetOffset(Vec2f(-2,1));
	//	icon.SetRelativeZ( 1 );
	//}

	this.getSprite().SetZ(-10.0f);
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	//if (forBlob.getCarriedBlob() is null && this.getInventory().getItemsCount() == 0)
		//return false;
    return true;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{  
	//set_emote(this, Emotes::heart);
}

void onDie(CBlob@ this)
{
    this.getSprite().Gib();
    Vec2f pos = this.getPosition();
    Vec2f vel = this.getVelocity();
    //custom gibs
    string fname = CFileMatcher("/Crate.png").getFirst();	 
    for (int i = 0; i < 4; i++)
    {
        CParticle@ temp = makeGibParticle( fname, pos, vel + getRandomVelocity( 90, 1 , 120 ), 9, 2+i, Vec2f (16,16), 2.0f, 20, "Sounds/material_drop.ogg", 0 );
    }
}
