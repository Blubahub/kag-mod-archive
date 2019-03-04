//Sets our team to the team of whatever's carrying us.

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{		    
	this.server_setTeamNum(attached.getTeamNum());
}	