#include "LootSystem.as";

// name, amount, bonus, weight
const string[][] items =
{
	{"mat_stone", "0", "1000", "800"},
	{"mat_wood", "0", "1000", "1000"},
	{"mat_gold", "0", "500", "400"},
	{"mat_sulphur", "0", "250", "550"},
	{"mat_coal", "0", "100", "600"},
	{"rifle", "1", "1", "170"},
	{"revolver", "1", "2", "248"},
	{"smg", "1", "1", "198"},
	{"mysterybox", "1", "3", "780"},
	{"egg", "1", "2", "750"},
	{"landfish", "1", "1", "450"},
	{"cowo", "0", "1", "55"},
	{"chicken", "1", "2", "125"},
	{"mat_mithril", "0", "100", "250"},
	{"lantern", "1", "1", "500"},
	{"bomb", "1", "2", "675"},
	{"mine", "1", "2", "475"},
	{"keg", "1", "1", "122"},
	{"automat", "1", "0", "76"},
	{"mat_bombita", "1", "0", "27"},
	{"mat_incendiarybomb", "2", "4", "103"},
	{"mat_smallbomb", "4", "16", "247"},
	{"rocket", "1", "0", "468"},
	{"scoutchicken", "1", "1", "50"},
	{"badger", "1", "3", "425"},
	{"mat_oil", "0", "50", "720"},
	{"mat_copperingot", "0", "25", "405"},
	{"mat_ironingot", "0", "25", "358"},
	{"mat_goldingot", "0", "25", "105"},
	{"mat_steelingot", "0", "25", "254"},
	{"artisancertificate", "0", "1", "600"},
	{"mat_mithrilingot", "0", "25", "51"},
	{"badgerden", "1", "1", "154"},
	{"card_pack", "1", "2", "404"},
	{"heart", "1", "5", "743"},
	{"food", "1", "2", "645"},
	{"ratburger", "1", "3", "740"},
	{"bucket", "1", "2", "242"},
	{"sponge", "1", "2", "227"},
	{"mat_rifleammo", "5", "20", "724"},
	{"mat_pistolammo", "10", "60", "754"},
	{"mat_smallrocket", "1", "10", "275"},
	{"bazooka", "1", "0", "164"},
	{"shotgun", "1", "0", "197"},
	{"flamethrower", "0", "1", "179"},
	{"mat_shotgunammo", "4", "16", "674"},
	{"steamtank", "1", "0", "42"},
	{"armoredbomber", "1", "0", "22"},
	{"phone", "1", "0", "21"},
	{"scyther", "1", "0", "5"}, // lolz
	{"infernalstone", "1", "0", "23"},
	{"scubagear", "1", "0", "500"},
	{"ninjascroll", "1", "1", "250"}
};

void onInit(CBlob@ this)
{
	this.addCommandID("box_unpack");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	caller.CreateGenericButton(12, Vec2f(0, 0), this, this.getCommandID("box_unpack"), "Unpack");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("box_unpack"))
	{
		if (getNet().isServer())
		{
			if (this.hasTag("unpacked")) return;

			server_SpawnRandomItem(this, items);

			this.server_Die();
		}

		this.Tag("unpacked");
	}
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	string fname = CFileMatcher("/Crate.png").getFirst();
	for (int i = 0; i < 4; i++)
	{
		CParticle@ temp = makeGibParticle(fname, pos, vel + getRandomVelocity(90, 1 , 120), 9, 2 + i, Vec2f(16, 16), 2.0f, 20, "Sounds/material_drop.ogg", 0);
	}
}
