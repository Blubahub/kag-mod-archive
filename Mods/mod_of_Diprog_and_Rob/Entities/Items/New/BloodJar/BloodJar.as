#include "GetAttached.as";

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("activate"))
    {
		/*CBlob@ attached = getAttached(this, "PICKUP");
		if (attached.getSprite() !is null)
			attached.getSprite().SetOffset( Vec2f(0, 100000) );
		this.server_Die();*/
    }
}
