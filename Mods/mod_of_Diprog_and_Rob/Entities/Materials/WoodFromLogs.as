#include "MakeMat.as";

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
    // make wood from hitting log
    if (getNet().isServer() && hitBlob !is null && hitBlob.getName() == "log" && damage > 0.0f)
    {
		//printf("damaga" + damage );
        int amount = 40.0f*damage;
        MakeMat( this, worldPoint, "mat_wood", Maths::Max(1,amount) );
    }
	else if (!this.isAttached())
	{
		if (getNet().isServer() && hitBlob !is null && hitBlob.getName() == "gold_block" && damage > 0.0f)
		{
			MakeMat( this, worldPoint, "mat_gold", 4 );
		}
		else if (getNet().isServer() && hitBlob !is null && hitBlob.getName() == "coins_block" && damage > 0.0f)
		{
			this.getPlayer().server_setCoins(this.getPlayer().getCoins() + 10);
		}
	}
}
