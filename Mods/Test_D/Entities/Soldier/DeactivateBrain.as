#include "HoverMessage.as"

void onTick( CBrain@ this )
{
	CBlob@ blob = this.getBlob();
	CControls@ controls = blob.getControls();
	if (controls !is null && controls.ActionKeyPressed( AK_ACTION1 ) ){
		this.server_SetActive( false );
		print("ENTER PLAYER " + controls.getIndex() );
		Sound::Play("JoinPlayer");
   		AddMessage( blob, "PLAYER " + controls.getIndex() );
	}
}
