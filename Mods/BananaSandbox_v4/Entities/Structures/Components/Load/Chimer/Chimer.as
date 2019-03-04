// Chimer.as

#include "MechanismsCommon.as";

//const SColor textColor = SColor(255, 255, 255, 255);

const f32[] noteFrequencies =
{
	220.000f, // A3
	233.082f, // A#3
	246.942f, // B3
	261.626f, // C4
	277.183f, // C#4
	293.665f, // D4
	311.127f, // D#4
	329.628f, // E4
	349.228f, // F4
	369.994f, // F#4
	391.995f, // G4
	415.305f, // G#4
	440.000f, // A4
	466.164f, // A#4
	493.883f  // B4
};

class Chimer : Component
{
	u16 id;

	Chimer(Vec2f position, u16 _id)
	{
		x = position.x;
		y = position.y;

		id = _id;
	}

	void PlayNote(CBlob@ this)
	{
		f32 freq = noteFrequencies[this.get_u8("note")];
		f32 pitchFactor = freq / 440.0f;
		this.getSprite().PlaySound("Chime.ogg", 1.0f, pitchFactor);
	}

	void Activate(CBlob@ this)
	{
		PlayNote(this);

		this.SetLight(true);
		this.getSprite().SetFrameIndex(1);
	}

	void Deactivate(CBlob@ this)
	{
		this.SetLight(false);
		this.getSprite().SetFrameIndex(0);
	}
}

void onInit(CBlob@ this)
{
	// used by BuilderHittable.as
	this.Tag("builder always hit");

	// used by BlobPlacement.as
	this.Tag("place norotate");
	this.Tag("place ignore facing");

	// used by KnightLogic.as
	this.Tag("ignore sword");

	// used by TileBackground.as
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.SetLight(false);
	this.SetLightRadius(10.0f);
	this.SetLightColor(SColor(255, 219, 87, 67));

	this.addCommandID("tuneup");
	this.addCommandID("tunedown");

	AddIconToken("$chimer_tuneup$", "Chimer.png", Vec2f(16, 16), 2);
	AddIconToken("$chimer_tunedown$", "Chimer.png", Vec2f(16, 16), 3);

	this.set_u8("note", XORRandom(noteFrequencies.length()));
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(!isStatic || this.exists("component")) return;

	const Vec2f POSITION = this.getPosition() / 8;

	Chimer component(POSITION, this.getNetworkID());
	this.set("component", component);

	if(getNet().isServer())
	{
		MapPowerGrid@ grid;
		if(!getRules().get("power grid", @grid)) return;

		grid.setAll(
		component.x,                        // x
		component.y,                        // y
		TOPO_CARDINAL,                      // input topology
		TOPO_CARDINAL,                      // output topology
		INFO_LOAD,                          // information
		0,                                  // power
		component.id);                      // id
	}

	CSprite@ sprite = this.getSprite();
	if(sprite !is null)
	{
		sprite.SetZ(500);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(!this.isOverlapping(caller) || !this.getShape().isStatic()) return;

	bool upEnabled = (this.get_u8("note") < noteFrequencies.length() - 1);
	bool downEnabled = (this.get_u8("note") > 0);

	CButton@ upbutton = caller.CreateGenericButton(
	"$chimer_tuneup$",                          // icon token
	Vec2f(0, -5),                               // button offset
	this,                                       // button attachment
	this.getCommandID("tuneup"),                // command id
	"Tune Up");                                 // description

	CButton@ downbutton = caller.CreateGenericButton(
	"$chimer_tunedown$",                        // icon token
	Vec2f(0, 5),                                // button offset
	this,                                       // button attachment
	this.getCommandID("tunedown"),              // command id
	"Tune Down");                               // description

	upbutton.radius = 8.0f;
	upbutton.enableRadius = 40.0f;
	upbutton.SetEnabled(upEnabled);

	downbutton.radius = 8.0f;
	downbutton.enableRadius = 40.0f;
	downbutton.SetEnabled(downEnabled);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool upEnabled = (this.get_u8("note") < noteFrequencies.length() - 1);
	bool downEnabled = (this.get_u8("note") > 0);

	if(cmd == this.getCommandID("tuneup") && upEnabled)
	{
		this.set_u8("note", this.get_u8("note") + 1);

		Chimer@ chimer;
		this.get("component", @chimer);

		if(chimer !is null)
		{
			chimer.PlayNote(this);
		}
	}
	else if(cmd == this.getCommandID("tunedown") && downEnabled)
	{
		this.set_u8("note", this.get_u8("note") - 1);

		Chimer@ chimer;
		this.get("component", @chimer);

		if(chimer !is null)
		{
			chimer.PlayNote(this);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

/*void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob is null) return;

	if(getLocalPlayer() is null) return;
	CBlob@ playerBlob = getLocalPlayer().getBlob();
	if(playerBlob is null) return;

	if(playerBlob.isKeyPressed(key_use) && blob.getShape().isStatic())
	{
		f32 distance = (playerBlob.getPosition() - blob.getPosition()).Length();
		if(distance <= 50.0f)
		{
			string text = formatInt(blob.get_u8("note"), "");
			Vec2f pos = blob.getScreenPos();

			GUI::SetFont("menu");
			GUI::DrawTextCentered(text, pos, textColor);
		}
	}
}*/
