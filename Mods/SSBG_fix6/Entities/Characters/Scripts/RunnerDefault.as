#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked_SSBG.as"
#include "FireCommon.as"
#include "Help.as"

void onInit( CBlob@ this )
{	
	this.getCurrentScript().removeIfTag = "dead";
	
	//default player minimap dot - not for migrants
	if(this.getName() != "migrant")
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

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{  
	if (customData == Hitters::water && hitterBlob !is null)
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
		SetKnocked( this, 45 );
		this.Tag("dazzled");
	}

	return damage; //no block, damage goes through
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return ((this.getTeamNum() != byBlob.getTeamNum()) && (this.get_u8("knocked") > 0 || this.isOnGround()));
}
