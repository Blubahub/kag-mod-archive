//This Edited File was Created by Bunnie, ask for permission before using it.

#include "Emote_s.as";

void onInit( CBlob@ blob )
{
	CSprite@ sprite = blob.getSprite();
    blob.set_u8("emote", Emotes::off);
    blob.set_u32("emotetime", 0);
    CSpriteLayer@ emote = sprite.addSpriteLayer( "bubble", "Entities/Common/Emotes/Emoticons.png", 32, 32, 0, 0 );

    if (emote !is null)
    {
        emote.SetOffset(Vec2f(0,-sprite.getBlob().getRadius()*1.5f-16));
        emote.SetRelativeZ(100.0f);
        {
            Animation@ anim = emote.addAnimation( "default", 0, true );

            for (int i = 0; i < Emotes::emotes_total; i++) {
                anim.AddFrame(i);
            }
        }
        emote.SetVisible( false );
        emote.SetHUD( true );
    }

    AddBubblesToMenu( blob ); 	
}



void onTick( CBlob@ blob )
{		
	blob.getCurrentScript().tickFrequency = 6;
	if (!blob.getShape().isStatic())
    {
		CSprite@ sprite = blob.getSprite();
		CSpriteLayer@ emote = sprite.getSpriteLayer( "bubble");

		const u8 index = blob.get_u8("emote");
		if (is_emote(blob, index) && !blob.hasTag("dead"))
		{
			blob.getCurrentScript().tickFrequency = 1;
			if (emote !is null)
			{
				emote.SetVisible( true );
				emote.animation.frame = index;

				emote.ResetTransform();
				if (sprite.isFacingLeft()) {
					emote.ScaleBy(Vec2f(-1.0f,1.0f));
				}
			}
		}
		else
		{				
			emote.SetVisible( false );
		}
    }
}

void onClickedBubble( CBlob@ this, int index )
{
	set_emote( this, index );
}

void AddBubblesToMenu( CBlob@ this )
{
    this.LoadBubbles( "Entities/Common/Emotes/Emoticons.png" );


	this.AddBubble( "", Emotes::aa );
	//this.AddBubble( "", Emotes::ba );
	this.AddBubble( "", Emotes::ca );
	this.AddBubble( "", Emotes::da );
	this.AddBubble( "", Emotes::ea );
	this.AddBubble( "", Emotes::fa );
	this.AddBubble( "", Emotes::ga );
	this.AddBubble( "", Emotes::ha );
	this.AddBubble( "", Emotes::ia );	
	this.AddBubble( "", Emotes::ja );
	this.AddBubble( "", Emotes::ka );
	this.AddBubble( "", Emotes::la );
	this.AddBubble( "", Emotes::ma );
	this.AddBubble( "", Emotes::na );
	this.AddBubble( "", Emotes::oa );
	this.AddBubble( "", Emotes::pa);
	this.AddBubble( "", Emotes::qa );			
	this.AddBubble( "", Emotes::ra );

	//this.AddBubble( "", Emotes::skull );
	//this.AddBubble( "", Emotes::blueflag );
	this.AddBubble( "", Emotes::note );	
	this.AddBubble( "", Emotes::right );
	//this.AddBubble( "", Emotes::smile );
	//this.AddBubble( "", Emotes::redflag );
	this.AddBubble( "", Emotes::flex );
	this.AddBubble( "", Emotes::down );
	//this.AddBubble( "", Emotes::frown );
	//this.AddBubble( "", Emotes::troll );
	this.AddBubble( "", Emotes::finger );
	this.AddBubble( "", Emotes::left );
	//this.AddBubble( "", Emotes::mad );
	//this.AddBubble( "", Emotes::archer );
	this.AddBubble( "", Emotes::sweat );
	this.AddBubble( "", Emotes::up );
	//this.AddBubble( "", Emotes::laugh );
	//this.AddBubble( "", Emotes::knight );
	this.AddBubble( "", Emotes::question );
	this.AddBubble( "", Emotes::thumbsup );
	//this.AddBubble( "", Emotes::wat );
	//this.AddBubble( "", Emotes::builder );
	//this.AddBubble( "", Emotes::disappoint );
	this.AddBubble( "", Emotes::thumbsdown );
	this.AddBubble( "", Emotes::derp );
	//this.AddBubble( "", Emotes::ladder );	
	//this.AddBubble( "", Emotes::attn );	
	//this.AddBubble( "", Emotes::pickup );	
	this.AddBubble( "", Emotes::cry );	
	//this.AddBubble( "", Emotes::wall );	
	this.AddBubble( "", Emotes::heart );	
	//this.AddBubble( "", Emotes::fire );	
	this.AddBubble( "", Emotes::check );	
	this.AddBubble( "", Emotes::cross );	
	//this.AddBubble( "", Emotes::dots );
	this.AddBubble( "", Emotes::cog );
	//derp note
}
