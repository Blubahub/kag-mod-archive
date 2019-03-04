//Animorph.as
//@author: Verrazano
//@description: Allows moderators to morph players into a random animal using F7 key.
//@usage: add this file to gamemode.cfg.

#include "AnimorphCommon.as"

//exact name of player in game you don't need any deliminators as long as their name appears as it is in game.
const string admins = "Verrazano;Arcrave;";

const string morph1 = "chicken";
const string morph2 = "bison";
const string morph3 = "fishy";
const string morph4 = "shark";
const string morph5 = "door";
const string morph6 = "tree";

const string buildermorph = "drill";
const string knightmorph = "keg";
const string archermorph = "ballista";
const bool useclassmorph = true;

void onTick(CRules@ this)
{
	if(getNet().isServer())
		return;

	if(getLocalPlayer() !is null && getControls().isKeyJustPressed(KEY_F7) && isAdmin(getLocalPlayer()))
	{
		Vec2f pos = getControls().getMouseWorldPos();
		CBlob@[] blobList;
		getMap().getBlobsInRadius(pos, 3, blobList);

		for (uint i = 0; i < blobList.length(); i++)
		{ 
			CBlob@ blob = blobList[i];
			if(blob.getPlayer() is null || blob.hasTag("morphed"))
				continue;

			string morphBlob = chooseBlob(blob);
			setupMorphTimer(this, 10, false);
			morph(this, blob, morphBlob);
			return;

		}

	}

}

string chooseBlob(CBlob@ blob)
{
	if(useclassmorph)
	{
		if(blob.getName() == "builder")
			return buildermorph;
		else if(blob.getName() == "knight")
			return knightmorph;
		else if(blob.getName() == "archer")
			return archermorph;
		else
			return XORRandom(2) == 1 ? morph1 : XORRandom(2) == 1 ? morph2 : XORRandom(2) == 1 ? morph3 : XORRandom(2) == 1 ? morph4 : XORRandom(2) == 1 ? morph5 : morph6;
	}

	return XORRandom(2) == 1 ? morph1 : XORRandom(2) == 1 ? morph2 : XORRandom(2) == 1 ? morph3 : XORRandom(2) == 1 ? morph4 : XORRandom(2) == 1 ? morph5 : morph6;

}

bool isAdmin(CPlayer@ player)
{
	return admins.find(player.getUsername()) < admins.size();

}