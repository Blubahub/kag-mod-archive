// A script by TFlippy

// 0. Blank
// 1. MountainKing
// 2. Lucio
// 3. SeduceMe
// 4. Mystery
// 5. NoHushing
// 6. Circus
// 7. HotStuff
// 8. MapleLeaf
// 9. DrunkenSailor
// 10. SuitePuntaDelEste

const string[] names =
{
	"Blank",
	"Mountain King",
	"Lucio",
	"Seduce Me",
	"It is a Mystery",
	"No Hushing",
	"Circus!",
	"Hot Stuff",
	"Maple Leaf",
	"Drunken Sailor",
	"Suite Punta del Este"
};

void onInit(CBlob@ this)
{
	this.addCommandID("set");
	this.set_u8("trackID", XORRandom(11)); // Temporary 
	
	SetTrack(this, this.get_u8("trackID"));
}

void SetTrack(CBlob@ this, u8 inIndex)
{
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