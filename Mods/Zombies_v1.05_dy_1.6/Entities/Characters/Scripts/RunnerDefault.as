#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
#include "FireCommon.as"
#include "Help.as"

void onInit( CBlob@ this )
{
	this.getCurrentScript().removeIfTag = "dead";
	
	//default player minimap dot - not for migrants
	if(this.getName() != "migrant" || this.getName() != "knight_bot" ||  this.getName() != "archer_bot")
	{
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8,8));
	}
	
	this.set_s16( burn_duration , 100 );  
}

// pick up efffects
// something was picked up

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
    this.getSprite().PlaySound( "/PutInInventory.ogg" );
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    this.getSprite().PlaySound( "/Pickup.ogg" );

	if (getNet().isClient())
	{
		RemoveHelps( this, "help throw" );

		if (!attached.hasTag("activated"))
			SetHelp( this, "help throw", "", "$"+attached.getName()+"$"+"Throw    $KEY_C$", "", 2 );
	}

    // check if we picked a player - don't just take him out of the box
    /*if (attached.hasTag("player"))
    this.server_DetachFrom( attached ); CRASHES*/
}

// set the Z back
void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.getSprite().SetZ(0.0f);
}

//stun from hit with stunning water
f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{  
	if (customData == Hitters::water_stun && hitterBlob !is null)
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
		SetKnocked( this, 45 );
		this.Tag("dazzled");
	}

	return damage; //no block, damage goes through
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return this.hasTag("migrant") || this.hasTag("dead") || this.hasTag("npc_bot");
}
