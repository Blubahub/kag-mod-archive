//Animorph.as
//@author: Verrazano
//@description: A scroll that turns everyone friend or foe into an animal, the animal dies after 10 seconds.

#include "AnimorphCommon.as";

const int radius = 300;

void onInit(CBlob@ this)
{
	this.addCommandID("animorph");

}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("animorph"), "Create your own farm!", params);

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("animorph"))
	{	
		Vec2f pos = this.getPosition();
		CBlob@[] blobList;
		getMap().getBlobsInRadius(pos, radius, blobList);

		for (uint i = 0; i < blobList.length(); i++)
		{ 
			CBlob@ blob = blobList[i];
			if(blob.getPlayer() is null || blob.hasTag("morphed"))
				continue;

			string morphBlob = XORRandom(2) == 1 ? "chicken" : XORRandom(2) == 1 ? "bison" : XORRandom(2) == 1 ? "fishy" : XORRandom(2) == 1 ? "shark" : XORRandom(2) == 1 ? "chicken" : "fishy";
			setupMorphTimer(getRules(), 10, true);
			morph(getRules(), blob, morphBlob);

		}
		
		this.server_Die();
		Sound::Play( "MagicWand.ogg", this.getPosition(), 1.0f, 0.75f );

	}
	
}