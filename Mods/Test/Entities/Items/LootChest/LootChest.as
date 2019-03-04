#include "LootSystem.as";

// name, amount, bonus, weight
const string[][] items =
{
	{"mat_stone", "0", "1000", "800"},
	{"mat_wood", "0", "1000", "1000"},
	{"ninjascroll", "1", "1", "250"},
	{"amr", "1", "1", "150"},
	{"assaultrifle", "1", "0", "750"},
	{"fuger", "1", "2", "250"},
	{"smg", "1", "1", "198"},
	{"mat_mithril", "0", "100", "250"},
	{"lantern", "1", "1", "500"},
	{"mat_copperingot", "0", "64", "400"},
	{"mat_ironingot", "0", "64", "500"},
	{"mat_goldingot", "0", "64", "100"},
	{"mat_steelingot", "0", "64", "250"},
	{"mat_mithrilingot", "0", "32", "50"},
	{"foodcan", "2", "4", "500"},
	{"bp_chickenassembler", "1", "0", "500"},
	{"phone", "1", "0", "750"},
	{"mat_rifleammo", "5", "20", "400"},
	{"mat_pistolammo", "10", "60", "400"},
	{"autoshotgun", "1", "0", "197"},
	{"raygun", "0", "1", "179"},
	{"mat_shotgunammo", "4", "16", "400"},
	{"scubagear", "1", "0", "400"},
	{"rekt", "1", "0", "15"},
	{"zatniktel", "1", "0", "20"},
	{"blaster", "1", "0", "25"}
};

void onInit(CBlob@ this)
{
	this.addCommandID("chest_open");

	AddIconToken("$chest_open$", "InteractionIcons.png", Vec2f(32, 32), 20);

	CSprite@ sprite = this.getSprite();
	if(sprite !is null)
	{
		u8 team_color = XORRandom(5);
		this.set_u8("team_color", team_color);

		sprite.SetZ(-10.0f);
		sprite.ReloadSprites(team_color, 0);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() != 250 && !this.hasTag("opened"))
	{
		caller.CreateGenericButton("$chest_open$", Vec2f(0, 0), this, this.getCommandID("chest_open"), "Open");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("chest_open"))
	{
		if (getNet().isServer())
		{
			if (this.hasTag("opened")) return;

			for(int i = 0; i < 3; i++)
			{
				server_SpawnRandomItem(this, items);
			}

			server_SpawnCoins(this, 200 + XORRandom(200));
		}

		CSprite@ sprite = this.getSprite();
		if(sprite !is null)
		{
			sprite.SetAnimation("open");
			sprite.PlaySound("ChestOpen.ogg", 3.0f);
		}

		this.Tag("opened");
	}
}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null)
	{
		sprite.Gib();

		makeGibParticle(
		sprite.getFilename(),               // file name
		this.getPosition(),                 // position
		getRandomVelocity(90, 2, 360),      // velocity
		0,                                  // column
		3,                                  // row
		Vec2f(16, 16),                      // frame size
		1.0f,                               // scale?
		0,                                  // ?
		"",                                 // sound
		this.get_u8("team_color"));         // team number
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
