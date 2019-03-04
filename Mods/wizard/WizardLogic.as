// Wizard logic

#include "Help.as";
#include "Hitters2.as";

void onInit( CBlob@ this )
{
    this.set_f32("gib health", 0.0f);
    this.Tag("player");
    this.Tag("flesh");
    this.Tag("does not cap");
    this.Tag("does not heal");
    this.Tag("no sudden gib");
    this.set_u8("custom_hitter", Hitters::wizexplosion);
	
	AddIconToken( "$Orb0$", "MagicOrb.png", Vec2f(8,8), 1 , 0);
	AddIconToken( "$Orb1$", "MagicOrb.png", Vec2f(8,8), 1 , 1);
	AddIconToken( "$Teleport$", "SmallExplosion1.png", Vec2f(24,24), 2 );
	AddIconToken( "$Reload$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 4 );
	SetHelp( this, "help show", "wizard", "$Reload$ Reload    $KEY_SPACE$", "" );
	SetHelp( this, "help self action2", "wizard", "$Teleport$Teleport    $RMB$", "" );  
	SetHelp( this, "help self action", "wizard", "$Orb"+this.getTeamNum()+"$Shoot orbs    $LMB$", "", 5 ); 
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick( CBlob@ this )
{
	AttachmentPoint@ hands = this.getAttachments().getAttachmentPointByName("PICKUP");
	hands.offset.Set(0, -1);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData ){
	if (customData == Hitters::wizexplosion){
		return 0.0f;
	}
	if (hitBlob.getName() == "wizard_orb" && hitBlob.getDamageOwnerPlayer() is this.getPlayer()){
		return 0.0f;
	}
	return damage;
}