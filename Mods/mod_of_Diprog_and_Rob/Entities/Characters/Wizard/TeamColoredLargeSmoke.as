#include "TeamColour.as";

void onInit( CBlob@ this )
{
	this.SetLight( true );
	this.SetLightRadius( 32.0f );
	this.SetLightColor(getTeamColor(this.getTeamNum()));
	this.getSprite().PlaySound("Thunder2.ogg");
	this.getShape().SetStatic(true);
	this.server_SetTimeToDie(0.8f);
	this.getSprite().SetZ(100);

}