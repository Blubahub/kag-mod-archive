// A script by TFlippy

const string[] names =
{
	"Disc_0001_5-Audio:",	"Disc_Blank",	
	"Disc_Another_one_Another_day",
	"Disc_Mayonnaise",
	"Disc_song",
	"Disc_WTF",
	"Disc_Flandre_39_s_Theme_-_U",
	"Disc_Glittering-Shores",
	"Disc_The-Signalist",
	"Disc_AlphysTakesAction",
	"Disc_A-Wistful-Wish",		"Disc_SolSoberstein",

};

void onInit(CBlob@ this)
{
	this.addCommandID("set");
	this.set_u8("trackID", XORRandom(11)); // Temporary 
	
	SetTrack(this, this.get_u8("trackID"));
}

void SetTrack(CBlob@ this, u8 inIndex)
{
	if (inIndex > names.length - 1) return;

	this.set_u8("trackID", inIndex);
	this.getSprite().SetAnimation("track" + inIndex);
	this.setInventoryName("Gramophone Record (" + names[inIndex] + ")");
	
	// print("Current: " + this.getSprite().animation.name + "; Should be: " + "track" + inIndex);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	// print("cmd");

	if (getNet().isClient())
	{
		if (cmd == this.getCommandID("set"))
		{
			// print("set");
			SetTrack(this, params.read_u8());
		}
	}
}